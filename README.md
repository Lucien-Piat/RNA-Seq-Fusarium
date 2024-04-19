# Genomics Data Preprocessing and Alignment Pipeline

This pipeline performs quality checks, trimming of reads, indexing of reference genomes, and alignment of reads using BWA-MEM2. The pipeline is controlled by a JSON configuration file, making it flexible and adaptable to various datasets and analysis requirements.

## Getting Started

These instructions will guide you through the setup and execution of the genomics data preprocessing and alignment pipeline.

### Prerequisites

- Python 3
- BWA-MEM2
- FastQC
- Cutadapt
- A valid JSON configuration file

### Installation

Ensure that all the required tools (BWA-MEM2, FastQC, Cutadapt) are installed and accessible in your system's PATH. This script assumes that these tools are already installed and configured correctly.

### Configuration

The pipeline is configured using a JSON file which specifies paths to input data, output directories, and parameters for read trimming and alignment. An example configuration file is provided below:

```json
{
    "bwa_mem2_path": "/path/to/bwa-mem2",
    "reference_genome": "/path/to/reference_genome.fasta",
    "reads": ["/path/to/read1.fastq.gz", "/path/to/read2.fastq.gz"],
    "is_paired": false,
    "thread_count": 1,
    "fastqc_input_dir": "/path/to/your/folders/for/fastqc",
    "fastqc_output_dir": "/path/to/output/directory/for/fastqc",
    "cutadapt_input_dir": "/path/to/your/folders/for/cutadapt",
    "cutadapt_output_dir": "/path/to/your/trimmed_fastq_files",
    "illumina_adapter": "AGATCGGAAGAGCACACGTCTGAACTCCAGTCA",
    "solid_adapter": "CCACTACGCCTCCGCTTTCCTCTCTATGGGCAGTCGGTGAT",
    "quality_cutoff": "20",
    "minimum_length": "20"
}
```
### Usage:
```bash
python script.py /path/to/config.json
```
