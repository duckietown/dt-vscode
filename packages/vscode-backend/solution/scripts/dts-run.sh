#!/bin/bash

export PATH=$PATH:/root/.local/bin
dts --set-version daffy
dts version

cp ./solution/command.py ~/.dt-shell/commands-multi/daffy/devel/run/command.py