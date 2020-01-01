#!/bin/bash -x
set -e

ref=$1
sample=$2
amplicons=$3
raw=$4
basecalled_reads=$5

if [[ -z "$(which sbatch)" ]]
then
  CLUSTER=0
else
  CLUSTER=1
fi

# Takes a $sample.fasta file full of nanopolish reads, ie
# nanopolish extract --type 2d /data > $sample.fasta
# Files are written to working directory

# 1) index the ref & align with bwa
bwa index $ref
bwa mem $ref $sample.fasta -t 12 | samtools view --threads 12 -bS - | samtools sort --threads 12 -o $sample.sorted.bam -
samtools index $sample.sorted.bam

# 2) trim the alignments to the primer start sites and normalise the coverage to save time
python pipeline/scripts/align_trim.py --normalise 500 --start $amplicons --report $sample.alignreport.txt < $sample.sorted.bam 2> $sample.alignreport.er | samtools view --threads 12 -bS - | samtools sort --threads 12 -T $sample - -o $sample.trimmed.sorted.bam
# python pipeline/scripts/align_trim.py --normalise 100 $amplicons --report $sample.alignreport.txt < $sample.sorted.bam 2> $sample.alignreport.er | samtools view --threads 12 -bS - | samtools sort --threads 12 -T $sample - -o $sample.primertrimmed.sorted.bam
samtools index $sample.trimmed.sorted.bam
# samtools index $sample.primertrimmed.sorted.bam

# 3) do variant calling using the raw signal alignment
if [[ "${CLUSTER}" -eq "1" ]]
then
  nanopolish/nanopolish variants --progress -t 12 --reads $sample.fasta -o $sample.vcf -b $sample.trimmed.sorted.bam -g $ref -vv -w "`pipeline/scripts/nanopolish_header.py $ref`" --snps --ploidy 1
else
  #source activate minion-seq &> /dev/null
  nanopolish index -d $raw -s $basecalled_reads/sequencing_summary.txt $sample.fastq
  #nanopolish index -d $raw -s $sample.fastq
  nanopolish variants --progress -t 12 --reads $sample.fastq -o $sample.vcf -b $sample.trimmed.sorted.bam -g $ref -vv -w "`pipeline/scripts/nanopolish_header.py $ref`" --snps --ploidy 1
  source activate minion-seq &> /dev/null

fi

# 4) filter the variants and produce a consensus
python pipeline/scripts/margin_cons.py $ref $sample.vcf $sample.trimmed.sorted.bam a > $sample.consensus.fasta
