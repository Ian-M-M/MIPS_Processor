#!/bin/bash

for i in $(seq 1 1048576); do
    hex="$(echo "obase=16;$i" | bc)"
    echo "$hex"
done