import subprocess
import glob
import json
import logging
from argparse import ArgumentParser

# Configure logging
logging.basicConfig(level=logging.INFO)

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

def perform_quality_check(config):
    """Runs FastQC on specified FASTQ.GZ files."""
    fastq_files = glob.glob(f"{config['fastqc_input_dir']}/**/*fastq.gz", recursive=True)
    for file in fastq_files:
        logging.info(f"Running FastQC on {file}...")
        subprocess.run(['fastqc', file, '-o', config['fastqc_output_dir']])
    logging.info("All FastQC analyses are complete.")

def trim_reads(config):
    """Trims reads using Cutadapt."""
    fastq_files = glob.glob(f"{config['cutadapt_input_dir']}/**/*.fastq.gz", recursive=True)
    for file in fastq_files:
        output_file = f"{config['cutadapt_output_dir']}/{file.split('/')[-1].replace('.fastq.gz', '_trimmed.fastq.gz')}"
        logging.info(f"Trimming {file}...")
        subprocess.run([
            'cutadapt',
            '-a', config['illumina_adapter'],
            '-a', config['solid_adapter'],
            '-q', config['quality_cutoff'],
            '-m', config['minimum_length'],
            '-o', output_file,
            file
        ])
    logging.info("Trimming complete.")

def index_and_align_reads(config):
    """Indexes and aligns reads using BWA-MEM2."""
    index_reference_genome(config['reference_genome'], config['bwa_mem2_path'])
    align_reads(config['reference_genome'], config['reads'], config['is_paired'], config['thread_count'], config['bwa_mem2_path'])

def index_reference_genome(reference_genome, bwa_mem2_path):
    """Indexes the reference genome using BWA-MEM2."""
    logging.info("Indexing the reference genome using BWA-MEM2...")
    bwa_index_command = [bwa_mem2_path, "index", reference_genome]
    run_command(bwa_index_command)
    logging.info("Indexing completed.")

def align_reads(reference_genome, reads, is_paired, thread_count, bwa_mem2_path):
    """Aligns reads to the reference genome using BWA-MEM2."""
    logging.info("Aligning reads to the reference genome...")
    bwa_mem_command = [bwa_mem2_path, "mem", "-t", str(thread_count), reference_genome] + reads
    output_file = "aligned_reads.sam"
    bwa_mem_command = ' '.join(bwa_mem_command) + f" > {output_file}"
    run_command(bwa_mem_command)
    logging.info("Alignment completed. Output saved to %s", output_file)

def main(config_file):
    with open(config_file, 'r') as file:
        config = json.load(file)

    perform_quality_check(config)
    trim_reads(config)
    index_and_align_reads(config)

if __name__ == "__main__":
    parser = ArgumentParser(description="Run genomics preprocessing and analysis pipeline.")
    parser.add_argument("config_file", help="Path to the configuration file")
    args = parser.parse_args()
    main(args.config_file)
