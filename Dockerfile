FROM python:3.11
RUN apt update
RUN apt install -y vim
RUN apt install -y nano
RUN apt install -y libvips
COPY . /app
WORKDIR /app

ENTRYPOINT ["tail", "-f", "/dev/null"]
