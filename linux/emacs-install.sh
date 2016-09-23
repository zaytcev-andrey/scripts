#!/bin/bash

# Install emacs24
# https://launchpad.net/~cassou/+archive/emacs
# sudo add-apt-repository -y ppa:cassou/emacs
# sudo apt-get -qq update
sudo apt-get install -y emacs24-nox emacs24-el emacs24-common-non-dfsg

if [ -d .emacs.d/ ]; then
    mv .emacs.d .emacs.d~
fi
