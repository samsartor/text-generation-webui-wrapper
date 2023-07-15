#!/usr/bin/bash

# The root directory of the webui server
cd /text-generation-webui

# Make sure the correcte models dir exists in the file browser
mkdir -p /mnt/files/models
rm -rf /mnt/files/models.tmp
# Switch to a temporary directory in case the entrypoint dies
mv -T /mnt/files/models /mnt/files/models.tmp
# Copy small README-style files from the webui directory
rsync -ru ./models_init/. /mnt/files/models.tmp/
# Copy the larger default model checkpoints, using cp since it supports reflink
cp -au --reflink=auto /mnt/default-models/. /mnt/files/models.tmp/
# Make the temporary directory official
mv -T /mnt/files/models.tmp /mnt/files/models
# Symlink the models directory into the webui directory where it is expected
ln -s /mnt/files/models

# Set up logs directory
mkdir -p /mnt/files/logs
ln -s /mnt/files/logs

# Set up other persistant directories
for dir in presets characters loras; do
  if [ -d /mnt/files/$dir ]; then
    rm -r $dir
  else
    mv $dir /mnt/files/$dir
  fi
  ln -s /mnt/files/$dir
done

# Create settings file
if [ ! -f /data/settings.yaml ]; then
  cp settings-template.yaml /data/settings.yaml
fi

# Run the webui server
exec tini -- python -u server.py \
  --chat --cpu \
  --listen \
  --settings /data/settings.yaml \
  --model $DEFAULT_MODEL
