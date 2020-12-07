FROM ubuntu:latest

ENV CLI_VERSION=1.44.1 \
    GO_VERSION=1.15.6 \
    TERRAFORM_VERSION=0.13.5 \
    CI="true" \
    BITRISE_IO="true" \
    BITRISE_SOURCE_DIR="/bitrise/src"

ADD ./scripts/* /tmp/

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    wget \
    git \
    rsync \
    python \
    sudo \
    expect \
    unzip \
    nodejs \
    jq \
    docker.io \
    build-essential \
    && /tmp/install_bitrise_cli.sh \
    && /tmp/install_go.sh \
    && /tmp/install_gcloud_cli.sh \
    && /tmp/install_helm.sh \
    # && /tmp/install_argo.sh \
    && /tmp/install_terraform.sh \
    && rm -rf /var/cache/apt \
    && apt-get clean

ENV GOBIN=/usr/local/go/bin
ENV GOPATH=$HOME/go
ENV PATH=$PATH:/usr/local/google-cloud-sdk/bin:/usr/local/bin/argocd:${GOBIN}

RUN mkdir -p $BITRISE_SOURCE_DIR \
    && mkdir -p $GOPATH \
    && bitrise setup \
    && bitrise envman -version \
    && bitrise stepman -version \
    #  cache for the StepLib
    && bitrise stepman setup -c https://github.com/bitrise-io/bitrise-steplib.git \
    && bitrise stepman update \
    && go get -u github.com/kisielk/errcheck \
    && go get -u github.com/tfsec/tfsec/cmd/tfsec \
    && go get -u golang.org/x/lint/golint

WORKDIR $BITRISE_SOURCE_DIR

