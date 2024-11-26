FROM ubuntu:latest

RUN apt-get update && apt-get install -y build-essential curl python3-dev python3-pip libffi-dev openssl libssl-dev sqlite3 libsqlite3-dev libbz2-dev liblzma-dev git wget git-lfs && rm -rf /var/lib/apt/lists/*
RUN curl -O https://www.python.org/ftp/python/3.10.7/Python-3.10.7.tar.xz && tar -xf Python-3.10.7.tar.xz && rm Python-3.10.7.tar.xz
WORKDIR Python-3.10.7
RUN ./configure --with-ssl --with-system-ffi --enable-optimizations --enable-loadable-sqlite-extensions && make -j$(nproc) && make install
RUN cp /usr/local/bin/pip3 /usr/local/bin/pip
WORKDIR /
RUN git clone --branch ZH-Clap https://github.com/fishaudio/Bert-VITS2.git
WORKDIR /Bert-VITS2
RUN pip3 install -r requirements.txt
# RUN pip3 install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN echo "import nltk" > init.py
RUN echo "nltk.download('cmudict')" >> init.py
ENV PATH="/usr/local/bin:${PATH}"
RUN python3 init.py
WORKDIR /Bert-VITS2/emotional
RUN rm -rf clap-htsat-fused && rm -rf wav2vec2-large-robust-12-ft-emotion-msp-dim
RUN git clone https://huggingface.co/weslie520/clap-htsat-fused
RUN git clone https://huggingface.co/weslie520/wav2vec2-large-robust-12-ft-emotion-msp-dim

WORKDIR /Bert-VITS2/bert
RUN rm -rf Erlangshen-MegatronBert-1.3B-Chinese
RUN git clone https://huggingface.co/weslie520/Erlangshen-MegatronBert-1.3B-Chinese

WORKDIR /Bert-VITS2
COPY config.yml /Bert-VITS2/config.yml
COPY xyy.json /Bert-VITS2/xyy.json
COPY G_43200.pth /Bert-VITS2/G_43200.pth
COPY webui.py /Bert-VITS2/webui.py

RUN pip3 cache purge

CMD ["python3", "webui.py"]
