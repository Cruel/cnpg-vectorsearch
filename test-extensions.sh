#!/bin/bash
set -e

IMAGE_NAME=${1:-test-image:latest}

echo "Running verification test on image: $IMAGE_NAME"

docker run --rm \
  -e POSTGRES_PASSWORD=test \
  "$IMAGE_NAME" \
  bash -c "
    set -e
    echo 'Initializing temporary database...'
    initdb -D /tmp/pgdata > /dev/null
    
    echo 'Starting PostgreSQL...'
    postgres -D /tmp/pgdata -k /tmp > /dev/null 2>&1 & 
    
    timeout=30
    until pg_isready -h /tmp || [ \$timeout -eq 0 ]; do
        sleep 1
        ((timeout--))
    done
    
    if [ \$timeout -eq 0 ]; then
        echo 'Error: PostgreSQL failed to start'
        exit 1
    fi

    echo 'Creating extensions...'
    psql -h /tmp -U postgres -d postgres -c 'CREATE EXTENSION IF NOT EXISTS pg_search;'
    psql -h /tmp -U postgres -d postgres -c 'CREATE EXTENSION IF NOT EXISTS vectorscale CASCADE;'
    psql -h /tmp -U postgres -d postgres -c 'CREATE EXTENSION IF NOT EXISTS vchord;'
    
    echo 'Verifying installation...'
    psql -h /tmp -U postgres -d postgres -c '\\dx'
    
    echo 'Test passed successfully!'
  "
