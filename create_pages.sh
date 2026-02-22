#! /usr/bin/env bash

mkdir -p docs && cp README.md docs/
python -m mkdocs build -d public