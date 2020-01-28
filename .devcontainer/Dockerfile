FROM cirrusci/flutter

WORKDIR /home/cirrus/sdks/flutter
RUN sudo apt-get update \
    && git checkout master \
    && git pull \
    && flutter channel stable
    && flutter upgrade

WORKDIR /workspace
