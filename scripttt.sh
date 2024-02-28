#!/bin/bash

# Validate the input
function validate_input() {
    local component_name=$1
    local scale=$2
    local view=$3
    local count=$4

    if [[ $scale != "MID" && $scale != "HIGH" && $scale != "LOW" ]]; then
        echo "Invalid scale"
        return 1
    fi

    if [[ $view != "Auction" && $view != "Bid" ]]; then
        echo "Invalid view"
        return 1
    fi

    if [[ $count -gt 9 || $count -lt 0 ]]; then
        echo "Invalid count"
        return 1
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


}

# Get the input from the user
echo "Enter the component name- INGESTOR/JOINER/WRANGLER/VALIDATOR: "
read component_name

echo "Enter the scale- MID/HIGH/LOW: "
read scale

echo "Enter the view- Auction/Bid: "
read view

echo "Enter the count (Single digit): "
read count

# Validate the input
if ! validate_input $component_name $scale $view $count; then
    exit 1
fi


if [[ "$view" == "Auction" ]]; then
    conf_line="$view ; $scale ; $component_name ; ETL ; vdopiasample= $count"
elif [[ "$view" == "Bid" ]]; then
    conf_line="$view ; $scale ; $component_name ; ETL ; vdopiasample-bid= $count"
fi

# Update the data to sig.conf
sed -i "/$view/d" sig.conf
echo "$conf_line" >> sig.conf

cat sig.conf
