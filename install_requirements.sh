#!/bin/bash

# Install minionSeq requirements

echo "Installing minionSeq requirements"

# Install Guppy

echo "Installing Guppy"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y wget apt-transport-https git libboost-all-dev python3-setuptools lsb-release libhdf5-cpp
sudo apt-get install -f
export PLATFORM=$(lsb_release -cs)
wget -O- https://mirror.oxfordnanoportal.com/apt/ont-repo.pub | sudo apt-key add -
echo "deb http://mirror.oxfordnanoportal.com/apt ${PLATFORM}-stable non-free" | sudo tee /etc/apt/sources.list.d/nanoporetech.sources.list
sudo apt-get update
sudo apt-get install -y ont-guppy[-cpu]
sudo apt-get install -f
sudo apt-get update

if [ -z "$(which guppy_basecaller)" ]
then
  echo "Error installing Guppy: skipping for now"
else
  echo "Successfully installed Guppy"
fi

# Install Nanopolish

echo "Installing Nanopolish"
cd /$HOME/softwares/ && git clone --recursive https://github.com/jts/nanopolish.git && cd nanopolish && make
export PATH=$PATH:/$HOME/softwares/nanopolish
if [ -z "$(which nanopolish)" ]
then
  echo "Error installing Nanopolish: skipping for now"
else
  echo "Successfully installed Nanopolish"
fi

# Install Miniconda3

echo "Installing Miniconda3"
CONDA_SCRIPT=Miniconda3-latest-Linux-x86_64.sh
CONDA_DIR=/$HOME/softwares/miniconda3
wget https://repo.continuum.io/miniconda/$CONDA_SCRIPT
bash $CONDA_SCRIPT -b -p $CONDA_DIR
CONDA_BIN_DIR=$CONDA_DIR/bin
export PATH=$PATH:$CONDA_BIN_DIR
rm -rf $CONDA_SCRIPT
export PATH=/$PATH:/$HOME/softwares/miniconda3/bin
if [ -z "$(which conda)" ]
then
  echo "Error installing Miniconda3: skipping for now"
else
  echo "Successfully installed Miniconda3"
fi

# Environment in which Snakemake will be run

echo "Installing conda environment: minion-seq"
conda env create -f /$HOME/softwares/minionSeq/envs/anaconda.snakemake-env.yaml
echo "Installing conda environment: minoin-seq_pipeline"
conda env create -f /$HOME/softwares/minionSeq/envs/anaconda.pipeline-env.yaml
echo "To solving instalation problems of the Snakemake"

#export PATH=$PATH:/$HOME/softwares/nanopolish
#export PATH=$PATH:/$HOME/softwares/miniconda3/bin
#source activate minion-seq
#conda install -c anaconda python=3.7
#conda install -c bioconda -c conda-forge snakemake
#conda env update -f /$HOME/softwares/minionSeq/envs/anaconda.snakemake-env.yaml

echo "Done!"
