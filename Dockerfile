FROM centos:8
EXPOSE 22

# install packages and build openpbs
RUN dnf install -y dnf-plugins-core &&\
    dnf config-manager --set-enabled powertools &&\
    dnf install -y gcc make rpm-build libtool hwloc-devel \
      libX11-devel libXt-devel libedit-devel libical-devel \
      ncurses-devel perl postgresql-devel postgresql-contrib python3-devel tcl-devel \
      tk-devel swig expat-devel openssl-devel libXext libXft \
      autoconf automake gcc-c++ \
      expat libedit postgresql-server python3 \
      sendmail sudo tcl tk libical \
      openssh-server initscripts  &&\
    cd /tmp &&\
    curl -L https://github.com/openpbs/openpbs/archive/refs/tags/v20.0.1.tar.gz -o src.tgz&&\
    tar xfz src.tgz &&\
    cd openpbs* &&\
    ./autogen.sh &&\
    ./configure --prefix=/opt/pbs &&\
    make &&\
    make install &&\
    /opt/pbs/libexec/pbs_postinstall &&\
    chmod 04755 /opt/pbs/sbin/pbs_{iff,rcp} &&\
    chmod 0700  /opt/pbs/sbin/pbs_{mom,sched,server} &&\
    chmod 0700  /opt/pbs/bin/pbs_topologyinfo

# setup ssh-server
RUN ssh-keygen -A && mkdir -p /run/sshd && rm -rf /run/nologin

# add non-root user
RUN useradd -m testuser && echo "testuser:passw0rd" | chpasswd
RUN mkdir -p /home/testuser/.ssh && chmod 755 /home/testuser/.ssh

ADD ./entrypoint*.sh /
ENTRYPOINT ["bash", "entrypoint.sh"]
