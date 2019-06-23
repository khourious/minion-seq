import time
import subprocess
from cfg import config
import os

DEMUX_DIR=config['demux_dir']
BASECALLED_READS=config['basecalled_reads']
RAW_READS = config['raw_reads']
BUILD_DIR = config['build_dir']

def get_minion_analysis():
    call = "find %s -name \"*.fast5\" | head -n 1" % (config['raw_reads'])
    fname = subprocess.check_output(call,shell=True)
    if type(fname) != str:
        fname = str(fname)[2:-3]
    fname = fname.replace(config['raw_reads'],"")[1:]
    return fname

GET_MINION_ANALYSIS=get_minion_analysis()

rule all:
    params:
        build=BUILD_DIR
    input:
        "%s" % (BUILD_DIR)

def _get_guppy_config(wildcards):
    return config["guppy_config"]

rule basecall:
    params:
        cfg=_get_guppy_config
    input:
        raw="%s" % (RAW_READS)
    output:
        directory("%s/pass" % (BASECALLED_READS))
    shell:
        "guppy_basecaller -i %s -c {params.cfg} -r --cpu_threads_per_caller 12 --qscore_filtering -s %s" % (RAW_READS, BASECALLED_READS)

def get_fastq_file():
    call = "find %s -name \"*.fast5\" | head -n 1" % (config['basecalled_reads']+"/pass")
    fname = subprocess.check_output(call,shell=True)
    if type(fname) != str:
        fname = str(fname)[2:-3]
    fname = fname.replace(config['basecalled_reads']+"/pass","")[1:]
    return fname
	
FASTQ=get_fastq_file()

rule demultiplex_full_fasta:
    input:
        "%s/pass" % (BASECALLED_READS)
    output:
        directory("%s" % (DEMUX_DIR))
    shell:
        "porechop -i %s/pass/%s -b %s --barcode_threshold 75 --threads 12 --check_reads 100000" % (BASECALLED_READS, FASTQ, DEMUX_DIR)

#

def _get_samples(wildcards):
    """ Build a string of all samples that will be processed in a pipeline.py run.
    """
    s = config['samples']
    samples = " ".join(s)
    return samples

rule pipeline:
    params:
        dimension=config['dimension'],
        samples=_get_samples,
        raw=config['raw_reads'],
        build=BUILD_DIR,
        basecalled_reads=config['basecalled_reads']
    input:
        "%s" % (DEMUX_DIR)
    output:
        directory("%s" % (BUILD_DIR))
    conda:
        "envs/anaconda.pipeline-env.yaml"
    shell:
        "python pipeline/scripts/pipeline.py --samples {params.samples} --dimension {params.dimension} --raw_reads {params.raw} --build_dir {params.build} --basecalled_reads {params.basecalled_reads}"
