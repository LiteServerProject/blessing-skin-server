FROM ubuntu:latest
# apt mirror
RUN sed -i 's/archive.ubuntu.com/mirrors.cloud.tencent.com/g; s/security.ubuntu.com/mirrors.cloud.tencent.com/g' /etc/apt/sources.list \
    && rm -f /etc/apt/apt.conf.d/docker-gzip-indexes

# configure tzdata
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' > /etc/timezone

# add systemd
RUN apt update \
  && DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt install -y systemd \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* /var/tmp/* \
  && sed 's/ProtectHostname=yes/ProtectHostname=no/g' -i /lib/systemd/system/systemd-logind.service \
  && cd /lib/systemd/system/sysinit.target.wants/ \
  && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1 \
  && rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*
ENTRYPOINT ["/bin/systemd"]

# install
RUN apt update && apt install -y nginx php-fpm php-pdo php-mbstring php-tokenizer php-gd php-xml php-ctype php-json php-fileinfo php-zip php-mysql && rm -rf /var/lib/apt/lists/*
COPY default.conf /etc/nginx/sites-enabled/default
COPY skin-init.service /etc/systemd/system/
RUN systemctl enable skin-init
