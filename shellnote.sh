#!/bin/bash

# Default values
content=""
expire=""
listall="false"
delete="false"

# Create directory $HOME
if [ ! -d "$HOME/.sticky" ]; then
    mkdir -p "$HOME/.sticky"
fi

# Function to check if a value is empty
function is_empty {
    if [ -z "$1" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# Function to parse expiration format
# Accepts formats like 5m, 2h, 1d, etc.
function parse_expire() {
    local val="$1"
    if [[ "$val" =~ ^([0-9]+)([mhd])$ ]]; then
        num="${BASH_REMATCH[1]}"
        unit="${BASH_REMATCH[2]}"
        case "$unit" in
            m) echo "$num minutes" ;;
            h) echo "$num hours" ;;
            d) echo "$num days" ;;
        esac
    else
        echo "not_valid"
    fi
}

# Function to delete a note
function delete_note() {

    sticky_dir="$HOME/.sticky"
    shopt -s nullglob
    files=("$sticky_dir"/sticky_*.txt)
    shopt -u nullglob

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No notes found."
        return
    fi

    echo "Select a note to delete:"
    PS3="Enter number (or press CTRL+C to cancel): "

    options=()
    for file in "${files[@]}"; do
        IFS=',' read -r created_at expire_at content < "$file"
        options+=("Created: $(date -d @$created_at) | Expires: $(date -d @$expire_at) | $content")
    done

    select opt in "${options[@]}"; do
        if [[ -z "$opt" ]]; then
            echo "Cancelled."
            break
        fi

        index=$((REPLY - 1))
        if [[ $index -ge 0 && $index -lt ${#files[@]} ]]; then
            echo "Deleting: ${files[$index]}"
            rm -f "${files[$index]}"
            echo "Note deleted."
            break
        else
            echo "Invalid selection."
        fi
    done

}



function list_notes() {
    local listall="$1"
    sticky_dir="$HOME/.sticky"
    current_time=$(date +%s)

    shopt -s nullglob
    for file in "$sticky_dir"/sticky_*.txt; do
        # Read the fields
        IFS=',' read -r created_at expire_at content < "$file"
        
        if [[ "$listall" == "true" ]]; then
            echo "Created: $(date -d @$created_at) | Expires: $(date -d @$expire_at) | ${content}"
        elif [[ "$expire_at" -ge "$current_time" ]]; then
            echo "Created: $(date -d @$created_at) | Expires: $(date -d @$expire_at) | ${content}"
        fi
    done
    shopt -u nullglob
}


# Parse named arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --new)
            if [ -z "$2" ] || [[ "$2" == --* ]]; then
                echo "Error: --new requires a value"
                exit 1
            fi
            content="$2"
            shift 2
            ;;
        --expire)
            if [ -z "$2" ] || [[ "$2" == --* ]]; then
                echo "Error: --expire requires a value"
                exit 1
            fi
            expire="$2"
            shift 2
            ;;
        --listall)
            listall="true"
            shift
            ;;
        --delete)
            delete="true"
            shift
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

# delete a note
if [[ "$delete" == "true" ]]; then
    delete_note
    exit 0
fi

# New note creation
if [[ "$(is_empty "$content")" == "false" && -n "$expire" ]]; then
    parsed_expire=$(parse_expire "$expire")

    if [[ "$parsed_expire" == "not_valid" ]]; then
        echo "Error: Invalid expiration format: $expire"
        exit 1
    fi

    # Convert to seconds + current time
    expire_date=$(date -d "now + $parsed_expire" +%s 2>/dev/null)

    if [[ -z "$expire_date" ]]; then
        echo "Error: Invalid expiration format: $expire"
        exit 1
    fi

    # Current date in seconds.
    current_date=$(date +%s)

    # Some sanity checks
    if [[ "$expire_date" -lt "$current_date" ]]; then
        echo "Error: Expiration date cannot be in the past."
        exit 1
    fi

    # Save the note with random name
    random_id=$(date +%s)_$RANDOM
    note_file="$HOME/.sticky/sticky_${random_id}.txt"
    echo "${current_date},${expire_date},${content}" > "$note_file"
    exit 0
fi

# list notes
list_notes "${listall}"
