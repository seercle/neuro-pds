FROM vuiiscci/slant:deep_brain_seg_v1_0_0_CPU

## Install Miniconda3 with Python 3.7
#RUN rm -rf /pythondir && \
#  wget --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-py37_23.1.0-1-Linux-x86_64.sh && \
#  bash Miniconda3-py37_23.1.0-1-Linux-x86_64.sh -b -p /pythondir/miniconda
#ENV CONDA_DEFAULT_ENV="base"
#ENV CONDA_PREFIX="/pythondir/miniconda"
#
## Install Python packages for SLANT
#RUN pip install torch && \
#  pip install numpy && \
#  pip install pytz && \
#  pip install scipy && \
#  pip install nibabel

# Install dependencies for eztrace
RUN rm -f /etc/apt/sources.list.d/cuda.list /etc/apt/sources.list.d/nvidia-ml.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends libiberty-dev binutils-dev openmpi-bin zlib1g-dev libopenmpi-dev

# Install Python 3.7.17 from source (eztrace requires Python >= 3.7)
RUN cd /opt && \
  wget --no-check-certificate https://www.python.org/ftp/python/3.7.17/Python-3.7.17.tgz && \
  tar -xf Python-3.7.17.tgz && \
  cd Python-3.7.17 && \
  ./configure --enable-optimizations --enable-shared && \
  make -j 16 install && \
  ldconfig

# Install CMake 3.25.1 (eztrace requires a version higher than what apt provides)
RUN wget --no-check-certificate https://github.com/Kitware/CMake/releases/download/v3.25.1/cmake-3.25.1-linux-x86_64.sh -q -O /tmp/cmake-install.sh && \
  chmod u+x /tmp/cmake-install.sh && \
  mkdir /opt/cmake-3.25.1 && \
  /tmp/cmake-install.sh --skip-license --prefix=/opt/cmake-3.25.1 && \
  rm /tmp/cmake-install.sh && \
  ln -s /opt/cmake-3.25.1/bin/* /usr/local/bin

# Install otf2
RUN wget --no-check-certificate https://perftools.pages.jsc.fz-juelich.de/cicd/otf2/tags/otf2-3.0.3/otf2-3.0.3.tar.gz -q -O /tmp/otf2-3.0.3.tar.gz && \
  tar xf /tmp/otf2-3.0.3.tar.gz -C /tmp && \
  cd /tmp/otf2-3.0.3/ && \
  ./configure --prefix=/opt/otf2-2.0.3 && make install -j && \
  ln -s /opt/otf2-2.0.3/bin/* /usr/local/bin

# Install eztrace
RUN wget --no-check-certificate https://gitlab.com/eztrace/eztrace/-/archive/2.2.1/eztrace-2.2.1.tar.gz -q -O /tmp/eztrace-2.2.1.tar.gz && \
  tar -xzf /tmp/eztrace-2.2.1.tar.gz -C /opt && \
  cd /opt/eztrace-2.2.1 && \
  cmake . -DEZTRACE_ENABLE_MPI=ON -DEZTRACE_ENABLE_PYTHON=ON && \
  make -j 16 install
