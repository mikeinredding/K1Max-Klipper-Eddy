#!/bin/bash

rsync --verbose --recursive --exclude-from=./exclude.txt --include-from=./include.txt ./klippy /usr/share/klipper
rsync --verbose --recursive --backup --suffix=.bak --include 'config/*.cfg' --exclude-from=./exclude.txt ./config /usr/data/printer_data
