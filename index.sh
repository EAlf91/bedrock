#!/bin/bash

start=0
end=250
max=14000

while [ $start -lt $max ]
do
    python main.py $start $end
    start=$end
    end=$(($end + 250))
done