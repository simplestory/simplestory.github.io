
From node:16.17-alpine3.16

COPY . /Blog
WORKDIR /Blog

ARG PANDOC_TAR=pandoc-2.19.2-linux-amd64.tar.gz
ARG PANDOC_TAR_LINK=https://github.com/jgm/pandoc/releases/download/2.19.2/${PANDOC_TAR}
ARG PANDOC_DIR=/usr/local

# build base environment
RUN apk add --no-cache git \
    && npm install -g hexo-cli \
    && wget ${PANDOC_TAR_LINK} -O ${PANDOC_TAR} \
    && tar xvzf ${PANDOC_TAR} --strip-components 1 -C ${PANDOC_DIR} \
    && rm ${PANDOC_TAR} \
    && npm install
