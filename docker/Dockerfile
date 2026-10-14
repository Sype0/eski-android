# Lollipop (5.x) Google'ın önerdiği gibi Ubuntu 14.04 + OpenJDK 7 + make 3.81 ister.
FROM ubuntu:14.04

ENV DEBIAN_FRONTEND=noninteractive

# 14.04 depoları archive.ubuntu.com'dan kaldırıldıysa old-releases'e geç.
RUN (apt-get update || ( \
        sed -i -e 's|http://archive.ubuntu.com|http://old-releases.ubuntu.com|g' \
               -e 's|http://security.ubuntu.com|http://old-releases.ubuntu.com|g' \
               /etc/apt/sources.list && apt-get update )) \
 && apt-get install -y --no-install-recommends \
        openjdk-7-jdk python bc git-core gnupg flex bison gperf \
        build-essential zip unzip curl ca-certificates rsync \
        zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
        lib32ncurses5-dev lib32z1-dev x11proto-core-dev libx11-dev \
        libgl1-mesa-dev libxml2-utils xsltproc \
 && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64 \
    PATH=/usr/lib/jvm/java-7-openjdk-amd64/bin:$PATH \
    LC_ALL=C \
    USER=root

WORKDIR /aosp
