# RNA-Seq Analysis Pipeline

This repository contains a set of scripts and configurations to run an RNA-Seq analysis pipeline. The pipeline processes RNA-Seq data through various stages, including quality control, trimming, alignment, feature counting, and differential expression analysis. Each step is configured using a JSON configuration file.

## Getting Started

These instructions will guide you through the setup and execution of the genomics data preprocessing and alignment pipeline.

### Prerequisites

- FastQC: A tool for quality control.
- Cutadapt: A tool for removing adapter sequences from high-throughput sequencing reads.
- BWA-MEM2: An updated version of the BWA aligner.
- SAMtools: Tools for manipulating alignments in the SAM format.
- ShortStack: A tool for the analysis of small RNA-seq data.
- featureCounts: A program for counting reads to genomic features.
- Cuffdiff: Part of the Cufflinks suite for analyzing RNA-Seq data.
- jq: A lightweight and flexible command-line JSON processor.
- A valid JSON configuration file
- Python 3
- Conda (for managing environments)
- Operating System: Linux (scripts may require modifications for other OS)

### Installation and Usage

- Clone the repository to your local machine.
- Install the required software and dependencies.
- Update the configuration.json file with appropriate paths and settings.
- Execute pipeline_manager.py to run the pipeline interactively.

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
        "input_dir": "./dataset",
        "output_dir": "./fastqc_output"
      }
    },
    {
      "name": "trimming.sh",
      "description": "Trims adapters from RNA-seq reads using Cutadapt.",
      "path_order": ["INPUT_DIR", "OUTPUT_DIR"],
      "paths": {
        "INPUT_DIR": "./dataset",
        "OUTPUT_DIR": "./trimming_output"
      }
    },
    {
      "name": "alignement.sh",
      "description": "Aligns RNA-seq reads using BWA-MEM2 against reference genomes.",
      "path_order": ["TRIMMED_OUTPUT_DIR", "GENOME_DIR", "OUTPUT_DIR"],
      "paths": {
        "TRIMMED_OUTPUT_DIR": "./trimming_output",
        "GENOME_DIR": "./genomes",
        "OUTPUT_DIR": "./alignment_output"
      }
    },
    {
      "name": "samtools.sh",
      "description": "Converts, sorts, indexes SAM files, and generates idxstats.",
      "path_order": ["input_dir", "output_dir"],
      "paths": {
        "input_dir": "./alignment_output",
        "output_dir": "./samtools_output"
      }
    }
```
### Usage:
```bash
python3 pipeline_manager.py
```
```bash
./cuffdiff.sh
```
```bash
Rscript result_postprocessing.r /path/to/your/file.diff
```
Example : 
```bash
Rscript result_postprocessing.r ./output_genome1/C9/gene_exp.diff
```
