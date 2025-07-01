FROM --platform=linux/amd64 rocker/r-ver:4.4.1

RUN apt-get update && apt-get install -y --no-install-recommends

ENV SHELL=/bin/bash

CMD ["echo hello world"]
