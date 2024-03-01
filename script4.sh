#!/bin/bash

# Function to validate user input for component name
validate_component() {
    local component=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case $component in
        ingestor|joiner|wrangler|validator)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to validate user input for scale
validate_scale() {
    local scale=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case $scale in
        mid|high|low)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to validate user input for view
validate_view() {
    local view=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case $view in
        auction|bid)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to validate user input for count
validate_count() {
    local count=$1
    if [[ $count =~ ^[0-9]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to update the configuration file
# Function to update the configuration file
# Function to update the configuration file
# Function to update the configuration file
update_conf_file() {
    local view=$1
    local scale=$2
    local component=$3
    local count=$4 


    if [[ $view == "auction" ]]; then
       view="vdopiasample"
    else
       view="vdopiasample-bid"
    fi

    # Construct the configuration line with variable values
    local config_line="$view ; $scale ; $component  ; vdopia-etl= $count"

    # Append the configuration line to the end of the file
    echo "$config_line" > sig.conf

    # Check if the echo command succeeded
    if [ $? -eq 0 ]; then
        echo "Conf line appended successfully."
    else
        echo "Error: Failed to append conf line."
        exit 1
    fi
}

# Main script starts here
for ((i=1; i<=3; i++)); do
    echo "Enter Component Name [INGESTOR/JOINER/WRANGLER/VALIDATOR]: "
    read component
    if validate_component "$component"; then
        break
    elif [[ $i -eq 3 ]]; then
        echo "Error: Max attempts reached for component name. Exiting."
        exit 1
    else
        echo "Invalid component name. Please choose from INGESTOR, JOINER, WRANGLER, or VALIDATOR."
    fi
done

for ((i=1; i<=3; i++)); do
    echo "Enter Scale [MID/HIGH/LOW]: "
    read scale
    if validate_scale "$scale"; then
        break
    elif [[ $i -eq 3 ]]; then
        echo "Error: Max attempts reached for scale. Exiting."
        exit 1
    else
        echo "Invalid scale. Please choose from MID, HIGH, or LOW."
    fi
done

for ((i=1; i<=3; i++)); do
    echo "Enter View [auction/bid]: "
    read view
    if validate_view "$view"; then
        break
    elif [[ $i -eq 3 ]]; then
        echo "Error: Max attempts reached for view. Exiting."
        exit 1
    else
        echo "Invalid view. Please choose from Auction or Bid."
    fi
done

for ((i=1; i<=3; i++)); do
    echo "Enter Count [single digit]: "
    read count
    if validate_count "$count"; then
        break
    elif [[ $i -eq 3 ]]; then
        echo "Error: Max attempts reached for count. Exiting."
        exit 1
    else
        echo "Invalid count. Please enter a single digit."
    fi
done

update_conf_file "$view" "$scale" "$component" "$count"
echo "Conf file updated successfully."
