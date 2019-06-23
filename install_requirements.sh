#!/bin/bash

# Install minion-seq requirements

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
else
  echo "Guppy already installed"
fi

# Install Nanopolish

if [[ -z "$(which nanopolish)" ]]
then
  cd .. && git clone --recursive https://github.com/jts/nanopolish.git && cd nanopolish && make
  export $PATH=$PATH:~/softwares/nanopolish/
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
conda env create -f envs/anaconda.snakemake-env.yaml
echo "Installing conda environment: minoin-seq_pipeline"
conda env create -f envs/anaconda.pipeline-env.yaml

# To solving problems with Python 3.5 and Snakemake

echo "Installing Python 3.7"
conda install -c anaconda python=3.7
echo "Installing Snakemake"
conda install -c bioconda -c conda-forge snakemake
echo "Update minion-seq"
conda env update -f envs/anaconda.snakemake-env.yaml

# To active minion-seq environment

#export PATH=$PATH:~/softwares/nanopolish
#export PATH=$PATH:~/softwares/miniconda3/bin
#source activate minion-seq
#echo "Installing Python 3.7"
#conda install -c anaconda python=3.7
#echo "Installing Snakemake"
#conda install -c bioconda -c conda-forge snakemake
#echo "Update minion-seq"
#conda env update --file envs/anaconda.snakemake-env.yaml

echo "Done!"
