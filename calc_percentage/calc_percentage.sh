#!/bin/bash

#author: berat postalcioglu

precision=2

display_help()
{
  echo "usage: calc_percentage.sh \"[file_pattern]\" [num_of_files] [update_seconds]"
}

if (($# <= 1 ));then
  display_help 
  exit 1
fi

pattern=$1
num_of_files=$2
if [ -z "$3" ];then
  update_secs=5
else
  update_secs="$3"
fi
error_str="ARGUMENT ERROR"

check_is_number()
{
  input=$1
  name=$2
  if [[ -n "${input//[0-9]/}" ]];then
    echo "$error_str: $name argument must be an integer"
    display_help
    exit 1
  fi
}

check_is_number "$num_of_files" "num_of_files"
check_is_number "$update_secs" "update_secs"

if (($num_of_files <= 0));then
  echo "$error_str: num_of_files argument must be greater than 0"
  display_help
  exit 1
fi

while true; do
	cnt=$(find . -iname "$pattern" | wc -l)
	percentage=$(echo "scale=$precision;($cnt/$num_of_files)*100" | bc)
	echo -ne "%$percentage : ($cnt/$num_of_files)\r"
	sleep "$update_secs" 
done
