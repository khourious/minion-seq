#!/bin/bash

# Install minion-seq requirements
echo ">> minion-seq requirements <<" && echo ""

# Install packages: curl git htop libdeflate-dev nanopolish r-base-core wget
sudo apt install curl git htop libdeflate-dev nanopolish r-base-core wget

# MinKNOW
echo "Downloading MinKNOW..."
sudo apt update && wget -O- https://mirror.oxfordnanoportal.com/apt/ont-repo.pub | sudo apt-key add -
echo "deb http://mirror.oxfordnanoportal.com/apt bionic-stable non-free" | sudo tee /etc/apt/sources.list.d/nanoporetech.sources.list
echo "Installing MinKNOW..."
sudo apt update && sudo apt install minion-nc
echo "Successfully installed MinKNOW!" && echo ""

# Guppy CPU
if [ -z "$(which guppy_basecaller)" ]
then
  echo "Downloading Guppy..."
  curl https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_3.4.4_linux64.tar.gz --output $HOME/softwares/ont-guppy-cpu.tar.gz
  curl https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy_3.4.4_linux64.tar.gz --output $HOME/softwares/ont-guppy-gpu.tar.gz
  echo "Installing Guppy..."
  cd $HOME/softwares/ && tar -vzxf ont-guppy-cpu.tar.gz && mv ont-guppy-cpu/ guppy-cpu/ && rm -rf ont-guppy-cpu.tar.gz
  cd $HOME/softwares/ && tar -vzxf ont-guppy-gpu.tar.gz && mv ont-guppy/ guppy-gpu/ && rm -rf ont-guppy-gpu.tar.gz
  export PATH="$HOME/softwares/guppy-cpu/bin:/usr/local/share/rsi/idl/bin:$PATH"
  export PATH="$HOME/softwares/guppy-gpu/bin:/usr/local/share/rsi/idl/bin:$PATH"
  echo 'export PATH="$HOME/softwares/guppy-cpu/bin:/usr/local/share/rsi/idl/bin:$PATH"' >> $HOME/.bashrc
  echo 'export PATH="$HOME/softwares/guppy-gpu/bin:/usr/local/share/rsi/idl/bin:$PATH"' >> $HOME/.bashrc
  echo "Successfully installed Guppy!" && echo ""
else
  echo "Guppy already installed!" && echo ""
fi

# Porechop
if [ -z "$(which porechop)" ]
then
  echo "Downloading Porechop..."
  cd $HOME/softwares/ && git clone https://github.com/rrwick/Porechop.git
  echo "Installing Porechop"
  cd $HOME/softwares/Porechop && sudo python3 setup.py install && sudo rm -rf mv $HOME/softwares/Porechop
  echo "Successfully installed Porechop!" && echo ""
else
  echo "Porechop already installed!" && echo ""
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
  conda update --yes --name base conda
  echo "Successfully installed Miniconda!" && echo ""
else
  echo "Miniconda already installed!" && echo ""
fi

# Create conda environment: minion-seq
echo "Creating "minion-seq" environment..."
conda env create --file $HOME/softwares/minion-seq/envs/minion-seq_env.yml

# RAMPART
echo "Downloading RAMPART..."
cd $HOME/softwares/ && git clone https://github.com/artic-network/rampart.git
echo "Creating "rampart" environment..."
conda env create --file $HOME/softwares/minion-seq/envs/rampart_env.yml
echo "Installing RAMPART..."
source activate rampart
cd $HOME/softwares/rampart && npm install && npm run build && npm install -g .
echo "Successfully installed RAMPART!" && echo ""

# Create PATH to bin folder
echo "Creating PATH to bin folder..."
cp -f -r -u $HOME/softwares/minion-seq/bin/ $HOME/bin/ && \
chmod 777 -R $HOME/bin/ && \
export PATH="$HOME/bin:/usr/local/share/rsi/idl/bin:$PATH" >> $HOME/.bashrc && \
echo 'export PATH="$HOME/bin:/usr/local/share/rsi/idl/bin:$PATH"' >> $HOME/.bashrc

echo "" && echo "Done!"
