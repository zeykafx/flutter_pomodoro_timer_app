FROM gitpod/workspace-full:latest

ENV ANDROID_HOME=/home/gitpod/android-sdk \
    FLUTTER_HOME=/home/gitpod/flutter

USER root

RUN curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list && \
    apt-get update && \
    apt-get -y install build-essential dart libkrb5-dev gcc make gradle android-tools-adb android-tools-fastboot openjdk-8-jdk && \
    apt-get clean && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*;

USER gitpod

RUN cd /home/gitpod && \
    wget -qO flutter_sdk.tar.xz \
    https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.3.8-stable.tar.xz &&\
    tar -xvf flutter_sdk.tar.xz && \
    rm -f flutter_sdk.tar.xz

RUN cd /home/gitpod && \
    wget -qO android_studio.tar.gz \
    https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2021.3.1.17/android-studio-2021.3.1.17-linux.tar.gz && \
    tar -xvf android_studio.tar.gz && \
    rm -f android_studio.tar.gz

RUN mkdir -p /home/gitpod/android-sdk && \
    cd /home/gitpod/android-sdk && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip && \
    unzip comandlinetools-linux-8512546_latest.zip && \
    rm -f comandlinetools-linux-8512546_latest.zip