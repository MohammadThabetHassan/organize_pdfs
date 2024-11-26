#!/bin/bash

ROOT_DIR=${1:-root_folder}

declare -A categories=(
    ["Programming"]="Python Java C"
    ["AI"]="Machine_Learning Neural_Networks"
    ["Math"]="Linear_Algebra Calculus"
    ["Database"]="SQL NoSQL"
    ["Security"]="Cryptography Network_Security"
    ["Others"]=""
)

for category in "${!categories[@]}"; do
    mkdir -p "$ROOT_DIR/$category"
    for subcategory in ${categories[$category]}; do
        mkdir -p "$ROOT_DIR/$category/$subcategory"
    done
done

echo "Directory structure created successfully in '$ROOT_DIR'."

