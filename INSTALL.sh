#!/bin/bash
# Install minionseq requirements
echo ">> minion-seq requirements <<" && echo ""
# Guppy
if [ -z "$(which guppy_basecaller)" ]
then
  echo "Downloading Guppy..."
  curl https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_3.2.2_linux64.tar.gz --output $HOME/softwares/ont-guppy-cpu.tar.gz
  echo "Installing Guppy..."
  cd $HOME/softwares/ && tar -vzxf ont-guppy-cpu.tar.gz && rm -rf ont-guppy-cpu.tar.gz
  echo "export PATH="$HOME/softwares/ont-guppy-cpu/bin:/usr/local/share/rsi/idl/bin:$PATH"" >> $HOME/.bashrc
  echo "Successfully installed Guppy!" && echo ""
else
  echo "Guppy already installed!" && echo ""
fi
# Miniconda
if [ -z "$(which conda)" ]
then
  echo "Downloading Miniconda..."
  curl https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh --output $HOME/softwares/miniconda.sh
  echo "Installing Miniconda..."
  bash $HOME/softwares/miniconda.sh -bfp $HOME/softwares/miniconda && rm --recursive --force $HOME/softwares/miniconda.sh
  echo "export PATH="$HOME/softwares/miniconda/bin:/usr/local/share/rsi/idl/bin:$PATH""
  echo "export PATH="$HOME/softwares/miniconda/bin:/usr/local/share/rsi/idl/bin:$PATH"" >> $HOME/.bashrc
  echo "Successfully installed Miniconda!" && echo ""
else
  echo "Miniconda already installed!" && echo ""
fi
# Update conda
echo "Updating conda..."
conda update --name base --channel defaults conda --yes
# Create conda environment: minion-seq
echo "Creating "minion-seq" environment..."
conda create --name minion-seq --yes
echo "Installing packages in minion-seq..."
conda install --name minion-seq --channel anaconda biopython drmaa pycoqc --yes
conda install --name minion-seq --channel bioconda bwa fastx-toolkit nanopolish porechop pysam r-minionqc snakemake samtools vcftools --yes
conda install --name minion-seq --channel conda-forge boto boto3 ipython libiconv ncurses numpy pandas psutil python pyvcf r-optparse --yes
conda install --name minion-seq --channel omgarcia gcc-6 --yes
conda install --name minion-seq --channel r r r-reshape r-reshape2 --yes
echo "" && echo "Done!"
