#!/bin/bash

# Install minionSeq requirements

echo "Installing minionSeq requirements"

# Install Guppy v3.2.1
if [ -z "$(which $HOME/softwares/ont-guppy-cpu/bin/guppy_basecaller)" ]
then
  echo "Installing Guppy v3.2.1"
  cd $HOME/softwares/
  wget https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_3.2.1_linux64.tar.gz
  tar -vzxf ont-guppy-cpu_3.2.1_linux64.tar.gz
  rm -rf ont-guppy-cpu_3.2.1_linux64.tar.gz
  echo "Successfully installed Guppy!"
else
  echo "Guppy already installed!"
fi

# Install Porechop v0.2.4
if [ -z "$(which $HOME/softwares/Porechop/porechop-runner.py)" ]
then
  echo "Installing Porechop v.0.2.4"
  cd $HOME/softwares/
  git clone --recursive https://github.com/rrwick/Porechop.git
  cd Porechop
  make
  echo "Successfully installed Porechop!"
else
  echo "Porechop already installed!"
fi

# Install Nanopolish v0.11.1
if [ -z "$(which $HOME/softwares/nanopolish/nanopolish)" ]
then
  echo "Installing Nanopolish v.0.11.1"
  cd $HOME/softwares
  git clone --recursive https://github.com/jts/nanopolish.git
  cd nanopolish
  make
  echo "Successfully installed Nanopolish!"
else
  echo "Nanopolish already installed!"
fi

# Install Miniconda v4.6.14
if [ -z "$(which $HOME/softwares/miniconda3/bin/conda)" ]
then
  echo "Installing Miniconda v.4.6.14"
  CONDA_SCRIPT=Miniconda3-latest-Linux-x86_64.sh
  CONDA_DIR=$HOME/softwares/miniconda3
  wget https://repo.continuum.io/miniconda/$CONDA_SCRIPT
  bash $CONDA_SCRIPT -b -p $CONDA_DIR
  CONDA_BIN_DIR=$CONDA_DIR/bin
  rm -rf $CONDA_SCRIPT
  echo "Successfully installed Miniconda!"
else
  echo "Miniconda already installed!"
fi

# chmod 777
  cd $HOME/softwares/
  chmod 777 -R ont-guppy-cpu/ Porechop/ nanopolish/ miniconda3/

# Environment in which Snakemake will be run
echo "Installing conda environment: minion-seq"
$HOME/softwares/miniconda3/bin/conda env create -f $HOME/softwares/minionSeq/envs/conda.snakemake-env.yaml
echo "Installing conda environment: minion-seq_pipeline"
$HOME/softwares/miniconda3/bin/conda env create -f $HOME/softwares/minionSeq/envs/conda.pipeline-env.yaml
echo "Updating Python 3.7"
$HOME/softwares/miniconda3/bin/conda install -c anaconda python=3.7
echo "Updating Snakemake 5.5"
$HOME/softwares/miniconda3/bin/conda install -c bioconda -c conda-forge snakemake=5.5

#source $HOME/softwares/miniconda3/bin/activate $HOME/softwares/minionSeq/.snakemake/conda
#$HOME/softwares/miniconda3/bin/conda install -c omgarcia gcc-6
#$HOME/softwares/miniconda3/bin/conda install libiconv
#$HOME/softwares/miniconda3/bin/conda install -c conda-forge ncurses
#$HOME/softwares/miniconda3/bin/conda install -c r r

echo "Done!"
