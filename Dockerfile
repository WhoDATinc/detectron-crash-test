# Dockerfile extending a generic NodeJS/NVidia (CUDA9,CUDNN7) image and a generic Python/Miniconda3 image with application files for a
# single application.
FROM docker.io/zakdances/docker-images:latest

# You can use this build-arg have docker bypass the command which
# causes the crash (`make ops`). The image will be kept alive with a
# nodejs server so you can terminal in. Example: "docker build --build-arg make_ops=false"
ARG make_ops=true

WORKDIR /app

# I've tried all of the following enviromental variable combinations

# # Use Caffe2 image as parent image
# FROM caffe2/caffe2:snapshot-py2-cuda9.0-cudnn7-ubuntu16.04 as ml

# RUN mv /usr/local/caffe2 /usr/local/caffe2_build
# ENV Caffe2_DIR /usr/local/caffe2_build

# ENV PYTHONPATH /usr/local/caffe2_build:${PYTHONPATH}
# ENV LD_LIBRARY_PATH /usr/local/caffe2_build/lib:${LD_LIBRARY_PATH}

# ENV Caffe2_DIR /opt/conda/envs/py3/lib/python3.7/site-packages/torch/share/cmake/Caffe2
# ENV Caffe2_DIR /opt/conda/lib/python3.7/site-packages/torch/share/cmake/Caffe2
# ENV PYTHONPATH /opt/conda/lib/python3.6/site-packages/torch/share/cmake/Caffe2:${PYTHONPATH}
# ENV LD_LIBRARY_PATH /opt/conda/lib/python3.6/site-packages/torch/share/cmake/Caffe2/public:${LD_LIBRARY_PATH}
# ENV Caffe2_DIR /opt/conda/lib/python3.7/site-packages/torch/share/cmake/Caffe2
# ENV EXTRA_CAFFE2_DIRS = /opt/conda/lib/python3.6/site-packages/torch/lib/include/caffe2:/opt/conda/lib/python3.6/site-packages/torch/lib:/opt/conda/lib/python3.6/site-packages/torch/lib/include:/opt/conda/lib/python3.6/site-packages/torch/share/cmake/Caffe2:/opt/conda/lib/python3.6/site-packages/torch/share/cmake
# ENV EXTRA_CAFFE2_DIRS = /opt/conda/lib/python3.7/site-packages/torch/lib/include/caffe2:/opt/conda/lib/python3.7/site-packages/torch/lib:/opt/conda/lib/python3.7/site-packages/torch/lib/include:/opt/conda/lib/python3.7/site-packages/torch/share/cmake/Caffe2:/opt/conda/lib/python3.7/site-packages/torch/share/cmake

# ENV PYTHONPATH ${Caffe2_DIR}:${PYTHONPATH}:${EXTRA_CAFFE2_DIRS}
# ENV LD_LIBRARY_PATH ${EXTRA_CAFFE2_DIRS}:${LD_LIBRARY_PATH}

# Without Caffe2_DIR set thusly, then the first `make` command for detectron will crash
ENV Caffe2_DIR /opt/conda/lib/python3.7/site-packages/torch/share/cmake/Caffe2

# Make sure all package managers are updated
RUN conda update conda
RUN apt-get update
RUN apt update

# Make sure cmake is updated to at least v3.12. It's neccesary for detectron to install.
RUN apt remove cmake -y
RUN conda install cmake -y

# Install ML libraries, this may take a while because pytorch is big.
RUN apt-get install libsm6 libxrender1 libfontconfig1 nano -y
RUN conda install Cython protobuf matplotlib future graphviz hypothesis pydot pyyaml mock scipy pytorch-nightly -c pytorch -y
RUN pip install opencv-python

# Just a quick version check before the final plunge
RUN cmake --version
RUN which python
RUN python --version
RUN which pip
RUN pip --version
RUN printenv

# This is where it gets interesting.

# Install Detectron (below code from here: https://github.com/facebookresearch/Detectron/blob/master/INSTALL.md)

# Install the COCO API
WORKDIR /app
RUN git clone https://github.com/cocodataset/cocoapi.git
WORKDIR /app/cocoapi/PythonAPI
RUN python setup.py build_ext install
RUN rm -rf build

WORKDIR /app
RUN git clone https://github.com/facebookresearch/detectron
WORKDIR /app/detectron
RUN make
# Another quick version check before the crash
RUN cmake --version
RUN which python
RUN python --version
RUN which pip
RUN pip --version
RUN printenv
# This next command (make ops) is where it should crash, unfortunately...
# The crash message should be something like
# "fatal error: caffe2/core/context.h: No such file or directory"
RUN if [ "$make_ops" = "true" ]; then make ops; else echo 'skipping make ops for now'; fi

# If you got here, then the crash has been averted.

# spinning up a basic NodeJS express server...

# Check to see if the nodejs version included in the base runtime satisfies
# '>=0.12.7', if not then do an npm install of the latest available
# version that satisfies it.
RUN /usr/local/bin/install_node '>=8.12.0'

WORKDIR /app
RUN mkdir -p server
WORKDIR /app/server
COPY . .

RUN mkdir -p public/files/output/files
RUN npm i

WORKDIR /app

CMD node server/index.js