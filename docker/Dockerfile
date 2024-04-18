FROM ubuntu:20.04

RUN chmod 1777 /tmp
#ENV DEBIAN_FRONTEND=noninteractivel LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu:/app/lib:/usr/local/cuda/lib64
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y sudo make g++ build-essential wget unzip \
              libcurl4-openssl-dev openssh-client git cmake openssl libssl-dev openssh-server locales \
              pkg-config rsync zlib1g-dev

RUN locale-gen en_US.UTF-8

# For Jammy we need libssl1.1
RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1-1ubuntu2.1~18.04.23_amd64.deb
RUN dpkg -i libssl1.1_1.1.1-1ubuntu2.1~18.04.23_amd64.deb

RUN wget https://github.com/Kitware/CMake/releases/download/v3.29.0-rc1/cmake-3.29.0-rc1-linux-x86_64.sh
RUN chmod +x cmake-3.29.0-rc1-linux-x86_64.sh
RUN ./cmake-3.29.0-rc1-linux-x86_64.sh --skip-license --prefix=/usr/local

RUN mkdir /var/run/sshd
# Set root password for SSH access (change 'your_password' to your desired password)
RUN echo 'root:root' | chpasswd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo PermitRootLogin yes >> /etc/ssh/sshd_config
RUN echo PasswordAuthentication yes >> /etc/ssh/sshd_config

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

EXPOSE 22

CMD ["/entrypoint.sh"]