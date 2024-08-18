output "private_subnets_ids" {
  value = [aws_subnet.private1.id, aws_subnet.private2.id]
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}