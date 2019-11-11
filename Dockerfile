#############################################
FROM debian:buster-slim as base

ENV CONDA_INSTALL_PATH /opt/conda
ENV CONDA_PATH ${CONDA_INSTALL_PATH}/bin/conda

RUN apt update && \
    apt install -y \
        curl \
        wget \
        && \
    apt clean

#############################################
FROM base as staging

ENV MINICONA_INSTALL_FILE Miniconda3-latest-Linux-x86_64.sh
RUN wget https://repo.anaconda.com/miniconda/${MINICONA_INSTALL_FILE}
RUN bash ${MINICONA_INSTALL_FILE} -b -p ${CONDA_INSTALL_PATH}
RUN ${CONDA_PATH} update conda -y
RUN ${CONDA_PATH} install -y conda-build conda-verify
RUN ${CONDA_PATH} clean -afy
RUN find ${CONDA_INSTALL_PATH} -follow -type f -name '*.a' -delete  && \
    find ${CONDA_INSTALL_PATH} -follow -type f -name '*.pyc' -delete && \
    find ${CONDA_INSTALL_PATH} -follow -type f -name '*.js.map' -delete
RUN echo ". ${CONDA_INSTALL_PATH}/etc/profile.d/conda.sh" >> /root/.bashrc && \
    echo "conda activate base" >> /root/.bashrc

#############################################
FROM base

COPY --from=staging ${CONDA_INSTALL_PATH} ${CONDA_INSTALL_PATH}
COPY --from=staging /root/.bashrc /root/.bashrc
