FROM gcr.io/danceplanet-4d6af/nodejs-gpu-docker:v1

# ENTRYPOINT [ “/bin/bash”, “-c” ]

# # Use Caffe2 image as parent image
# FROM caffe2/caffe2:snapshot-py2-cuda9.0-cudnn7-ubuntu16.04 as ml

# RUN mv /usr/local/caffe2 /usr/local/caffe2_build
# ENV Caffe2_DIR /usr/local/caffe2_build

# ENV PYTHONPATH /usr/local/caffe2_build:${PYTHONPATH}
# ENV LD_LIBRARY_PATH /usr/local/caffe2_build/lib:${LD_LIBRARY_PATH}

#  /opt/conda/lib/python3.7/site-packages/torch/lib/include

# # Clone the Detectron repository
# RUN git clone https://github.com/facebookresearch/detectron /detectron

# # Install Python dependencies
# RUN pip install -r /detectron/requirements.txt

# # Install the COCO API
# RUN git clone https://github.com/cocodataset/cocoapi.git /cocoapi
# WORKDIR /cocoapi/PythonAPI
# RUN make install

# # Go to Detectron root
# WORKDIR /detectron

# # Set up Python modules
# RUN make

# # [Optional] Build custom ops
# RUN make ops


# Dockerfile extending the generic Node image with application files for a
# single application.
# FROM gcr.io/google_appengine/nodejs

# COPY --from=gcr.io/danceplanet-4d6af/detectron1-image@sha256:c7843a138273ec23ca7f0ef597792db671518768e5a068cbac90cde6f0811c00 /etcc/nginx/nginx.conf /nginx.conf
# Check to see if the the version included in the base runtime satisfies
# '>=0.12.7', if not then do an npm install of the latest available
# version that satisfies it.
WORKDIR /app

RUN apt-get update
# RUN apt install apt-utils -y
# RUN apt-get purge cmake

RUN apt-get install wget nano -y

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH
ENV Caffe2_DIR /opt/conda/lib/python3.6/site-packages/torch/share/cmake/Caffe2
# ENV EXTRA_CAFFE2_DIRS = /opt/conda/lib/python3.6/site-packages/torch/lib/include/caffe2:/opt/conda/lib/python3.6/site-packages/torch/lib:/opt/conda/lib/python3.6/site-packages/torch/lib/include:/opt/conda/lib/python3.6/site-packages/torch/share/cmake/Caffe2:/opt/conda/lib/python3.6/site-packages/torch/share/cmake
# ENV EXTRA_CAFFE2_DIRS = /opt/conda/lib/python3.7/site-packages/torch/lib/include/caffe2:/opt/conda/lib/python3.7/site-packages/torch/lib:/opt/conda/lib/python3.7/site-packages/torch/lib/include:/opt/conda/lib/python3.7/site-packages/torch/share/cmake/Caffe2:/opt/conda/lib/python3.7/site-packages/torch/share/cmake

# ENV PYTHONPATH ${Caffe2_DIR}:${PYTHONPATH}:${EXTRA_CAFFE2_DIRS}
# ENV LD_LIBRARY_PATH ${EXTRA_CAFFE2_DIRS}:${LD_LIBRARY_PATH}

RUN apt-get update --fix-missing && \
  apt-get install -y bzip2 ca-certificates curl git && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
  /bin/bash ~/miniconda.sh -b -p /opt/conda && \
  rm ~/miniconda.sh && \
  /opt/conda/bin/conda clean -tipsy && \
  ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
  echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
  echo "conda activate base" >> ~/.bashrc
  # echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

# RUN conda update conda
# RUN conda create -n py3 python=3 -y
# RUN echo "conda activate py3" >> ~/.bashrc
# RUN . activate py3
# ENV PATH /opt/conda/envs/py3/bin:$PATH
# ENV PATH /opt/conda/envs/testenv/bin:$PATH
# ENV CONDA_DEFAULT_ENV py3
# ENV CONDA_PREFIX /opt/conda/envs/py3
# ENV CYTHON /opt/conda/envs/py3/share/cython

# now update conda and install pip
RUN conda update conda
RUN apt remove cmake -y
RUN conda install cmake -y
RUN cmake --version
# RUN conda install pip
# RUN pip install --upgrade pip
RUN which pip
RUN pip --version
RUN which python
RUN python --version
# RUN echo "conda activate py3" >> ~/.bashrc
# ENV PATH /opt/conda/bin:$PATH

# RUN apt-get -qq update && apt-get -qq -y install curl bzip2 \
#   && curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
#   && bash /tmp/miniconda.sh -bfp /usr/local \
#   && rm -rf /tmp/miniconda.sh \
#   # && conda install -y python=3 \
#   && conda update conda \
#   && apt-get -qq -y remove curl bzip2 \
#   && apt-get -qq -y autoremove \
#   && apt-get autoclean \
#   && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log \
#   && conda clean --all --yes



# RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
# RUN chmod +x Miniconda3-latest-Linux-x86_64.sh
# RUN bash ./Miniconda3-latest-Linux-x86_64.sh -bfp
# RUN source ~/.bashrc


# ENV PATH ~/anaconda3/bin:$PATH
# ENV PATH ~/conda/bin
# ENV PATH ./conda/bin


# conda install pip


RUN apt-get update
RUN apt-get install libsm6 libxrender1 libfontconfig1 -y
RUN pip install opencv-python
RUN conda install Cython protobuf matplotlib future graphviz hypothesis pydot pyyaml mock scipy pytorch-nightly -c pytorch -y
# (optional) create and activate an environment
# RUN conda create -n py3 python
# RUN python --version
# RUN pip --version
# RUN pip3 --version
# RUN activate py3
# RUN conda install pytorch-nightly -c pytorch -y

# ENV Caffe2_DIR /opt/conda/envs/py3/lib/python3.7/site-packages/torch/share/cmake/Caffe2
# ENV Caffe2_DIR /opt/conda/lib/python3.7/site-packages/torch/share/cmake/Caffe2
# ENV PYTHONPATH /opt/conda/lib/python3.6/site-packages/torch/share/cmake/Caffe2:${PYTHONPATH}
# ENV LD_LIBRARY_PATH /opt/conda/lib/python3.6/site-packages/torch/share/cmake/Caffe2/public:${LD_LIBRARY_PATH}



# RUN git clone https://github.com/pytorch/pytorch.git
# WORKDIR /app/pytorch
# RUN git submodule update --init --recursive
# RUN python setup.py install

# Detectron

# Install the COCO API
WORKDIR /app
RUN git clone https://github.com/cocodataset/cocoapi.git
WORKDIR /app/cocoapi/PythonAPI
RUN python setup.py build_ext install
RUN rm -rf build


WORKDIR /app
RUN git clone https://github.com/facebookresearch/detectron
WORKDIR /app/detectron
RUN cmake --version
RUN python --version
RUN pip --version
RUN printenv
RUN make
RUN make ops

RUN /usr/local/bin/install_node '>=8.12.0'

# WORKDIR /app
# RUN git clone https://github.com/pytorch/pytorch.git
# WORKDIR /app/pytorch
# RUN git submodule update --init --recursive
# RUN python3 setup.py install

WORKDIR /app
RUN mkdir -p server
WORKDIR /app/server
COPY . .

RUN mkdir -p public/files/output/files
RUN npm i
# CMD ["python tests/test_batch_permutation_op.py"]
# CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
WORKDIR /app

# COPY --from=ml . .

CMD node server/index.js