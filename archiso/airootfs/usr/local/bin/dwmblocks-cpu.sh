#!/usr/bin/env bash

top -bn1 | awk '/^%Cpu/ {
    gsub(",", "", $2)
    print $2 "%"
}'
