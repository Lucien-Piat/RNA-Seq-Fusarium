import subprocess
import glob

#Quality Chec

# Define the paths to your input and output directories
input_dir = '/path/to/your/folders'
output_dir = '/path/to/output/directory'

# Use glob.glob to find all .fastq.gz files in the input directory and its subdirectories
fastq_files = glob.glob(f'{input_dir}/**/*fastq.gz', recursive=True)

# Loop through the list of FASTQ.GZ files and run FastQC on each one
for file in fastq_files:
    print(f'Running FastQC on {file}...')
    subprocess.run(['fastqc', file, '-o', output_dir])

print('All FastQC analyses are complete.')


#################################################################################

#Trimming

# Define your input and output directories
input_dir = '/path/to/your/folders'
output_dir = '/path/to/your/trimmed_fastq_files'
illumina_adapter = 'AGATCGGAAGAGCACACGTCTGAACTCCAGTCA'  # Illumina Universal Adapter
solid_adapter = 'CCACTACGCCTCCGCTTTCCTCTCTATGGGCAGTCGGTGAT'  # SOLiD Small RNA Adapter
quality_cutoff = '20'  # Quality score cutoff
minimum_length = '20'  # Minimum length of reads after trimming

# Find all .fastq.gz files in the input directory
fastq_files = glob.glob(f'{input_dir}/**/*.fastq.gz', recursive=True)

# Loop through the list of files and run Cutadapt for each
for file in fastq_files:
    output_file = f"{output_dir}/{file.split('/')[-1].replace('.fastq.gz', '_trimmed.fastq.gz')}"
    print(f'Trimming {file}...')
    subprocess.run([
        'cutadapt',
        '-a', illumina_adapter,  # Adapter sequence to trim for Illumina
        '-a', solid_adapter,  # Adapter sequence to trim for SOLiD
        '-q', quality_cutoff,  # Quality cutoff
        '-m', minimum_length,  # Minimum length
        '-o', output_file,  # Output file
        file  # Input file
    ])

print('Trimming complete.')
