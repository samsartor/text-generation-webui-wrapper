# Wrapper for oobabooga's text-generation-webui

This repository creates the `s9pk` package that is installed to run `GPT4All` on [embassyOS](https://github.com/Start9Labs/embassy-os/).

## Building

The process of building the package is the same as for pretty much any other start9 wrapper repository. If you have the dependencies installed, just run `make`.

## Updating

The process for version-bumping oobabooga or a dependency is a little complicated. My advice is to:
1. launch the `start9/ai-base` docker container with /data mounted to some persistent volume
2. in the container's `/data` directory, clone the desired revision of text-generation-webui
3. checkout the same revision in the text-generation-webui submodule
4. in the container, run `pip install -r requirements.txt`
5. run the server and check that everything works
6. in the container, run `pip freeze`
7. copy the results into `requirements-versions.txt` and delete unneeded dependencies such as `torch` and `nvidia-*`
