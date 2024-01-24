#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 source_folder destination_folder"
	exit 1
fi

source_folder=$1
destination_folder=$2

if [ ! -d "$source_folder" ]; then
	echo "Error $source_folder does not exist"
	exit 1
fi


cp -r "$source_folder"/* "$destination_folder"

echo "files copied from $source_folder to $destination_folder successfully"

