FROM --platform=linux/amd64 ubuntu:18.04 as builder
# install packages and build openpbs
RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive apt install -y \
      gcc make libtool libhwloc-dev libx11-dev \
      libxt-dev libedit-dev libical-dev ncurses-dev perl \
      postgresql-server-dev-all postgresql-contrib python3-dev tcl-dev tk-dev swig \
      libexpat-dev libssl-dev libxext-dev libxft-dev autoconf \
      automake g++ curl

RUN cd /tmp &&\
    curl -L https://github.com/openpbs/openpbs/archive/refs/tags/v20.0.1.tar.gz -o src.tgz&&\
    tar xfz src.tgz &&\
    cd openpbs-* &&\
    ./autogen.sh &&\
    ./configure --prefix=/opt/pbs &&\
    make &&\
    make install &&\
    /opt/pbs/libexec/pbs_postinstall &&\
    chmod 04755 /opt/pbs/sbin/pbs_iff /opt/pbs/sbin/pbs_rcp &&\
    chmod 0700 /opt/pbs/bin/pbs_topologyinfo /opt/pbs/sbin/pbs_mom /opt/pbs/sbin/pbs_sched /opt/pbs/sbin/pbs_server

FROM builder as runner
EXPOSE 22
COPY --from=builder /opt/pbs /opt/pbs
RUN apt-get update &&\
    DEBIAN_FRONTEND=noninteractive apt install -y \
      expat libedit2 postgresql python3 postgresql-contrib sendmail-bin \
      sudo tcl tk libical3 postgresql-server-dev-all\
      openssh-server openssh-client openssh-sftp-server rsync

# setup ssh-server
RUN ssh-keygen -A && mkdir -p /run/sshd && rm -rf /run/nologin

# add non-root user
RUN useradd -m testuser && echo "testuser:passw0rd" | chpasswd
RUN mkdir -p /home/testuser/.ssh && chmod 755 /home/testuser/.ssh

ADD ./entrypoint.sh /
ADD ./entrypoint_withoutHistory.sh /
ENTRYPOINT ["bash", "entrypoint.sh"]
