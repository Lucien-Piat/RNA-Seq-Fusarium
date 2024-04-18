import os
import subprocess

# Path to the BWA-MEM2 executable
bwa_mem2 = "/path/to/bwa-mem2"

# Directory containing the reference genomes
genome_dir = "/path/to/genomes"

# Directory containing the read files
reads_dir = "/path/to/reads"

# Output directory for SAM files
output_dir = "/path/to/output"

# List of reference genomes - adjust names as per your files
genomes = ["Fgraminearum_Genome.fasta", "Fverticillioides_Genome.fasta"]

# List of read files - adjust names as per your files
reads = ["reads1.fastq", "reads2.fastq", "reads3.fastq", "reads4.fastq", 
         "reads5.fastq", "reads6.fastq", "reads7.fastq", "reads8.fastq"]

# Ensure output directory exists
os.makedirs(output_dir, exist_ok=True)

# Loop through all genomes and reads
for genome in genomes:
    for read in reads:
        print(f"Aligning {read} to {genome}")
        genome_path = os.path.join(genome_dir, genome)
        read_path = os.path.join(reads_dir, read)
        output_path = os.path.join(output_dir, f"{genome}_{read}.sam")
        command = f"{bwa_mem2} mem {genome_path} {read_path} > {output_path}"
        subprocess.run(command, shell=True)
