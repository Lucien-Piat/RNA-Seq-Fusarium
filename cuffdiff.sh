#!/bin/bash

# Path to the JSON configuration file
CONFIG_FILE="./rna_seq_config.json"

# Function to extract values from JSON
extract_json_value() {
    local key=$1
    jq -r "$key" "$CONFIG_FILE"
}

# Extract paths and parameters from JSON
BASE_DIR=$(extract_json_value '.scripts[] | select(.name == "cuffdiff.sh") | .paths.base_directory')
GENOME_FA1=$(extract_json_value '.scripts[] | select(.name == "cuffdiff.sh") | .paths.genome_fa1')
GENOME_FA2=$(extract_json_value '.scripts[] | select(.name == "cuffdiff.sh") | .paths.genome_fa2')
GFF1=$(extract_json_value '.scripts[] | select(.name == "cuffdiff.sh") | .paths.gff1')
GFF2=$(extract_json_value '.scripts[] | select(.name == "cuffdiff.sh") | .paths.gff2')
BAM_DIR=$(extract_json_value '.scripts[] | select(.name == "cuffdiff.sh") | .paths.bam_dir')
CONDITIONS=$(extract_json_value '.scripts[] | select(.name == "cuffdiff.sh") | .paths.conditions | join(" ")')
CONDA_PATH=$(extract_json_value '.scripts[] | select(.name == "cuffdiff.sh") | .environment.conda_path')

# Activate the conda environment
source "$CONDA_PATH"
conda activate cufflinks_env

# Create output directories if they don't exist
OUTPUT_GENOME1="$BASE_DIR/output_genome1"
OUTPUT_GENOME2="$BASE_DIR/output_genome2"
mkdir -p "$OUTPUT_GENOME1"
mkdir -p "$OUTPUT_GENOME2"

# Convert GFF to GTF using gffread (assumes gffread is available in the environment)
GTF1="$BASE_DIR/annotations1.gtf"
GTF2="$BASE_DIR/annotations2.gtf"
GFF3_1="$BASE_DIR/annotations1.gff3"
GFF3_2="$BASE_DIR/annotations2.gff3"

# Convert GFF to GFF3 first, then to GTF
gffread "$GFF1" -o "$GFF3_1"
gffread "$GFF2" -o "$GFF3_2"
gffread "$GFF3_1" -T -o "$GTF1"
gffread "$GFF3_2" -T -o "$GTF2"

# Process each condition
for sample in $CONDITIONS; do
    echo "Processing $sample..."

    # Determine the appropriate genome and output directory based on sample
    if [[ "$sample" == "C9" ]]; then
        GENOME_FA="$GENOME_FA1"
        OUTPUT_DIR="$OUTPUT_GENOME1"
        ANNOT="$GTF1"
    elif [[ "$sample" == "C25" ]]; then
        GENOME_FA="$GENOME_FA2"
        OUTPUT_DIR="$OUTPUT_GENOME2"
        ANNOT="$GTF2"
    else
        echo "Sample $sample does not match any known genomes."
        continue
    fi

    # Find sorted BAM files for each condition
    echo "Looking for sorted BAM files in: $BAM_DIR"
    echo "Patterns: *_${sample}_trimmed_sorted.bam"

    CONDITION1_FILES=$(find "$BAM_DIR" -name "Fgraminearum_Genome.fasta_${sample}_trimmed_sorted.bam" | tr '\n' ',')
    CONDITION2_FILES=$(find "$BAM_DIR" -name "Fverticillioides_Genome.fasta_${sample}_trimmed_sorted.bam" | tr '\n' ',')
    CONDITION1_FILES=${CONDITION1_FILES%,}  # Remove the trailing comma
    CONDITION2_FILES=${CONDITION2_FILES%,}  # Remove the trailing comma

    echo "Condition 1 files: $CONDITION1_FILES"
    echo "Condition 2 files: $CONDITION2_FILES"

    # Check if there are enough files for both conditions
    if [ -n "$CONDITION1_FILES" ] && [ -n "$CONDITION2_FILES" ]; then
        CUFFDIFF_CMD="cuffdiff -o $OUTPUT_DIR/${sample} -b $GENOME_FA -p 8 -L condition1,condition2 -u $ANNOT $CONDITION1_FILES $CONDITION2_FILES"
        echo "$CUFFDIFF_CMD"
        # Execute the command
        eval "$CUFFDIFF_CMD"
    else
        echo "Not enough sorted BAM files found for sample $sample. Condition 1 files: $CONDITION1_FILES, Condition 2 files: $CONDITION2_FILES"
    fi
done

echo "Analysis complete for all samples."
