#!/bin/bash
# Usage: trimming.sh <input_dir> <output_dir> <csv_file>

# Command-line arguments
INPUT_DIR="$1"
OUTPUT_DIR="$2"
CSV_FILE="$3"  # This should be a direct path to a CSV file, not a directory

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Adapter sequences
ILLUMINA_ADAPTER="AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"
SOLID_ADAPTER="CCACTACGCCTCCGCTTTCCTCTCTATGGGCAGTCGGTGAT"
miRNA_5="GTTCAGAGTTCTACAGTCCGA"
miRNA_3="AACTGTAGGCACCATCAAT"
UDI_adapter="CTACACGACGCTCTTCCGATCT"

# Validate extracted sequences to ensure they are valid IUPAC codes
validate_iupac() {
  local seq="$1"
  clean_seq="${seq//[[:space:]]/}"  # Strip whitespace
  echo "Validating sequence: '$clean_seq'"
  if [[ ! "$clean_seq" =~ ^[ACGTURYKMSWBDHVN]+$ ]]; then
    echo "Invalid IUPAC code in sequence: '$clean_seq'"
    exit 1
  fi
}

echo "Processing CSV file: $CSV_FILE"
# Read each line of the CSV file, skipping the header
tail -n +2 "$CSV_FILE" | while IFS=, read -r Confrontation Name i7_RUDI index_i7 i5_RUDI index_i5; do
  echo "Processing Sample: $Name, i7Seq: $index_i7, i5Seq: $index_i5"

  # Validate IUPAC codes for the adapter sequences
  validate_iupac "$index_i7"
  validate_iupac "$index_i5"

  # Construct the input and output file paths
  INPUT_FILE="${INPUT_DIR}/${Name}.fastq.gz"
  TEMP_OUTPUT_FILE="${OUTPUT_DIR}/${Name}.fastq"
  FINAL_OUTPUT_FILE="${OUTPUT_DIR}/${Name}_trimmed.fastq.gz"
  SUMMARY_FILE="${OUTPUT_DIR}/trimming_summary.txt"

  # Check if the file exists
  if [[ -f "$INPUT_FILE" ]]; then
    echo "Processing file: $INPUT_FILE" | tee -a "$SUMMARY_FILE"

    # Decompress, run Cutadapt with adapter sequences, then recompress
    gunzip -c "$INPUT_FILE" > "$TEMP_OUTPUT_FILE"
    cutadapt -a "$index_i7" -a "$index_i5" -a "$ILLUMINA_ADAPTER" -a "$SOLID_ADAPTER" -g "$miRNA_5" -a "$miRNA_3" -m 15 -M 30 -o "$FINAL_OUTPUT_FILE" "$TEMP_OUTPUT_FILE" | tee -a "$SUMMARY_FILE"
    gzip "$TEMP_OUTPUT_FILE"  # Recompress the temporary output

    echo "Processing successful for $INPUT_FILE" | tee -a "$SUMMARY_FILE"
  else
    echo "File $INPUT_FILE does not exist." | tee -a "$SUMMARY_FILE"
  fi
  # Add a separator between samples
  echo -e "\n---\n" | tee -a "$SUMMARY_FILE"
done
echo "Trimming process complete."
