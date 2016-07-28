# FlashX Docker image with ssh port forwarding and general ubuntu hackery


FROM ubuntu:14.04
MAINTAINER Alexander Niculescu <al3xander.niculescu@gmail.com>

# This is for installing R.
RUN sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
RUN gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
RUN gpg -a --export E084DAB9 | sudo apt-key add -

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd


###FLASHX CONF COMBINED FROM DOCKERFILE &&FLASHX QUICKSTART###
#https://github.com/icoming/FlashX/wiki/FlashX-Quick-Start-Guide
#https://github.com/wking/dockerfile

#RUN sudo apt-get update
#RUN sudo apt-get update
RUN sudo apt-get install -y git cmake g++
RUN sudo apt-get install -y libboost-dev libboost-system-dev libboost-filesystem-dev libnuma-dev libaio-dev libhwloc-dev libatlas-base-dev zlib1g-dev
RUN sudo apt-get install -y libstxxl-dev zlib1g-dev

RUN git clone https://github.com/icoming/FlashX.git

RUN sudo apt-get install wget
#wget is for trilinos

WORKDIR /FlashX
RUN mkdir build
WORKDIR build
RUN cmake ..
RUN make -j4


####Install and compile R
#https://www.digitalocean.com/community/tutorials/how-to-set-up-r-on-ubuntu-14-04
RUN sudo apt-get -y install r-base

#run R >> intstall igraph install.packages("igraph")
RUN sudo su - -c "R -e \"install.packages('igraph', repos = 'http://cran.rstudio.com/')\""

WORKDIR /FlashX
RUN ./install_FlashR.sh

#check to see if it's there ^^^?

####R finished####


CMD wget http://snap.stanford.edu/data/wiki-Vote.txt.gz
CMD gunzip wiki-Vote.txt.gz
CMD build/matrix/utils/el2fg conf/run_test.txt wiki-Vote.txt wiki-Vote

CMD build/flash-graph/test-algs/test_algs flash-graph/conf/run_test.txt wiki-Vote.adj wiki-Vote.index wcc


###FLASHX CONF END ###


ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]


