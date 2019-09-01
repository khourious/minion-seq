#!/bin/bash
# Install minionseq requirements
echo ">> minion-seq requirements <<" && echo ""
# Guppy
if [ -z "$(which guppy_basecaller)" ]
then
  echo "Downloading Guppy..."
  curl https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_3.2.2_linux64.tar.gz --output $HOME/softwares/ont-guppy-cpu.tar.gz
  echo "Installing Guppy..."
  cd $HOME/softwares/ && tar -vzxf ont-guppy-cpu.tar.gz && mv ont-guppy-cpu/ guppy/ && rm -rf ont-guppy-cpu.tar.gz
  export PATH="$HOME/softwares/guppy/bin:/usr/local/share/rsi/idl/bin:$PATH"
  echo 'export PATH="$HOME/softwares/guppy/bin:/usr/local/share/rsi/idl/bin:$PATH"' >> $HOME/.bashrc
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
  bash $HOME/softwares/miniconda.sh -bfp $HOME/softwares/conda && rm --recursive --force $HOME/softwares/miniconda.sh
  export PATH="$HOME/softwares/conda/bin:/usr/local/share/rsi/idl/bin:$PATH"
  echo 'export PATH="$HOME/softwares/conda/bin:/usr/local/share/rsi/idl/bin:$PATH"' >> $HOME/.bashrc
  echo "Successfully installed Miniconda!" && echo ""
else
  echo "Miniconda already installed!" && echo ""
fi
# Updating conda
echo "Updating conda..."
conda update --yes --name base --channel defaults conda
# Create conda environment: minion-seq
echo "Creating "minion-seq" environment..."
conda create --yes --name minion-seq
echo "Installing packages in minion-seq..."
conda install --yes --name minion-seq --channel anaconda biopython drmaa pycoqc
conda install --yes --name minion-seq --channel biobuilds fastx-toolkit
conda install --yes --name minion-seq --channel bioconda bwa deepbinner nanopolish porechop pysam r-minionqc seqtk snakemake samtools vcftools
conda install --yes --name minion-seq --channel conda-forge boto boto3 ipython libiconv ncurses numpy pandas psutil python=3.6* pyvcf r-optparse tensorflow
conda install --yes --name minion-seq --channel r r r-reshape r-reshape2
echo "" && echo "Done!"
