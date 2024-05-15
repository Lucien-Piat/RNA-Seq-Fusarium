#!/bin/bash

# Load configurations from JSON
CONFIG_FILE="./configuration.json"

# Use jq to extract paths
TRIMMED_OUTPUT_DIR=$(jq -r '.scripts[] | select(.name=="alignement.sh") | .paths.TRIMMED_OUTPUT_DIR' "$CONFIG_FILE")
GENOME_DIR=$(jq -r '.scripts[] | select(.name=="alignement.sh") | .paths.GENOME_DIR' "$CONFIG_FILE")
OUTPUT_DIR=$(jq -r '.scripts[] | select(.name=="alignement.sh") | .paths.OUTPUT_DIR' "$CONFIG_FILE")

# Path to the BWA-MEM2 executable
BWA_MEM2="./tools/bwa-mem2-2.2.1_x64-linux/bwa-mem2.avx2"

# Prompt the user to enter the list of genomes
read -p "Enter the list of the reference genomes exact filenames (separated by spaces): " -a GENOMES

# Display the list of genomes entered by the user
echo "List of reference genomes entered :"
for genome in "${GENOMES[@]}"; do
  echo "$genome"
done

# Check if the output directory exists and create it if not
if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir -p "$OUTPUT_DIR"
  echo "Created output directory: $OUTPUT_DIR"
fi

# Function to check if genome is indexed
is_indexed() {
  local genome_path="$1"
  local expected_files=("bwt" "pac" "ann" "amb" "sa")

  for ext in "${expected_files[@]}"; do
    if [ ! -f "${genome_path}.${ext}" ]; then
      return 1  # Not indexed
    fi
  done
  return 0  # Indexed
}

# Index genomes if not already indexed
for genome in "${GENOMES[@]}"; do
  genome_path="$GENOME_DIR/$genome"
  if ! is_indexed "$genome_path"; then
    echo "Indexing $genome"
    $BWA_MEM2 index "$genome_path"
  else
    echo "$genome is already indexed"
  fi
done

# Define the read files from TRIMMED_OUTPUT_DIR
READS=($(ls "$TRIMMED_OUTPUT_DIR"/*_trimmed.fastq.gz))

# Loop through all genomes and reads for alignment
for genome in "${GENOMES[@]}"; do
  for read in "${READS[@]}"; do
    echo "Aligning $read to $genome"
    output_path="$OUTPUT_DIR/${genome}_$(basename "$read" .fastq.gz).sam"
    command="$BWA_MEM2 mem \"$genome_path\" \"$read\" > \"$output_path\""
    eval "$command"
  done
done
echo "Alignment process complete."
