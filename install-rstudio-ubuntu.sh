#! /bin/sh

## install rstudio

RSTUDIO_VERSION=1.1.91

# RSTUDIO_FILE=rstudio-server-rhel-"$RSTUDIO_VERSION"-x86_64.rpm
RSTUDIO_FILE=rstudio-server-"$RSTUDIO_VERSION"-amd64.deb

wget https://s3.amazonaws.com/rstudio-dailybuilds/"$RSTUDIO_FILE"

# sudo yum install --nogpgcheck "$RSTUDIO_FILE"
sudo gdebi "$RSTUDIO_FILE"


