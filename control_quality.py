import subprocess
import glob
import csv
import json
import logging
from argparse import ArgumentParser

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def run_command(command):
    """Executes a shell command and captures the output and errors."""
    try:
        result = subprocess.check_output(command, stderr=subprocess.STDOUT, shell=True)
        logging.info("Command executed successfully: %s", ' '.join(command))
        return result.decode('utf-8')
    except subprocess.CalledProcessError as e:
        logging.error("Error occurred while executing command: %s", ' '.join(command))
        logging.error(e.output.decode('utf-8'))
        return None

def perform_quality_check(fastqc_input_dir, fastqc_output_dir):
    fastq_files = glob.glob(f"{fastqc_input_dir}/**/*fastq.gz", recursive=True)
    if not fastq_files:
        logging.info("No FASTQ files found for FastQC.")
    for file in fastq_files:
        logging.info(f"Found FASTQ file for FastQC: {file}")
        subprocess.run(['fastqc', file, '-o', fastqc_output_dir])
    logging.info("All FastQC analyses are complete.")


def trim_reads(cutadapt_input_dir, cutadapt_output_dir, metadata_csv):
    indices = {}
    with open(metadata_csv, mode='r') as infile:
        reader = csv.DictReader(infile)
        for row in reader:
            indices[row['Name']] = (row['i7_RUDI'], row['i5_RUDI'])

    fastq_files = glob.glob(f"{cutadapt_input_dir}/**/*.fastq.gz", recursive=True)
    if not fastq_files:
        logging.info("No FASTQ files found for trimming.")
    for file in fastq_files:
        base = file.split('/')[-1].replace('.fastq.gz', '')
        logging.info(f"Found FASTQ file for trimming: {file}")
        if base in indices:
            i7_index, i5_index = indices[base]
            output_file = f"{cutadapt_output_dir}/{base}_trimmed.fastq.gz"
            logging.info(f"Trimming {file} with i7 index {i7_index}, i5 index {i5_index}...")
            subprocess.run([
                'cutadapt',
                '-a', 'GTTCAGAGTTCTACAGTCCGACGATC',  # miRNA adapter 5'
                '-A', 'AACTGTAGGCACCATCAAT',          # miRNA adapter 3'
                '-g', 'CTACACGACGCTCTTCCGATCT',       # UDI adapter
                '-a', i7_index,  # i7 index adapter
                '-A', i5_index,  # i5 index adapter (if applicable)
                '-q', '20',      # Quality cutoff
                '-m', '18',      # Minimum length of trimmed reads
                '-o', output_file,
                file
            ])
        else:
            logging.warning(f"No indices found for {base}, skipping trimming.")
    logging.info("Trimming complete.")


if __name__ == "__main__":
    parser = ArgumentParser(description="Run genomics preprocessing and analysis pipeline.")
    parser.add_argument("config_file", help="Path to the configuration file (JSON)")
    parser.add_argument("metadata_csv", help="Path to the metadata CSV file with i7 and i5 indices")
    args = parser.parse_args()

    with open(args.config_file, 'r') as file:
        config = json.load(file)
    perform_quality_check(config['fastqc_input_dir'], config['fastqc_output_dir'])
    trim_reads(config['cutadapt_input_dir'], config['cutadapt_output_dir'], args.metadata_csv)

