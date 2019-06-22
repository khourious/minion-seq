#!/bin/bash

# Install minion-seq requirements

# Download and install miniconda
if [[ -z "$(which conda)" ]]
then
  echo "Installing miniconda"

  CONDA_SCRIPT=Miniconda3-latest-Linux-x86_64.sh

  CONDA_DIR=$HOME/softwares/miniconda3
  wget https://repo.continuum.io/miniconda/$CONDA_SCRIPT
  bash $CONDA_SCRIPT -b -p $CONDA_DIR -u

  CONDA_BIN_DIR=$CONDA_DIR/bin
  export PATH=$CONDA_BIN_DIR:$PATH

  rm -rf $CONDA_SCRIPT
  if [[ -z "$(which conda)" ]]
  then
    echo "Successfully installed Miniconda"
  else
    echo "Error installing Miniconda: skipping for now"
  fi
else
  echo "miniconda already installed"
fi

# Environment in which snakemake will be run
echo "Installing conda environment: minion-seq"
conda env create -f envs/anaconda.snakemake-env.yaml
echo "Installing conda environment: minoin-seq_pipeline"
conda env create -f envs/anaconda.pipeline-env.yaml

# Install Guppy
if [[ -z "$(which guppy_basecaller)" ]]
then
  echo "Installing Guppy"

  sudo apt-get update
  sudo apt-get install wget lsb-release
  export PLATFORM=$(lsb_release -cs)
  wget -O- https://mirror.oxfordnanoportal.com/apt/ont-repo.pub | sudo apt-key add - 
  echo "deb http://mirror.oxfordnanoportal.com/apt ${PLATFORM}-stable non-free" | sudo tee /etc/apt/sources.list.d/nanoporetech.sources.list
  sudo apt-get update
  apt-get install ont-guppy
else
  echo "Guppy already installed"
fi

# Install Nanopolish
if [[ -z "$(which nanopolish)" ]]
then
  cd && git clone --recursive https://github.com/jts/nanopolish.git && cd nanopolish && make
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

echo "Done!"

# To solving problems with Python 3.5 and Snakemake
# conda install python==3.7
# conda env ~/softwares/minionSeq/env/update anaconda.snakemake-env.yaml
