#!/bin/bash

# Input file containing names and numbers
input_file="final.txt"

# Base URL for downloading files
base_url="https://oshoworld.com/wp-content/uploads/2020/11/Hindi%20Audio/OSHO-"

# Loop through each line in the input file
while IFS=' ' read -r name count; do
    # Create a directory named after the ${name}
    mkdir -p "$name"
    
    # Loop through the numbers from 1 to the specified count
    for i in $(seq 1 $count); do
        # Format the number with leading zeros (if necessary)
        num=$(printf "%02d" $i)
        
        # Construct the full URL
        url="${base_url}${name}_${num}.mp3"
        
        # Construct the file path
        file_path="$name/$(basename "$url")"
        
        # Check if the file already exists
        if [ -f "$file_path" ]; then
            # Get the size of the existing file
            existing_size=$(stat -c %s "$file_path")
            
            # Get the size of the file on the server
            server_size=$(wget --spider --server-response "$url" 2>&1 | grep "Content-Length" | awk '{print $2}')
            
            if [ "$existing_size" -eq "$server_size" ]; then
                echo "File $file_path already exists and is complete. Skipping download."
            else
                # Calculate the size difference
                size_diff=$((server_size - existing_size))
                
                echo "File $file_path exists but is incomplete."
                echo "Existing size: $existing_size bytes"
                echo "Server size: $server_size bytes"
                echo "Size difference: $size_diff bytes"
                
                echo "Re-downloading $url"
                wget -c "$url" -P "$name"
            fi
        else
            echo "Downloading $url"
            wget -c "$url" -P "$name"
        fi
    done
done < "$input_file"
