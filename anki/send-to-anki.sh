#!/bin/bash

# Prompt user for deck name
read -p "Enter the deck name: " deck_name

# Check if Anki is running
if ! pgrep -x "anki" > /dev/null
then
    echo "Anki must be running to use this script."
    exit 1
fi

# File containing card data
input_file="input.csv"

# Check if input file exists
if [[ ! -f "$input_file" ]]
then
    echo "Input file not found: $input_file"
    exit 1
fi

# Read each line from the CSV file
while IFS='|' read -r front back
do
    # JSON payload for AnkiConnect
    json_payload=$(cat <<EOF
{
    "action": "addNote",
    "version": 6,
    "params": {
        "note": {
            "deckName": "$deck_name",
            "modelName": "Basic",
            "fields": {
                "Front": "$front",
                "Back": "$back"
            },
            "options": {
                "allowDuplicate": false
            },
            "tags": []
        }
    }
}
EOF
)

    # Send the request to AnkiConnect
    response=$(curl -s -X POST http://localhost:8765 -d "$json_payload")

    # Check for errors in response
    if [[ $(echo $response | grep -o '"result":null') ]]; then
        echo "Error adding card with front: $front"
    else
        echo "Added card with front: $front"
    fi

done < "$input_file"

echo "All cards processed."

