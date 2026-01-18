# CloudNativePG Vector Search Image

This repository contains a custom Docker image extending the official [CloudNativePG (CNPG)](https://cloudnative-pg.io/) PostgreSQL image with high-performance vector search and full-text search extensions.

I added an additional variant based on the official `pgvector` image. This allows for local testing of the extensions without the need for a CloudNativePG operator.

## Extensions Included

- **[pgvectorscale](https://github.com/timescale/pgvectorscale)**: Scaling `pgvector` to hundreds of millions of vectors using DiskANN.
- **[pg_search (ParadeDB)](https://github.com/paradedb/paradedb)**: High-performance full-text search based on Tantivy (BM25).
- **[VectorChord](https://github.com/tensorchord/VectorChord)**: A high-performance vector search extension for PostgreSQL.

## Directory Structure

- `Dockerfile.cnpg`: Optimized for the CloudNativePG operator (runs as user 26).
- `Dockerfile.pgvector`: Based on the standard `pgvector/pgvector` image (runs as user postgres).
- `install-extensions.sh`: Used during build to handle package installation and image hardening.
- `test-extensions.sh`: Used to verify extensions are correctly installed and linkable.
- `build-image.sh`: Local build helper script.
- `build.env`: Shared version configuration for the project.

## Local Development

### Prerequisites

- Docker with BuildKit enabled.
- (Optional) `.env` file for local version overrides.

### Build and Test

1.  **Configure versions**: Update `build.env` or create a local `.env`.
2.  **Build locally**:

    ```bash
    # Build CNPG variant (default)
    ./build-image.sh cnpg

    # Build pgvector variant
    ./build-image.sh pgvector
    ```

3.  **Run verification**:
    ```bash
    # the tag number is PG_VERSION
    ./test-extensions.sh cnpg-vectorsearch:cnpg-18.1
    ./test-extensions.sh cnpg-vectorsearch:pgvector-18.1
    ```

## Usage in PostgreSQL

After deploying the image, you must enable the extensions in your database:

```sql
CREATE EXTENSION IF NOT EXISTS pg_search CASCADE;
CREATE EXTENSION IF NOT EXISTS vectorscale CASCADE;
CREATE EXTENSION IF NOT EXISTS vchord;
```

_(Note: `vectorscale` will automatically enable `pgvector` as a dependency)._
