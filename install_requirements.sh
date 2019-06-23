#!/bin/bash

# Install minionSeq requirements
echo "Installing minionSeq requirements"

# Install Guppy

if [[ -z "$(which guppy_basecaller)" ]]
then
  echo "Installing Guppy"
  sudo apt-get update
  sudo apt-get install wget lsb-release git
  sudo apt-get install -f
  export PLATFORM=$(lsb_release -cs)
  wget -O- https://mirror.oxfordnanoportal.com/apt/ont-repo.pub | sudo apt-key add - 
  echo "deb http://mirror.oxfordnanoportal.com/apt ${PLATFORM}-stable non-free" | sudo tee /etc/apt/sources.list.d/nanoporetech.sources.list
  sudo apt-get update
  apt-get install ont-guppy
  apt-get install ont-guppy-cpu
  if [[ -z "$(which guppy_basecaller)" ]]
  then
    echo "Successfully installed Guppy"
  else
    echo "Error installing Guppy: skipping for now"
  fi
else
  echo "Guppy already installed"
fi

# Install Nanopolish

if [[ -z "$(which nanopolish)" ]]
then
  echo "Installing Nanopolish"
  cd ~/softwares/ && git clone --recursive https://github.com/jts/nanopolish.git && cd nanopolish && make
  export PATH=~/softwares/nanopolish:$PATH
  if [[ -z "$(which nanopolish)" ]]
  then
    echo "Successfully installed Nanopolish"
  else
    echo "Error installing Nanopolish: skipping for now"
  fi
else
  echo "Nanopolish already installed"
fi

# Install Miniconda3

if [[ -z "$(which conda)" ]]
then
  echo "Installing Miniconda3"
  CONDA_SCRIPT=Miniconda3-latest-Linux-x86_64.sh
  CONDA_DIR=$HOME/softwares/miniconda3
  wget https://repo.continuum.io/miniconda/$CONDA_SCRIPT
  bash $CONDA_SCRIPT -b -p $CONDA_DIR
  CONDA_BIN_DIR=$CONDA_DIR/bin
  export PATH=$CONDA_BIN_DIR:$PATH
  rm -rf $CONDA_SCRIPT
  export PATH=~/softwares/miniconda3/bin:$PATH
  if [[ -z "$(which conda)" ]]
  then
    echo "Successfully installed Miniconda3"
  else
    echo "Error installing Miniconda3: skipping for now"
  fi
else
  echo "Miniconda3 already installed"
fi

# Environment in which Snakemake will be run

echo "Installing conda environment: minion-seq"
export PATH=~/softwares/miniconda3/bin:$PATH
conda env create -f ~/softwares/minionSeq/envs/anaconda.snakemake-env.yaml
echo "Installing conda environment: minoin-seq_pipeline"
export PATH=~/softwares/miniconda3/bin:$PATH
conda env create -f ~/softwares/minionSeq/envs/anaconda.pipeline-env.yaml

# Snakemake problems

echo "To solving instalation problems of the Snakemake"

export PATH=~/softwares/nanopolish:$PATH
export PATH=~/softwares/miniconda3/bin:$PATH
source activate minion-seq
conda install -c anaconda python=3.7
conda install -c bioconda -c conda-forge snakemake
conda env update --file envs/anaconda.snakemake-env.yaml

echo "Done!"
