#!/bin/bash

# Constants
CONFIG_FILE="./configuration.json"

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found at $CONFIG_FILE"
    exit 1
fi

# Load configuration and print it
echo "Loading configuration..."
INDEX=4  # Correct index for the miRNAs_identification.sh configuration
ENV_NAME=$(jq -r ".scripts[$INDEX].environment.name" $CONFIG_FILE)
CONDA_PATH=$(jq -r ".scripts[$INDEX].environment.conda_path" $CONFIG_FILE)
GENOME_PATH=$(jq -r ".scripts[$INDEX].paths.genome_path" $CONFIG_FILE)
READ_DIR=$(jq -r ".scripts[$INDEX].paths.read_directory" $CONFIG_FILE)

# Print configurations for debugging
echo "ENV_NAME: $ENV_NAME"
echo "CONDA_PATH: $CONDA_PATH"
echo "GENOME_PATH: $GENOME_PATH"
echo "READ_DIR: $READ_DIR"

if [[ "$CONDA_PATH" == null || "$CONDA_PATH" == "" ]]; then
  echo "Conda path is not set or invalid in the configuration."
  exit 1
fi

echo "Sourcing Conda from $CONDA_PATH..."
source "$CONDA_PATH" || { echo "Failed to source Conda from $CONDA_PATH"; exit 1; }

echo "Activating Conda environment $ENV_NAME..."
conda activate "$ENV_NAME" || { echo "Failed to activate environment $ENV_NAME"; exit 1; }

echo "Environment activated successfully."



# Get timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Read genomes mapping
declare -A genomes
while IFS="=" read -r key value
do
    genomes["$key"]="$value"
done < <(jq -r ".scripts[$INDEX].genomes | to_entries | .[] | .key + \"=\" + .value" $CONFIG_FILE)

# Loop over each fastq file in the read directory
for readfile in "$READ_DIR"/*.fastq.gz; do
    basename=$(basename "$readfile" .fastq.gz)
    for genome in "${!genomes[@]}"; do
        OUT_DIR_PATTERN=$(jq -r '.output_naming.pattern' $CONFIG_FILE)
        genome_outdir="${OUT_DIR_PATTERN//{genome}/$genome}"
        genome_outdir="${genome_outdir//{basename}/$basename}"
        genome_outdir="${genome_outdir//{timestamp}/$TIMESTAMP}"
        genome_outdir="/mnt/c/Users/marwa/OneDrive/Desktop/new/RNA_seq/$genome_outdir"
        echo "Running ShortStack for $genome on $basename in $genome_outdir..."
        ShortStack --genomefile "$GENOME_PATH/${genomes[$genome]}" --readfile "$readfile" --outdir "$genome_outdir"
    done
done

echo "All analyses are complete."
