#!/usr/bin/env python

import argparse, csv, subprocess, time
import sys
from Bio import SeqIO
import os

def sample_to_run_data_mapping(samples_dir):
    '''
    return dict
    each key is string "sample_id"
    each value is a list of tuples ("library", "barcode")
    '''
    runs_file = samples_dir + "runs.tsv"
    sr_mapping = {}
    with open(runs_file) as tsv:
        for row in csv.DictReader(tsv, delimiter="\t"):
            sample = row["sample_id"]
            rb_pair = (row["run_name"], row["barcode_id"])
            if sample not in sr_mapping:
                sr_mapping[sample] = []
            sr_mapping[sample].append(rb_pair)
    return sr_mapping

def sample_to_metadata_mapping(samples_dir):
    '''
    return dict
    each key is string "sample_id"
    each value is a list of metadata ordered as
    ["sample_id", "country", "division", "location", "collect_date"]
    '''
    metadata_file = samples_dir + "samples.tsv"
    sm_mapping = {}
    with open(metadata_file) as tsv:
        for row in csv.DictReader(tsv, delimiter="\t"):
            sample = row["sample_id"]
            metadata = row["sample_id"], row["country"], row["division"], row["location"], row["collection_date"]
            sm_mapping[sample] = metadata
    return sm_mapping

def fastq_to_fasta(sr_mapping, data_dir):
    '''Convert fastqs into fastas for input
    '''
    import re
    first = True

    for sample in sr_mapping:
        if first:
            run = sr_mapping[sample][0][0]
            fastqs = os.listdir('%s%s/demux_porechop/' % (data_dir, run))
            for fastq in fastqs:
                fasta = re.sub('q$', 'a', fastq)
                print("Converting %s to %s." % (fastq, fasta))
                call = "seqtk seq -A %s%s/demux_porechop/%s > %s%s/demux_porechop/%s" % (data_dir, run, fastq, data_dir, run, fasta)

                subprocess.call(call, shell=True)
            first = False

def construct_sample_fastas(sr_mapping, data_dir, build_dir):
    ''' Construct one fasta for each sample from two input fastas.
    '''
    import gzip
    for sample in sr_mapping:
        # Grab a matched pair of barcode fastas; global paths
        fastas = [ '%s%s/demux_porechop/%s.fasta' % (data_dir, run, barcode) for (run, barcode) in sr_mapping[sample] ]
        for fasta in fastas:
            if fasta.endswith('na.fasta'):
                fastas.remove(fasta)
                print('Removed 1 fasta ending in na.fasta')
        assert len(fastas) == 2, 'Expected 2 .fasta files for %s, instead found %s.\nCheck that they are present and gzipped in %s/demux_porechop/' % (sample, len(fastas), data_dir)
        complete_fasta = '%s%s_complete.fasta' % (build_dir, sample)
        with open(complete_fasta, 'w+') as f:
            with open(fastas[0], 'r') as f1:
                print('Writing %s to %s' % (fastas[0],complete_fasta))
                content = f1.read()
                f.write(content)
            with open(fastas[1], 'r') as f2:
                print('Writing %s to %s' % (fastas[1],complete_fasta))
                content = f2.read()
                f.write(content)

        final_fasta = '%s%s.fasta' % (build_dir, sample)
        with open(final_fasta, 'w+') as f:
            (run, barcode) = sr_mapping[sample][0]
            sed_str = '%s%s' % (data_dir, run)
            sed_str = sed_str.split('/')
            sed_str = '\/'.join(sed_str)
            call = 'sed \'s/\.\./%s/\' %s%s_complete.fasta' % (sed_str, build_dir, sample)
            print(" > ".join([call, final_fasta]))
            subprocess.call(call, shell=True, stdout=f)

def construct_sample_fastqs(sr_mapping, data_dir, build_dir):
    ''' Construct one fastq for each sample from two input fastqs.
    '''
    import gzip
    for sample in sr_mapping:
        # Grab a matched pair of barcode fastqs; global paths
        fastqs = [ '%s%s/demux_porechop/%s.fastq' % (data_dir, run, barcode) for (run, barcode) in sr_mapping[sample] ]
        for fastq in fastqs:
            if fastq.endswith('na.fastq'):
                fastqs.remove(fastq)
                print('Removed 1 fastq ending in na.fastq')
        print(fastqs)
        assert len(fastqs) == 2, 'Expected 2 .fastq files for %s, instead found %s.\nCheck that they are present and gzipped in %s%s/demux_porechop/' % (sample, len(fastqs), data_dir, sr_mapping[sample][0])
        complete_fastq = '%s%s.fastq' % (build_dir, sample)
        # complete_fastq = '%s%s_complete.fastq' % (build_dir, sample)
        with open(complete_fastq, 'w+') as f:
            with open(fastqs[0], 'r') as f1:
                print('Writing %s to %s' % (fastqs[0],complete_fastq))
                content = f1.read()
                f.write(content)
            with open(fastqs[1], 'r') as f2:
                print('Writing %s to %s' % (fastqs[1],complete_fastq))
                content = f2.read()
                f.write(content)

def process_sample_fastas(sm_mapping, build_dir, dimension, reference_genome, primer_scheme, raw_reads, basecalled_reads):
    ''' Run fasta_to_consensus script to construct consensus files.
    TODO: Make sure that this runs after changes to inputs and fasta_to_consensus on 1d reads
    '''
    for sample in sm_mapping:
        print("* Processing " + sample)
        sample_stem = build_dir + sample
        if dimension == '2d':
            call = ['pipeline/scripts/fasta_to_consensus_2d.sh', reference_genome, sample_stem, primer_scheme]
        elif dimension == '1d':
            call = ['pipeline/scripts/fasta_to_consensus_1d.sh', reference_genome, sample_stem, primer_scheme, raw_reads, basecalled_reads]
        print(" ".join(call))
        subprocess.call(" ".join(call), shell=True)
        print('#############\n')
        fasta_header = ">" + "_".join(sm_mapping[sample])
        replacement = r"\~^>~s~.*~" + fasta_header + "~"
        input_file = build_dir + sample + ".consensus.fasta"
        output_file = "temp.fasta"
        f = open(output_file, "w")
        call = ['sed', replacement, input_file]
        print(" ".join(call) + " > " + output_file)
        subprocess.call(call, stdout=f)
        call = ['mv', output_file, input_file]
        print(" ".join(call))
        subprocess.call(call)
        print("")

def gather_consensus_fastas(sm_mapping, build_dir):
    '''
    Gather consensus files into genomes with 'partial' (50-80 percent coverage)
    and good (>80 percent coverage) coverage
    '''
    print("* Concatenating consensus fastas")
    partial_samples = []
    good_samples = []
    poor_samples = []
    for sample in sm_mapping:
        consensus_file = build_dir + sample + ".consensus.fasta"
        with open(consensus_file) as f:
            lines = f.readlines()
        if len(lines) > 0:
            seq = lines[1]
            coverage = 1 - seq.count("N") / float(len(seq))
            print("N's in consensus: " + str(seq.count("N")))
            print("Total genome length: " + str(len(seq)))
            print("Non-N percentage: "+ str(coverage))
            if coverage >= 0.5 and coverage < 0.8:
                partial_samples.append(sample)
            elif coverage >= 0.8:
                good_samples.append(sample)
            else:
                poor_samples.append(sample)
        else:
            print("WARNING: {} does not contain a consensus genome.".format(consensus_file))
    partial_samples.sort()
    good_samples.sort()
    poor_samples.sort()
    print("Good samples: " + " ".join(good_samples))
    print("Partial samples: " + " ".join(partial_samples))
    print("Poor samples: " + " ".join(poor_samples))

def overlap(sr_mapping, build_dir):
    for sample in sr_mapping:
        bamfile = build_dir + sample + '.sorted.bam'
        coveragefile = build_dir + sample + '.coverage'
        with open(coveragefile, 'w+') as f:
            call = ['samtools', 'depth', bamfile]
            print(" ".join(call + ['>', coveragefile]))
            subprocess.call(call, stdout=f)

        chfile = build_dir + sample + '.chr1.coverage'
        with open(coveragefile, 'r') as f:
            f.readline()
            line = f.readline()
            l = line.split('\t')
            chromosome_name = l[0]
        call = "awk '$1 == \"" + chromosome_name + "\" {print $0}' " + coveragefile + " > " + chfile
        print(call)
        subprocess.call([call], shell=True)
        call = "Rscript pipeline/scripts/depth_coverage.R --inFile " + chfile + " --outPath " + build_dir + " --name " + sample
        print(call)
        subprocess.call([call], shell=True)
        print("")

def per_base_error_rate(sr_mapping, build_dir):
    '''
    Calculate per-base error rates by walking through VCF files for each sample.
    TODO: make this work
    '''
    length = 10794.0
    for sample in sr_mapping:
        error = 0
        vcf = build_dir + sample + '.vcf'
        if vcf in os.listdir(build_dir):
            with open(vcf) as f:
                lines = f.readlines()
                if len(lines) > 1:
                    for line in lines:
                        l = line.split('\t')
                        alt = len(l[4])
                        error += alt
            outfile = build_dir + sample + '.error'
            error = error / length
            with open(outfile, 'w+') as f:
                f.write('Error rate: ' + str(error))

if __name__=="__main__":
    parser = argparse.ArgumentParser( description = "Bioinformatic pipeline for generating consensus genomes from demultiplexed fastas" )
    parser.add_argument( '--data_dir', type = str, default = "data",
                            help="directory containing data; default is 'data/'" )
    parser.add_argument( '--samples_dir', type = str, default = "samples",
                            help="directory containing samples and runs TSVs; default is 'samples/'" )
    parser.add_argument( '--build_dir', type = str, default = "build",
                            help="directory for output data; default is 'build/'" )
    parser.add_argument( '--samples', type = str, default = None, nargs='*',
                            help="sample to be run" )
    parser.add_argument( '--dimension', type = str, default = '2d',
                            help="dimension of library to be fun; options are '1d' or '2d', default is '2d'" )
    parser.add_argument( '--run_steps', type = int, default = None, nargs='*',
                            help="Numbered steps that should be run (i.e. 1 2 3):\n\t1. Construct sample fastas\n\t2. Construct sample fastqs \n\t3. Process sample fastas \n\t4. Gather consensus fastas \n\t 5. Generate overlap graphs \n\t6. Calculate per-base error rates")
    parser.add_argument( '--raw_reads', type=str, default=None,
                            help="directory containing raw .fast5 reads" )
    parser.add_argument( '--basecalled_reads', type=str, default=None,
                            help="directory containing basecalled reads" )
    parser.add_argument( '--reference_genome', type = str,
                            help="genome reference for alignment" )
    parser.add_argument( '--primer_scheme', type = str,
                            help="primer scheme of minion sequencing" )
    params = parser.parse_args()

    assert params.dimension in [ '1d', '2d' ], "Unknown library dimension: options are '1d' or '2d'."
    assert params.raw_reads is not None, "Directory containing raw reads is required."
    assert params.basecalled_reads is not None, "Directory containing basecalled_reads reads is required."
    assert params.reference_genome is not '.fasta', "Unknown file for genome reference."
    assert params.primer_scheme is not '.bed', "Unknown file for primer scheme."


    dd = params.data_dir
    bd = params.build_dir
    sd = params.samples_dir

    if dd[-1] != '/':
        dd += '/'
    if bd[-1] != '/':
        bd += '/'
    if sd[-1] != '/':
        sd += '/'

    start_time = time.time()

    sr_mapping = sample_to_run_data_mapping(sd)
    sm_mapping = sample_to_metadata_mapping(sd)
    tmp_sr = { s: sr_mapping[s] for s in params.samples }
    tmp_sm = { s: sm_mapping[s] for s in params.samples }
    sr_mapping = tmp_sr
    sm_mapping = tmp_sm
    fastq_to_fasta(sr_mapping, dd)

    def csf():
        construct_sample_fastas(sr_mapping, dd, bd)
    def csfq():
        construct_sample_fastqs(sr_mapping, dd, bd)
    def psf():
        process_sample_fastas(sm_mapping, bd, params.dimension, params.reference_genome, params.primer_scheme, params.raw_reads, params.basecalled_reads)
    def gcf():
        gather_consensus_fastas(sm_mapping, bd)
    def go():
        overlap(sm_mapping, bd)
    def pber():
        per_base_error_rate(sr_mapping, bd)

    if params.run_steps is not None:
        print("Running steps {}.".format(", ".join(map(str,params.run_steps))))
        for index in params.run_steps:
            assert index in [1,2,3,4,5,6], 'Unknown step number %s, options are 1, 2, 3, 4, 5, or 6.' % (index)
    pipeline = [ csf, csfq, psf, gcf, go, pber ]
    if params.run_steps is None:
        for fxn in pipeline:
            fxn()
    else:
        for index in params.run_steps:
            pipeline[index-1]()

    time_elapsed = time.time() - start_time
    m, s = divmod(time_elapsed, 60)
    h, m = divmod(m, 60)
    print('Total runtime: %d:%02d:%02d' % (h, m, s))
