FROM nvidia/cuda:11.3.1-cudnn8-runtime-ubuntu18.04

# metainformation #CHANGE
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.authors="Gustaf Ahdritz"
LABEL org.opencontainers.image.source="https://github.com/aqlaboratory/openfold"
LABEL org.opencontainers.image.licenses="Apache License 2.0"
LABEL org.opencontainers.image.base.name="docker.io/nvidia/cuda:10.2-cudnn8-runtime-ubuntu18.04"

RUN apt-key del 7fa2af80
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub

RUN apt-get update && apt-get install -y wget libxml2 cuda-minimal-build-11-3 libcusparse-dev-11-3 libcublas-dev-11-3 libcusolver-dev-11-3 git
RUN wget -P /tmp \
    "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" \
    && bash /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm /tmp/Miniconda3-latest-Linux-x86_64.sh
ENV PATH /opt/conda/bin:$PATH
### ABOVE FROM OPENFOLD Dockerfile

# get esmfold-dropouts and install into conda
RUN git clone https://github.com/FinnOD/esm-dropouts.git
RUN cd esm-dropouts/ && conda env create -f environment.yml

# activate conda and install extra esmfold deps
SHELL ["conda", "run", "-n", "esmfold", "/bin/bash", "-c"]
RUN pip install 'dllogger @ git+https://github.com/NVIDIA/dllogger.git'
RUN pip install 'openfold @ git+https://github.com/aqlaboratory/openfold.git@4b41059694619831a7db195b7e0988fc4ff3a307'
RUN pip install 'fair-esm[esmfold] @ git+https://github.com/FinnOD/esm-dropouts.git'

# download esm weights
RUN python -c "import esm; model = esm.pretrained.esmfold_v1()"
