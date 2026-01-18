#!/bin/bash
set -e
if [ -z "$PG_VERSION" ] || [ -z "$PG_MAJOR" ] || [ -z "$PG_SEARCH_VERSION" ] || [ -z "$PGVECTORSCALE_VERSION" ] || [ -z "$VECTORCHORD_VERSION" ] || [ -z "$OS_CODENAME" ]; then
    echo "Error: Missing required build-args (PG_VERSION, PG_MAJOR, PG_SEARCH_VERSION, PGVECTORSCALE_VERSION, VECTORCHORD_VERSION, OS_CODENAME)"
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

# 5. Install VectorChord
echo "Downloading VectorChord ${VECTORCHORD_VERSION} for ${ARCH}..."
# Filename format: postgresql-18-vchord_1.0.0-1_amd64.deb
curl -L "https://github.com/tensorchord/VectorChord/releases/download/${VECTORCHORD_VERSION}/postgresql-${PG_MAJOR}-vchord_${VECTORCHORD_VERSION}-1_${ARCH}.deb" -o /tmp/vchord.deb
apt-get install -y /tmp/vchord.deb

# 6. Cleanup
echo "Cleaning up build tools and temporary files..."
apt-get purge -y --auto-remove curl unzip ca-certificates
rm -rf /tmp/pg_search.deb /tmp/pgvectorscale.zip /tmp/pgvectorscale /tmp/vchord.deb /var/lib/apt/lists/*

echo "Installation complete!"
