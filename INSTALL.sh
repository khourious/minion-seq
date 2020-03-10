#!/bin/bash

# Install minion-seq requirements
echo ">> minion-seq requirements <<" && echo ""

# Install packages: curl git libdeflate-dev nanopolish r-base-core
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get install -y curl git libdeflate-dev nanopolish python3-distutils r-base-core && sudo apt-get autoremove && sudo apt-get clean && sudo apt-get check
echo "" && echo "Successfully installed packages!" && echo ""

# MinKNOW
echo "" && echo "Downloading MinKNOW..."
sudo apt-get update && wget -O- https://mirror.oxfordnanoportal.com/apt/ont-repo.pub | sudo apt-key add -
echo "deb http://mirror.oxfordnanoportal.com/apt bionic-stable non-free" | sudo tee /etc/apt/sources.list.d/nanoporetech.sources.list
echo "" && echo "Installing MinKNOW..."
sudo apt-get update && sudo apt-get install -y minion-nc
echo "" && echo "Successfully installed MinKNOW!" && echo ""

# Guppy
if [ -z "$(which guppy_basecaller)" ]
then
  echo "" && echo "Downloading Guppy..."
  curl https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_3.4.5_linux64.tar.gz -o $HOME/softwares/ont-guppy-cpu.tar.gz
  curl https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy_3.4.5_linux64.tar.gz -o $HOME/softwares/ont-guppy-gpu.tar.gz
  echo "" && echo "Installing Guppy..."
  cd $HOME/softwares/ && tar -vzxf ont-guppy-cpu.tar.gz && mv ont-guppy-cpu/ guppy-cpu/ && rm -rf ont-guppy-cpu.tar.gz
  cd $HOME/softwares/ && tar -vzxf ont-guppy-gpu.tar.gz && mv ont-guppy/ guppy-gpu/ && rm -rf ont-guppy-gpu.tar.gz
  export PATH="$HOME/softwares/guppy-cpu/bin:/usr/local/share/rsi/idl/bin:$PATH"
  export PATH="$HOME/softwares/guppy-gpu/bin:/usr/local/share/rsi/idl/bin:$PATH"
  echo 'export PATH="$HOME/softwares/guppy-cpu/bin:/usr/local/share/rsi/idl/bin:$PATH"' >> $HOME/.bashrc
  echo 'export PATH="$HOME/softwares/guppy-gpu/bin:/usr/local/share/rsi/idl/bin:$PATH"' >> $HOME/.bashrc
  echo "Successfully installed Guppy!" && echo ""
else
  echo "" && echo "Guppy already installed!" && echo ""
fi

# Porechop
if [ -z "$(which porechop)" ]
then
  echo "Downloading Porechop..."
  cd $HOME/softwares/ && git clone https://github.com/rrwick/Porechop.git
  echo "Installing Porechop"
  cd $HOME/softwares/Porechop && sudo python3 setup.py install && sudo rm -rf $HOME/softwares/Porechop
  echo "" && echo "Successfully installed Porechop!" && echo ""
else
  echo "" && echo "Porechop already installed!" && echo ""
fi

# Miniconda
if [ -z "$(which conda)" ]
then
  echo "" && echo "Downloading Miniconda..."
  curl https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o $HOME/softwares/miniconda.sh
  echo "" && echo "Installing Miniconda..."
  bash $HOME/softwares/miniconda.sh -bfp $HOME/softwares/conda && rm -rf $HOME/softwares/miniconda.sh
  export PATH="$HOME/softwares/conda/bin:/usr/local/share/rsi/idl/bin:$PATH"
  echo 'export PATH="$HOME/softwares/conda/bin:/usr/local/share/rsi/idl/bin:$PATH"' >> $HOME/.bashrc
  conda update -y -n base conda
  echo "" && echo "Successfully installed Miniconda!" && echo ""
else
  echo "" && echo "Miniconda already installed!" && echo ""
fi

# Create conda environment: minion-seq
echo "" && echo "Creating "minion-seq" environment..."
conda env create -f $HOME/softwares/minion-seq/envs/minion-seq_env.yml

# Create PATH to bin folder
echo "" && echo "Creating PATH to bin folder..."
cp -f -r -u $HOME/softwares/minion-seq/bin/ $HOME/bin/ && \
chmod 777 -R $HOME/bin/ && \
export PATH="$HOME/bin:/usr/local/share/rsi/idl/bin:$PATH" >> $HOME/.bashrc && \
echo 'export PATH="$HOME/bin:/usr/local/share/rsi/idl/bin:$PATH"' >> $HOME/.bashrc

echo "" && echo "" && echo "Done!"
