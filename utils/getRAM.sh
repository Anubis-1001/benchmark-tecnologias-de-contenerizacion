#!/bin/bash
cat "record_$1.txt"  | awk '{printf "%s\n", $14}' | sed '/^$/d; /RSS/d'
