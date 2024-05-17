#!/bin/bash

# Load necessary modules or activate conda environment
# Uncomment and modify the following lines based on your environment setup
# source /path/to/conda.sh
# conda activate cufflinks_env

# Base directory
BASE_DIR="/mnt/c/Users/marwa/OneDrive/Desktop/new/RNA_seq"

# Define paths to reference genomes
GENOME_FA1="$BASE_DIR/genomes/Fgraminearum_Genome.fasta"
GENOME_FA2="$BASE_DIR/genomes/Fverticillioides_Genome.fasta"

# Define paths to GFF files
GFF1="$BASE_DIR/Fgraminearum.gff"
GFF2="$BASE_DIR/Fverticillioides.gff"

# Convert GFF to GTF
GTF1="$BASE_DIR/annotations1.gtf"
GTF2="$BASE_DIR/annotations2.gtf"

# Create output directories if they don't exist
OUTPUT_GENOME1="$BASE_DIR/output_genome1"
OUTPUT_GENOME2="$BASE_DIR/output_genome2"
mkdir -p $OUTPUT_GENOME1
mkdir -p $OUTPUT_GENOME2

# Convert GFF to GFF3 using gffread (then to GTF)
GFF3_1="$BASE_DIR/annotations1.gff3"
GFF3_2="$BASE_DIR/annotations2.gff3"

# Convert GFF to GFF3 first
gffread $GFF1 -o $GFF3_1
gffread $GFF2 -o $GFF3_2

# Then convert GFF3 to GTF
gffread $GFF3_1 -T -o $GTF1
gffread $GFF3_2 -T -o $GTF2

# Directory where BAM files are stored
BAM_DIR="$BASE_DIR/bam_files"

# Define the CONDITIONS array with only C9 and C25
CONDITIONS=("C9" "C25")

# Example use of CONDITIONS in processing loop
for sample in "${CONDITIONS[@]}"; do
    echo "Processing $sample..."

    # Determine the appropriate genome based on sample naming convention or other logic
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

    # Assuming sorted BAM files are named to reflect the sample names and conditions
    echo "Looking for sorted BAM files in: $BAM_DIR"
    echo "Patterns: *_${sample}_trimmed_sorted.bam"

    CONDITION1_FILES=$(find $BAM_DIR -name "Fgraminearum_Genome.fasta_${sample}_trimmed_sorted.bam" | tr '\n' ',')
    CONDITION2_FILES=$(find $BAM_DIR -name "Fverticillioides_Genome.fasta_${sample}_trimmed_sorted.bam" | tr '\n' ',')
    CONDITION1_FILES=${CONDITION1_FILES%,}  # Remove the trailing comma
    CONDITION2_FILES=${CONDITION2_FILES%,}  # Remove the trailing comma

    echo "Condition 1 files: $CONDITION1_FILES"
    echo "Condition 2 files: $CONDITION2_FILES"

    if [ -n "$CONDITION1_FILES" ] && [ -n "$CONDITION2_FILES" ]; then
        CUFFDIFF_CMD="cuffdiff -o $OUTPUT_DIR/${sample} -b $GENOME_FA -p 8 -L condition1,condition2 -u $ANNOT $CONDITION1_FILES $CONDITION2_FILES"
        echo $CUFFDIFF_CMD
        # Execute the command
        eval $CUFFDIFF_CMD
    else
        echo "Not enough sorted BAM files found for sample $sample. Condition 1 files: $CONDITION1_FILES, Condition 2 files: $CONDITION2_FILES"
    fi
done

echo "Analysis complete for all samples."
