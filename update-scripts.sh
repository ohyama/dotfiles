#!/bin/bash

cd `dirname $0`

echo "This will update ~/.my-scripts."
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Canceled."
    exit 1
fi

# my-scripts
cp -R ./.my-scripts/ ~/.my-scripts/

echo "Done."
