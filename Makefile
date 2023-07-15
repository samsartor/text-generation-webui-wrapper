PKG_ID := $(shell yq e ".id" manifest.yaml)
PKG_VERSION := $(shell yq e ".version" manifest.yaml)
TS_FILES := $(shell find ./ -name \*.ts)
DEFAULT_MODEL := GPT4All-13B-snoozy.ggmlv3.q4_1.bin

# delete the target of a rule if it has changed and its recipe exits with a nonzero exit status
.DELETE_ON_ERROR:

all: verify

verify: $(PKG_ID).s9pk
	@embassy-sdk verify s9pk $(PKG_ID).s9pk
	@echo " Done!"
	@echo "   Filesize: $(shell du -h $(PKG_ID).s9pk) is ready"

install:
ifeq (,$(wildcard ~/.embassy/config.yaml))
	@echo; echo "You must define \"host: http://embassy-server-name.local\" in ~/.embassy/config.yaml config file first"; echo
else
	embassy-cli package install $(PKG_ID).s9pk
endif

clean:
	rm -rf docker-images
	rm -rf assets/default-models
	rm -f image.tar
	rm -f $(PKG_ID).s9pk
	rm -f scripts/*.js

clean-manifest:
	@sed -i '' '/^[[:blank:]]*#/d;s/#.*//' manifest.yaml
	@echo; echo "Comments successfully removed from manifest.yaml file."; echo

assets/default-models/GPT4All-13B-snoozy.%:
	mkdir -p $(dir $@)
	wget https://huggingface.co/TheBloke/GPT4All-13B-snoozy-GGML/resolve/main/$(notdir $@) -O $@

scripts/embassy.js: $(TS_FILES)
	deno bundle scripts/embassy.ts scripts/embassy.js

docker-images/x86_64.tar: manifest.yaml text-generation-webui/**/* docker_entrypoint.sh Dockerfile
	mkdir -p docker-images
	docker buildx build --tag start9/$(PKG_ID)/main:$(PKG_VERSION) --platform=linux/amd64 --build-arg DEFAULT_MODEL=$(DEFAULT_MODEL) -o type=docker,dest=docker-images/x86_64.tar .

$(PKG_ID).s9pk: manifest.yaml instructions.md icon.png LICENSE scripts/embassy.js docker-images/x86_64.tar assets/default-models/$(DEFAULT_MODEL)
	@echo "embassy-sdk: Preparing x86_64 package ..."
	@embassy-sdk pack
