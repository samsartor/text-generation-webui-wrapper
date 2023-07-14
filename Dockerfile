FROM start9/ai-base:latest

RUN apt-get update && \
    apt-get install -y git tini && \
    rm -rf /var/lib/apt/lists

ADD ./requirements-versions.txt ./text-generation-webui/requirements-versions.txt
WORKDIR /text-generation-webui
RUN pip install --no-deps -r requirements-versions.txt

ADD ./text-generation-webui /text-generation-webui
# ADD webui.patch webui.patch
# RUN patch -p1 webui.patch
# ADD ./icon.png icon.png
ARG DEFAULT_MODEL
ENV DEFAULT_MODEL=$DEFAULT_MODEL
RUN mv models models_init
ADD --chmod=755 ./check-mem.py /usr/local/bin/check-mem.py
ADD --chmod=755 ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
