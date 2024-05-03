#!/bin/bash

# Relative path to the JSON configuration file
CONFIG_FILE="./rna_seq_config.json"

# Use jq to extract paths for input and output directories
input_dir=$(jq -r '.scripts[] | select(.name=="samtools.sh") | .paths.input_dir' "$CONFIG_FILE")
output_dir=$(jq -r '.scripts[] | select(.name=="samtools.sh") | .paths.output_dir' "$CONFIG_FILE")

# Ensure the output directory exists
mkdir -p "$output_dir" || { echo "Failed to create output directory: $output_dir"; exit 1; }
echo "Output directory ensured at: $output_dir"

# Loop through all SAM files in the input directory
for sam_file in "$input_dir"/*.sam; do
    # Check if the file exists
    if [ ! -f "$sam_file" ]; then
        echo "SAM file not found: $sam_file"
        continue
    fi

    # Extract the base name without the extension
    base_name=$(basename "$sam_file" .sam)

    # Convert SAM to BAM
    bam_file="$output_dir/${base_name}.bam"
    echo "Converting $sam_file to BAM format."
    samtools view -bS "$sam_file" > "$bam_file"

    # Sort the BAM file
    sorted_bam_file="$output_dir/${base_name}_sorted.bam"
    echo "Sorting BAM file: $bam_file"
    samtools sort "$bam_file" -o "$sorted_bam_file"

    # Index the sorted BAM file
    echo "Indexing sorted BAM file: $sorted_bam_file"
    samtools index "$sorted_bam_file"

    # File path for idxstats output
    idxstats_file="$output_dir/${base_name}_idxstats.txt"

    # Add headers to idxstats output
    echo -e "Reference\tLength\tMapped Reads\tUnmapped Reads" > "$idxstats_file"

    # Generate idxstats for the sorted BAM file and append to the txt file
    echo "Generating idxstats for: $sorted_bam_file"
    samtools idxstats "$sorted_bam_file" >> "$idxstats_file"
done

echo "All SAM files have been processed."

