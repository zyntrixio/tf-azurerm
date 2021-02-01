# Silly hack solution for running Terraform on M1 until real support
# Build with: docker build --platform=linux/amd64 -t terraform:latest .
# Run with: docker run --platform=linux/amd64 -it --rm -v $(pwd):/app -v ~/.ssh:/root/.ssh -v ~/.chef:/root/.chef -v ~/.secrets:/root/.secrets terraform:latest bash

FROM ubuntu:latest

RUN apt update && apt -y install wget unzip vim git && \
    wget https://releases.hashicorp.com/terraform/0.14.5/terraform_0.14.5_linux_amd64.zip && \
    unzip terraform_0.14.5_linux_amd64.zip && rm terraform_0.14.5_linux_amd64.zip && \
    mv terraform /usr/local/bin

WORkDIR /app
