#!/bin/bash

indent_size="  "

# Function to generate JSON for a directory
generate_json() {
    local dir_path=$1
    local level=$2
    local indent=$(printf "%*s" $((level * ${#indent_size})) "")
    local json=""

    json+="${indent}{\n"
    json+="${indent}${indent_size}\"name\": \"$(basename "$dir_path")\",\n"
    json+="${indent}${indent_size}\"contentType\": \"directory\",\n"
    json+="${indent}${indent_size}\"items\": [\n"

    local first_item=true

    # Process directories first
    DIRECTORIES=$(find "$dir_path" -mindepth 1 -maxdepth 1 -type d | LC_COLLATE=zh_CN.UTF-8 sort)
    for item in $DIRECTORIES; do
        if [ "$first_item" = false ]; then
            json+=",\n"
        fi
        first_item=false
        json+=$(generate_json "$item" $((level + 2)))
    done

    # Process files next
    FILES=$(find "$dir_path" -mindepth 1 -maxdepth 1 -type f | LC_COLLATE=zh_CN.UTF-8 sort)
    for item in $FILES; do
        if [ "$first_item" = false ]; then
            json+=",\n"
        fi
        first_item=false
        local item_indent=$(printf "%*s" $(((level + 2) * ${#indent_size})) "")
        json+="${item_indent}{\n"
        json+="${item_indent}${indent_size}\"name\": \"$(basename "$item")\",\n"
        json+="${item_indent}${indent_size}\"contentType\": \"file\"\n"
        json+="${item_indent}}"
    done
    json+="\n"

    json+="${indent}${indent_size}]\n"
    json+="${indent}}"

    echo -e "$json"
}

# Generate JSON for the root directory
root_dir="resource"
json=$(generate_json "$root_dir" 0)

# Write JSON to data.json
echo -e "$json" > data.json