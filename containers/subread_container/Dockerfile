FROM ubuntu:24.04
WORKDIR opt/src
RUN apt-get update
RUN apt-get install -y wget
RUN wget --output-document subread.tar.gz https://sourceforge.net/projects/subread/files/subread-1.4.6-p3/subread-1.4.6-p3-Linux-x86_64.tar.gz
RUN tar -xzf subread.tar.gz
RUN rm subread.tar.gz
ENV PATH=$PATH:/opt/src/subread-1.4.6-p3-Linux-x86_64/bin
