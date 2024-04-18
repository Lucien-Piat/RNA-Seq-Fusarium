import subprocess
import sys
import logging
from argparse import ArgumentParser

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

def index_reference_genome(reference_genome):
    """Indexes the reference genome using BWA-MEM2."""
    logging.info("Indexing the reference genome using BWA-MEM2...")
    bwa_index_command = ["./bwa-mem2", "index", reference_genome]
    run_command(bwa_index_command)
    logging.info("Indexing completed.")

def align_reads(reference_genome, reads, is_paired=False, thread_count=1):
    """Aligns reads to the reference genome using BWA-MEM2."""
    logging.info("Aligning reads to the reference genome...")
    bwa_mem_command = ["./bwa-mem2", "mem", "-t", str(thread_count), reference_genome] + reads
    output_file = "aligned_reads.sam"
    bwa_mem_command = ' '.join(bwa_mem_command) + f" > {output_file}"
    run_command(bwa_mem_command)
    logging.info("Alignment completed. Output saved to %s", output_file)

def main(reference_genome, reads, is_paired=False, thread_count=1):
    index_reference_genome(reference_genome)
    align_reads(reference_genome, reads, is_paired, thread_count)

if __name__ == "__main__":
    parser = ArgumentParser(description="Run genome indexing and alignment using BWA-MEM2")
    parser.add_argument("reference_genome", help="Path to the reference genome file")
    parser.add_argument("reads", nargs='+', help="Path to the reads file(s)")
    parser.add_argument("--is_paired", action='store_true', help="Flag to indicate paired-end reads")
    parser.add_argument("--threads", type=int, default=1, help="Number of threads to use")
    args = parser.parse_args()
    main(args.reference_genome, args.reads, args.is_paired, args.threads)
