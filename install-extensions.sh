#!/bin/bash
set -e
if [ -z "$PG_VERSION" ] || [ -z "$PG_MAJOR" ] || [ -z "$PG_SEARCH_VERSION" ] || [ -z "$PGVECTORSCALE_VERSION" ] || [ -z "$OS_CODENAME" ]; then
    echo "Error: Missing required build-args (PG_VERSION, PG_MAJOR, PG_SEARCH_VERSION, PGVECTORSCALE_VERSION, OS_CODENAME)"
    exit 1
fi

echo "Installing extensions for architecture: $TARGETARCH"
echo "PostgreSQL version: $PG_MAJOR (Full: $PG_VERSION)"

# 1. Install build tools
apt-get update
apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    libicu-dev

# 2. Architecture logic
if [ "$TARGETARCH" = "amd64" ]; then
    ARCH="amd64"
elif [ "$TARGETARCH" = "arm64" ]; then
    ARCH="arm64"
else
    echo "Unsupported architecture: $TARGETARCH"
    exit 1
fi

# 3. Install pg_search
echo "Downloading pg_search v${PG_SEARCH_VERSION} for ${ARCH}..."
curl -L "https://github.com/paradedb/paradedb/releases/download/v${PG_SEARCH_VERSION}/postgresql-${PG_MAJOR}-pg-search_${PG_SEARCH_VERSION}-1PARADEDB-${OS_CODENAME}_${ARCH}.deb" -o /tmp/pg_search.deb
apt-get install -y /tmp/pg_search.deb

# 4. Install pgvectorscale
echo "Downloading pgvectorscale ${PGVECTORSCALE_VERSION} for ${ARCH}..."
curl -L "https://github.com/timescale/pgvectorscale/releases/download/${PGVECTORSCALE_VERSION}/pgvectorscale-${PGVECTORSCALE_VERSION}-pg${PG_MAJOR}-${ARCH}.zip" -o /tmp/pgvectorscale.zip
unzip /tmp/pgvectorscale.zip -d /tmp/pgvectorscale
apt-get install -y /tmp/pgvectorscale/*.deb

# 5. Cleanup
echo "Cleaning up build tools and temporary files..."
apt-get purge -y --auto-remove curl unzip ca-certificates
rm -rf /tmp/pg_search.deb /tmp/pgvectorscale.zip /tmp/pgvectorscale /var/lib/apt/lists/*

echo "Installation complete!"
