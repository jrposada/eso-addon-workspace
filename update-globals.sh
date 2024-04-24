#!/bin/bash

# Input and output file paths
eso_doc_file="../esoui/ESOUIDocumentation.txt"
workpsace_settings_file="./eso-addon-workspace.code-workspace"

if [ ! -f "$eso_doc_file" ]; then
    echo "Error: ESO documentation file does not exist at '$eso_doc_file'."
    exit 1
fi

if [ ! -f "$workpsace_settings_file" ]; then
    echo "Error: Workspace file does not exist at '$workpsace_settings_file'."
    exit 1
fi

# Temporary file for intermediate processing
temp_json="./temp.json"
temp_names="temp_names.json"

# Extract lines starting with exactly one '*' and process them
names=$(grep '^* ' "$eso_doc_file" | grep -E '^\* ([a-zA-Z0-9_]+(\([^)]*\))?)$' | sed -e 's/^* \([^()]*\).*/\1/' -e 's/ /_/g')

# Convert to JSON array and write to temporary file
echo "$names" | jq -R . | jq -s . > "$temp_names"

# Read the current JSON, update the specific key with new values using the temporary names file
jq --slurpfile names "$temp_names" '.settings."Lua.diagnostics.globals" = $names[0]' "$workpsace_settings_file" > "$temp_json"

# Move the temp file to the original JSON file to update it
mv "$temp_json" "$workpsace_settings_file"

# # Clean up (optional)
rm -f "$temp_json"
rm -f "$temp_names"

echo "The JSON file has been updated successfully."
