FROM cirrusci/flutter

WORKDIR /home/cirrus/sdks/flutter
RUN sudo apt-get update \
    && git checkout master \
    && git pull \
    && flutter upgrade

WORKDIR /workspace
