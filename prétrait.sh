#!/bin/bash

# Read the JSON config file
CONFIG_FILE="config.json"

# Extract values from JSON
CSV_FILE=$(jq -r '.csv_file' "$CONFIG_FILE")
FASTQC_INPUT_DIR=$(jq -r '.fastqc_input_dir' "$CONFIG_FILE")
FASTQC_OUTPUT_DIR=$(jq -r '.fastqc_output_dir' "$CONFIG_FILE")
TRIMMED_OUTPUT_DIR=$(jq -r '.trimmed_output_dir' "$CONFIG_FILE")

# Adapter sequences
I7_SEQ=$(jq -r '.cutadapt.adapters.i7_seq' "$CONFIG_FILE")
I5_SEQ=$(jq -r '.cutadapt.adapters.i5_seq' "$CONFIG_FILE")
MIRNA_5=$(jq -r '.cutadapt.adapters.mirna_5' "$CONFIG_FILE")
MIRNA_3=$(jq -r '.cutadapt.adapters.mirna_3' "$CONFIG_FILE")
UDI=$(jq -r '.cutadapt.adapters.udi' "$CONFIG_FILE")
illumina_adapter=$(jq -r '.cutadapters.adapters.illumina_adapter' "$CONFIG_FILE")
solid_adapter=$(jq -r '.cutadapters.adapters.solid_adapter' "$CONFIG_FILE")
# Ensure directories exist
mkdir -p "$FASTQC_OUTPUT_DIR"
mkdir -p "$TRIMMED_OUTPUT_DIR"

# FastQC Analysis
echo "Running FastQC..."
find "$FASTQC_INPUT_DIR" -name '*.fastq.gz' | while read -r file; do
  echo "Processing $file with FastQC..."
  fastqc "$file" -o "$FASTQC_OUTPUT_DIR"
done
echo "FastQC analysis complete."

# Trimming Process
echo "Starting trimming process..."
tail -n +2 "$CSV_FILE" | while IFS=, read -r Descriptor SampleID i7Name i7Seq i5Name i5Seq other_columns; do
  INPUT_FILE="${FASTQC_INPUT_DIR}/${SampleID}.fastq.gz"
  TEMP_OUTPUT_FILE="${TRIMMED_OUTPUT_DIR}/${SampleID}.fastq"
  FINAL_OUTPUT_FILE="${TRIMMED_OUTPUT_DIR}/${SampleID}_trimmed.fastq.gz"

  if [[ -f "$INPUT_FILE" ]]; then
    echo "Processing file: $INPUT_FILE"
    gunzip -c "$INPUT_FILE" > "$TEMP_OUTPUT_FILE"
    cutadapt $I7_SEQ $I5_SEQ $MIRNA_5 $MIRNA_3 $UDI $illumina_adapter $solid_adapter -o "$FINAL_OUTPUT_FILE" "$TEMP_OUTPUT_FILE"
    gzip "$TEMP_OUTPUT_FILE"
    echo "Processing successful for $INPUT_FILE"
  else
    echo "File $INPUT_FILE does not exist."
  fi
done
echo "Trimming process complete."
