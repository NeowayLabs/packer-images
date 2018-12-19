FROM debian:stable-slim

ENV TERRAFORM_VERSION 0.11.7
ENV PACKER_VERSION 1.2.5
ENV EDITOR vim
ENV ANSIBLE_VERSION 2.5.0

RUN apt-get -y update && \
    apt-get -y install \
        openssh-client \
        python \
        python-pip \
        unzip \
        git \
        vim \
        jq \
        && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/*

WORKDIR /packer-images

RUN pip install ansible==${ANSIBLE_VERSION}

ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip /tmp/

RUN unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
    rm /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip /tmp/

RUN unzip /tmp/packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
    rm /tmp/packer_${PACKER_VERSION}_linux_amd64.zip

RUN groupadd -r packer && useradd --no-log-init -m -r -g packer packer

COPY hack/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
