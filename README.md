# Bioinformatic pipeline for genome sequencing using MinION

#### Laise de Moraes<sup>1</sup>, Felipe Torres<sup>1</sup>, Luciane Amorim<sup>1,2</sup>, Ricardo Khouri<sup>1,2,3</sup>

###### <sup>1</sup>Laboratório de Enfermidades Infecciosas Transmitidas por Vetores, Instituto Gonçalo Moniz, Fundação Oswaldo Cruz, Salvador Bahia, Brasil; <sup>2</sup>Faculdade de Medicina da Bahia, Universidade Federal da Bahia, Salvador, Brasil; <sup>3</sup>KU Leuven, Department of Microbiology and Immunology, Rega Institute for Medical Research, Laboratory of Clinical and Epidemiological Virology, Leuven, Belgium.

This repo contains scripts and files to run the bioinformatic analysis of genome sequencing using MinION, and was built based on "[Experimental protocols and bioinformatic pipelines for Zika genome sequencing](https://github.com/blab/zika-seq)" of [Bedford Lab](https://bedford.io/projects/zika-seq).

---

## Setting up and running the pipeline

1. Download and install the pipeline from the github repo:
```sh
git clone https://github.com/lpmor22/minionSeq.git
cd minionSeq
```
```sh
sh ./install_requeriments.sh
```
Note: If fails, you may need to run `chmod 700` before rerunning.

---

2. Input `reference genome` for the pipeline in the refs directory: ``minionSeq/pipeline/refs/``

---

3. Input `primer scheme` for the pipeline in the metadata directory: ``minionSeq/pipeline/metadata/``

### `primer-scheme.bed`

Must be `bed` formatted. Keyed off of column headers rather than column order.

| pubmed_id | start_sequence | end_sequence | primer_name        | sense_strand |
| ----------| -------------- | ------------ | ------------------ | ------------ |
| KP164568  | 115            | 137          | CHIK_400_1_FORWARD | +            |
| KP164568  | 428            | 451          | CHIK_400_1_REVERSE | -            

---

4. Input `sample metadata` for the pipeline in the samples directory: ``minionSeq/samples/``
    - ``samples.tsv`` - line list of sample metadata
    - ``runs.tsv`` - line list of run metadata

### `samples.tsv`

Must be `tsv` formatted. Keyed off of column headers rather than column order.

| sample_id | strain             | collection_date | country | division  | location  | usvi_sample_id      | seq_platform |
| --------- | ------------------ | --------------- | ------- | --------- | --------- | ------------------- | ------------ |
| ID0001    | Zika Vírus         | 2019-05-03      | Brazil  | Bahia     | Salvador  | Plasma              | minion       |
| ID0002    | Zika Vírus         | 2019-05-03      | Brazil  | Bahia     | Salvador  | Whole Blood         | minion       |
| ID0003    | Zika Vírus         | 2019-05-03      | Brazil  | Bahia     | Salvador  | Urine               | minion       |
| ID0004    | Chikungunya Vírus  | 2019-05-03      | Brazil  | Bahia     | Salvador  | Plasma              | minion       |
| ID0005    | Chikungunya Vírus  | 2019-05-03      | Brazil  | Bahia     | Salvador  | Whole Blood         | minion       |
| NTC       | NTC                | 2019-05-03      | Brazil  | Bahia     | Salvador  | No Template Control | minion       |

### `runs.tsv`

Must be `tsv` formatted. Keyed off of column headers rather than column order.

| run_name            | barcode_id | sample_id    | primer_scheme |
| ------------------- | ---------- | ------------ | ------------- |
| library1-2019-05-03 | BC01       | ID0001       | primer_scheme |
| library1-2019-05-03 | BC02       | ID0001       | primer_scheme |
| library1-2019-05-03 | BC03       | ID0002       | primer_scheme |
| library1-2019-05-03 | BC04       | ID0002       | primer_scheme |
| library1-2019-05-03 | BC05       | ID0003       | primer_scheme |
| library1-2019-05-03 | BC06       | ID0003       | primer_scheme |
| library1-2019-05-03 | BC07       | ID0004       | primer_scheme |
| library1-2019-05-03 | BC08       | ID0004       | primer_scheme |
| library1-2019-05-03 | BC09       | ID0005       | primer_scheme |
| library1-2019-05-03 | BC10       | ID0005       | primer_scheme |
| library1-2019-05-03 | BC11       | NTC          | primer_scheme |
| library1-2019-05-03 | BC12       | NTC          | primer_scheme |

---

5. Open ``minionSeq/cfg.py`` and change config information as apropriate:
* ``raw_reads`` : directory containing un-basecalled ``.fast5`` numbered directories (``minionSeq/data``)
* ``dimension`` : sequencing dimension (1d or 2d)
* ``demux_dir`` : path to directory where demultiplexing will take place
* ``build_dir`` : path to output location (``minionSeq/build``)
* ``samples`` : list of all samples that are included for the library that will be processed
* ``guppy_config`` : name of the config file to be used during basecalling by Guppy (``guppy_basecaller --print_workflows``)
* ``prefix`` : prefix to prepend onto output consensus genome filenames
* ``ref_genome`` : reference genome for alignment (``minionSeq/pipeline/refs``)
* ``primer_scheme`` : primer scheme used in sequencing (``minionSeq/pipeline/metadata``)

---

6. Run the pipeline:

  ```sh
  source activate minion-seq
  snakemake --use-conda
  ```

---

#### Tips

* If the computer is shutdown or the snakemake process is "finished", the files are not deleted. However, snakemake creates a hidden metadata file with execution information. Then, to restart the snakemake process from the stop point, you can use ``snakemake --use-conda --rerun-incomplete``.

* If you had a single sample that failed, rather than re-running the pipeline on all the samples again, change the config file so that the pipeline will *only run on the single* failed sample.

---

#### Inside the pipeline...

When Guppy basecalls the raw `fast5` reads, it makes a workspace directory, which then contains a `pass` and a `fail` directory. Both the `pass` and the `fail` directory contain fastq files. The `fastq` in the pass directory contains the high quality reads (Q score >= 7), and the pipeline only uses this `fastq` files.

The basecalled `fastq` files serves as input to porechop, the program which performs barcode demultiplexing. Porechop writes a single `fastq` file for each barcode to the `demux` directory you created.

Next we run `pipeline.py`, which is a large script that references other custom python scripts and shell scripts to do run every other step of the pipeline. This is what is occurring in `pipeline.py`.

1.  Map sample IDs and run information that is contained in the `samples.tsv` and the `runs.tsv` files. This allows us to know which sample IDs are linked to which barcodes and primers etc.

2. Convert demuxed `fastq` files to `fasta` files. (If you look in the `demux` directory after a pipeline run you'll see both file types present for each barcode).

3. Using the linked sample and run information, combine the two barcode `fastq` or `fasta` files that represent pool 1 and pool 2 of the same sample. The pool-combined files are written as `<sample ID>.fasta` and `<sample ID>.fastq` to the `build` directory you made previously.

4. Map the reads in `<sample ID>.fasta` to a reference sequence using `bwa-mem`, and pipe to `samtools` to get a sorted bam file. Output files are labeled `<sample ID>.sorted.bam`.

5. Trim primer sequences out of the bam file using the custom script `align_trim.py`. Output files are labeled `<sample ID>.trimmed.sorted.bam`.

6. Use nanopolish to call SNPs more accurately. This is a two step process. First step is using `nanopolish index` to create a map of how basecalled reads in `<sample ID>.fastq` are linked to the raw reads (signal level data). This step takes a while since for every sample all the program needs to iterate through all the raw reads.  Next, `nanopolish variants` will walk through the indexed `fastq` and a reference file, determine which SNPs are real given the signal level data, and write true SNPs to a VCF file.

7. Run `margin_cons.py` to walk through the reference sequence, the trimmed bam file, and the VCF file. This script looks at read coverage at a site, masking the sequence with 'N' if the read depth is below a hardcoded threshold (we use a threshold of 20 reads). If a site has sufficient coverage to call the base, either the reference base or the variant base (as recorded in the VCF) is written to the consensus sequence. Consensus sequences are written to `<sample ID>_complete.fasta`. The proportion of the genome that has over 20x coverage and over 40x coverage is logged to `<sample_ID>-log.txt`.

---

### Full usage

* align_trim.py
```sh
usage: align_trim.py [-h] [--normalise NORMALISE] [--report REPORT] [--start] 
                     [--verbose]
                     bedfile

Trim alignments from an amplicon scheme.

positional arguments:
  bedfile               BED file containing the amplicon scheme

optional arguments:
  -h, --help            show this help message and exit
  --normalise NORMALISE Subsample to n coverage
  --report REPORT       Output report to file
  --start               Trim to start of primers instead of ends
  --verbose             Debug mode
  ```
* depth_process.py
```sh
usage: depth_process.py [-h] [-d DIRECTORY]

optional arguments:
  -h, --help            show this help message and exit
  -d DIRECTORY, --directory DIRECTORY
                        Global path to directory of native barcode base-called
                        .fast5's
```
* get-alignment.py
```sh
usage: get-alignment.py [-h] [--minfreq MINFREQ]

Process some integers.

optional arguments:
  -h, --help         show this help message and exit
  --minfreq MINFREQ  an integer for the accumulator
  ```
  * pipeline.py
  ```sh
  usage: pipeline.py [-h] [--data_dir DATA_DIR] [--samples_dir SAMPLES_DIR]
                   [--build_dir BUILD_DIR] [--prefix PREFIX]
                   [--samples [SAMPLES [SAMPLES ...]]] [--dimension DIMENSION]
                   [--run_steps [RUN_STEPS [RUN_STEPS ...]]]
                   [--raw_reads RAW_READS]
                   [--basecalled_reads BASECALLED_READS]
                   [--reference_genome REFERENCE_GENOME]
                   [--primer_scheme PRIMER_SCHEME]

Bioinformatic pipeline for generating consensus genomes from demultiplexed
fastas

optional arguments:
  -h, --help            show this help message and exit
  --data_dir DATA_DIR   directory containing data; default is 'data/'
  --samples_dir SAMPLES_DIR
                        directory containing samples and runs TSVs; default is
                        'samples/'
  --build_dir BUILD_DIR
                        directory for output data; default is 'build/'
  --prefix PREFIX       string to be prepended onto all output consensus
                        genome files; default is 'LIB'
  --samples [SAMPLES [SAMPLES ...]]
                        sample to be run
  --dimension DIMENSION
                        dimension of library to be fun; options are '1d' or
                        '2d', default is '2d'
  --run_steps [RUN_STEPS [RUN_STEPS ...]]
                        Numbered steps that should be run (i.e. 1 2 3): 1.
                        Construct sample fastas 2. Construct sample fastqs 3.
                        Process sample fastas 4. Gather consensus fastas 5.
                        Generate overlap graphs 6. Calculate per-base error
                        rates
  --raw_reads RAW_READS
                        directory containing raw .fast5 reads
  --basecalled_reads BASECALLED_READS
                        directory containing basecalled reads
  --reference_genome REFERENCE_GENOME
                        genome reference for alignment
  --primer_scheme PRIMER_SCHEME
                        primer scheme of minion sequencing
```
