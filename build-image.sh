#!/bin/bash

# Load base version variables
if [ -f build.env ]; then
    export $(grep -v '^#' build.env | xargs)
fi

# Load local overrides
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Build for local architecture (or provide --platform if needed)
docker build \
    --build-arg PG_VERSION="$PG_VERSION" \
    --build-arg PG_MAJOR="$PG_MAJOR" \
    --build-arg PG_SEARCH_VERSION="$PG_SEARCH_VERSION" \
    --build-arg PGVECTORSCALE_VERSION="$PGVECTORSCALE_VERSION" \
    --build-arg OS_CODENAME="$OS_CODENAME" \
    -t cnpg-vectorsearch:"$PG_VERSION" .
