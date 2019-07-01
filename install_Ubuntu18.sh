#!/bin/bash

# Install minionSeq requirements

echo "Installing minionSeq requirements"

# Install Guppy

if [ -z "$(which guppy_basecaller)" ]
then
  echo "Installing Guppy"
  sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get install -y wget git apt-transport-https libboost-all-dev python3-setuptools lsb-release libhdf5-cpp && sudo apt-get install -f -y && sudo apt-get update -y && sudo apt-get ugrade -y
  cd $HOME/softwares/ && wget https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_3.1.5_linux64.tar.gz && tar -vzxf ont-guppy-cpu_3.1.5_linux64.tar.gz && rm -rf ont-guppy-cpu_3.1.5_linux64.tar.gz && mv ont-guppy-cpu/ guppy/ && sudo cp -r guppy/ /opt/ && sudo ln -s /opt/guppy/bin/guppy_* /usr/local/bin && sudo ln -s /opt/guppy/lib/libont* /usr/local/lib
  echo "Successfully installed Guppy"
else
  echo "Guppy already installed!"
fi

# Install Nanopolish

if [ -z "$(which nanopolish)" ]
then
  echo "Installing Nanopolish"
  cd $HOME/softwares/ && git clone --recursive https://github.com/jts/nanopolish.git && cd nanopolish && make
  echo "export PATH=$PATH:$HOME/softwares/nanopolish" >> $HOME/.bashrc && source $HOME/.bashrc
  echo "Successfully installed Nanopolish"
else
  echo "Nanopolish already installed!"
fi

# Install Miniconda3

if [ -z "$(which conda)" ]
then
  echo "Installing Miniconda3"
  CONDA_SCRIPT=Miniconda3-latest-Linux-x86_64.sh
  CONDA_DIR=$HOME/softwares/miniconda3
  wget https://repo.continuum.io/miniconda/$CONDA_SCRIPT
  bash $CONDA_SCRIPT -b -p $CONDA_DIR
  CONDA_BIN_DIR=$CONDA_DIR/bin
  echo "export PATH=$PATH:$CONDA_BIN_DIR" >> $HOME/.bashrc && source $HOME/.bashrc
  rm -rf $CONDA_SCRIPT
  echo "Successfully installed Miniconda3!"
else
  echo "Miniconda3 already installed!"
fi

# Environment in which Snakemake will be run

echo "Installing conda environment: minion-seq"
conda env create -f $HOME/softwares/minionSeq/envs/conda.snakemake-env.yaml
echo "Installing conda environment: minoin-seq_pipeline"
conda env create -f $HOME/softwares/minionSeq/envs/conda.pipeline-env.yaml
echo "Updating Python 3.7"
conda install -c anaconda python=3.7
echo "Updating Snakemake 5.5"
conda install -c bioconda -c conda-forge snakemake=5.5

echo "Done!"
