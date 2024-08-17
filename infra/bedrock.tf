data "aws_iam_policy" "bedrock_default" {
  name = "AmazonBedrockFullAccess"
}


data "aws_iam_policy_document" "bedrock_trust" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

  }
}

resource "aws_iam_role" "bedrock" {
  name               = "BedrockDefaultRole"
  assume_role_policy = data.aws_iam_policy_document.bedrock_trust.json
}

data "aws_iam_policy_document" "default_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "rds-data:ExecuteStatement",
      "rds:DescribeDBClusters",
      "rds-data:BatchExecuteStatement"
    ]

    resources = [aws_rds_cluster.postgres.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_rds_cluster.postgres.master_user_secret[0].secret_arn]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "${aws_s3_bucket.data_source.arn}",
      "${aws_s3_bucket.data_source.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "bedrock_default" {
  name   = "DefaultPolicy"
  policy = data.aws_iam_policy_document.default_role_policy.json
}


resource "aws_iam_role_policy_attachment" "bedrock" {
  role       = aws_iam_role.bedrock.name
  policy_arn = data.aws_iam_policy.bedrock_default.arn
}

resource "aws_iam_role_policy_attachment" "bedrock_default" {
  role       = aws_iam_role.bedrock.name
  policy_arn = aws_iam_policy.bedrock_default.arn
}


resource "awscc_bedrock_knowledge_base" "bedrock" {
  name        = "bedrock-knowledge-base"
  description = "Bedrock Knowledge base"
  role_arn    = aws_iam_role.bedrock.arn

  storage_configuration = {
    type = "RDS"
    rds_configuration = {
      credentials_secret_arn = aws_rds_cluster.postgres.master_user_secret[0].secret_arn
      database_name          = "postgres"
      field_mapping = {
        metadata_field    = "metadata"
        primary_key_field = "id"
        text_field        = "chunks"
        vector_field      = "embedding"
      }
      table_name   = "bedrock_integration.bedrock_kb"
      resource_arn = aws_rds_cluster.postgres.arn
    }
  }
  knowledge_base_configuration = {
    type = "VECTOR"
    vector_knowledge_base_configuration = {
      embedding_model_arn = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
    }
  }
  depends_on = [aws_iam_role.bedrock]
}

resource "aws_s3_bucket" "data_source" {
  bucket = "bedrock-data-source-${data.aws_caller_identity.current.account_id}"
}

resource "aws_bedrockagent_data_source" "example" {
  knowledge_base_id = awscc_bedrock_knowledge_base.bedrock.id
  name              = "bedrock-data-source"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.data_source.arn
    }
  }
}