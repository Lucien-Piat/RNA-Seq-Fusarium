#!/bin/bash
# Usage: quality_control.sh <input_dir> <output_dir>

input_dir="$1"
output_dir="$2"

echo "Script started."

# Create directories if they don't exist
mkdir -p "$output_dir"

echo "Running FastQC..."
find "$input_dir" -name '*.fastq.gz' | while read -r file; do
    echo "Processing $file with FastQC..."
    fastqc "$file" -o "$output_dir"
    # Add a separator between samples
    echo -e "\n---\n"
done
echo "FastQC analysis complete."
