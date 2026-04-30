#!/usr/bin/env bash

top -bn1 | awk '
/^%Cpu/ {
    gsub(",", "")

    used = $2 + $4

    printf "CPU %.0f%%\n", used
    exit
}
'
