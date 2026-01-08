# CloudNativePG Vector Search Image

This repository contains a custom Docker image extending the official [CloudNativePG (CNPG)](https://cloudnative-pg.io/) PostgreSQL image with high-performance vector search and full-text search extensions.

## Extensions Included

- **[pgvectorscale](https://github.com/timescale/pgvectorscale)**: Scaling `pgvector` to hundreds of millions of vectors using DiskANN.
- **[pg_search (ParadeDB)](https://github.com/paradedb/paradedb)**: High-performance full-text search based on Tantivy (BM25).

## Directory Structure

- `Dockerfile`: Multi-architecture (`amd64`/`arm64`) build logic.
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
    ./build-image.sh
    ```
3.  **Run verification**:
    ```bash
    ./test-extensions.sh cnpg-vectorsearch:18.0 # the tag is PG_VERSION
    ```

## Usage in PostgreSQL

After deploying the image, you must enable the extensions in your database:

```sql
CREATE EXTENSION IF NOT EXISTS pg_search CASCADE;
CREATE EXTENSION IF NOT EXISTS vectorscale CASCADE;
```

_(Note: `vectorscale` will automatically enable `pgvector` as a dependency)._
