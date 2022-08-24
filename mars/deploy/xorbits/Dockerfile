FROM xorbits/mars:base

COPY . /opt/mars

RUN /opt/conda/bin/pip install -e /opt/mars && \
    apt-get -yq remove gcc g++ nodejs && \
    apt-get -yq autoremove && \
    apt-get -yq clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/local/lib/node_modules
