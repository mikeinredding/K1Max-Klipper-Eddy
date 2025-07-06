#!/bin/bash

rsync --verbose --recursive --exclude-from=./exclude.txt --include-from=./include.txt . /usr/share/klipper