#!/bin/sh

dir=${0%/node_release.sh}

source ${dir}/.venv/bin/activate
python ${dir}/node_release_script.py
