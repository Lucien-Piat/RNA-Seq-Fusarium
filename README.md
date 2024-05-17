# Genomics Data Preprocessing and Alignment Pipeline

This repository contains a set of scripts and configurations to run an RNA-Seq analysis pipeline. The pipeline processes RNA-Seq data through various stages, including quality control, trimming, alignment, feature counting, and differential expression analysis. Each step is configured using a JSON configuration file.

## Getting Started

These instructions will guide you through the setup and execution of the genomics data preprocessing and alignment pipeline.

### Prerequisites

- Python 3
- jq: A lightweight and flexible command-line JSON processor.
- Cutadapt: A tool for removing adapter sequences from high-throughput sequencing reads.
- BWA-MEM2: An updated version of the BWA aligner.
- SAMtools: Tools for manipulating alignments in the SAM format.
- ShortStack: A tool for the analysis of small RNA-seq data.
- featureCounts: A program for counting reads to genomic features.
- Cuffdiff: Part of the Cufflinks suite for analyzing RNA-Seq data.
- A valid JSON configuration file

### Installation

Ensure that all the required tools are installed and accessible in your system's PATH. This script assumes that these tools are already installed and configured correctly.

### Configuration

The pipeline is configured using a JSON file which specifies paths to input data, output directories, and parameters for read trimming and alignment. An example configuration file is provided below:

```json
{
  "scripts": [
    {
      "name": "quality_control.sh",
      "description": "Runs FastQC on trimmed RNA-seq data.",
      "path_order": ["input_dir", "output_dir"],
      "paths": {
        "input_dir": "/mnt/c/Users/marwa/OneDrive/Desktop/new/RNA_seq/data",
        "output_dir": "/mnt/c/Users/marwa/OneDrive/Desktop/new/RNA_seq/fastqc_output"
      }
    },
    {
      "name": "trimming.sh",
      "description": "Trims adapters from RNA-seq reads using Cutadapt.",
      "path_order": ["INPUT_DIR", "OUTPUT_DIR"],
      "paths": {
        "INPUT_DIR": "/mnt/c/Users/marwa/OneDrive/Desktop/new/RNA_seq/data",
        "OUTPUT_DIR": "/mnt/c/Users/marwa/OneDrive/Desktop/new/RNA_seq/trimmed_1"
      }
    },
    {
      "name": "alignement.sh",
      "description": "Aligns RNA-seq reads using BWA-MEM2 against reference genomes.",
      "path_order": ["TRIMMED_OUTPUT_DIR", "GENOME_DIR", "OUTPUT_DIR"],
      "paths": {
        "TRIMMED_OUTPUT_DIR": "/mnt/c/Users/marwa/OneDrive/Desktop/new/RNA_seq/trimmed_1",
        "GENOME_DIR": "/mnt/c/Users/marwa/OneDrive/Desktop/new/RNA_seq/genomes",
        "OUTPUT_DIR": "/mnt/c/Users/marwa/OneDrive/Desktop/new/RNA_seq/alignment_output"
      }
    },
    {
      "name": "samtools.sh",
      "description": "Converts, sorts, indexes SAM files, and generates idxstats.",
      "path_order": ["input_dir", "output_dir"],
      "paths": {
        "input_dir": "/mnt/c/Users/marwa/OneDrive/Desktop/new/RNA_seq/alignment_output",
        "output_dir": "/mnt/c/Users/marwa/OneDrive/Desktop/new/RNA_seq/bam_files"
      }
    }
```
### Usage:
```bash
python manage.py 
```
```bach
./cuffdiff.sh
```

