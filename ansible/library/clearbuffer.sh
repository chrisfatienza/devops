#!/bin/bash

# Function to check if the buffer size exceeds 90% of total memory
check_buffer_size() {
    local total_mem=$(free -m | awk 'NR==2 {print $2}')
    local buffer_size=$(free -m | awk 'NR==2 {print $6}')
    local buffer_percentage=$((buffer_size * 100 / total_mem))

    if [[ $buffer_percentage -ge 90 ]]; then
        echo "Buffer size is ${buffer_percentage}% of total memory. Clearing memory buffer..."
        sync && echo 1 > /proc/sys/vm/drop_caches
    else
        echo "Buffer size is ${buffer_percentage}% of total memory. No action needed."
    fi
}

echo "Before clearing memory buffer:"
free -h

check_buffer_size

echo "After clearing memory buffer:"
free -h
