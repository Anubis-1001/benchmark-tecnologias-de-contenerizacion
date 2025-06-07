#!/bin/bash
cat "record_$1.txt"  | awk '{printf "%s\n", $8 }' | sed '/^$/d; /wait/d'
