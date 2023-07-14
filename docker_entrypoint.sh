#!/bin/sh

# The root directory of the webui server
cd /text-generation-webui

# Make sure the correcte models dir exists in the file browser
mkdir -p /mnt/files/models
rm -rf /mnt/files/models.tmp
# Switch to a temporary directory in case the entrypoint dies
mv /mnt/files/models /mnt/files/models.tmp
# Copy small README-style files from the webui directory
rsync -ru ./models_init/ /mnt/files/models/
# Copy the larger default model checkpoints, using cp since it supports reflink
cp -rpu --reflink=auto /mnt/default-models/ /mnt/files/models/
# Make the temporary directory official
mv /mnt/files/models.tmp /mnt/files/models
# Symlink the models directory into the webui directory where it is expected
ln -s /mnt/files/models

# Run the webui server
exec tini -- python -u server.py \
  --chat \
  --model $DEFAULT_MODEL
