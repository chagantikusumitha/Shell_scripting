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
update_conf_file() {
    local view=$1
    local scale=$2
    local component=$3
    local count=$4
    shift 4  # Shift past the processed options
    local extra_arguments=("$@")

    if [[ $view == "auction" ]]; then
       view="vdopiasample"
    else
       view="vdopiasample-bid"
    fi

    # Construct the configuration line with variable values and extra arguments
    local config_line="$view ; $scale ; $component  ; vdopia-etl= $count ; extra_args= ${extra_arguments[*]}"

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

# Function to display usage information
usage() {
    echo "Usage: $0 -c <component> -s <scale> -v <view> -n <count> [extra_argument1 extra_argument2 ...]"
}

# Initialize variables
component=""
scale=""
view=""
count=""

# Parse command-line options
while getopts ":c:s:v:n:" opt; do
  case $opt in
    c)
      component="$OPTARG"
      ;;
    s)
      scale="$OPTARG"
      ;;
    v)
      view="$OPTARG"
      ;;
    n)
      count="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      usage
      exit 1
      ;;
  esac
done

# Shift to the next set of arguments
shift $((OPTIND - 1))

# Validate required options
if [ -z "$component" ] || [ -z "$scale" ] || [ -z "$view" ] || [ -z "$count" ]; then
    echo "Error: Missing required options. Please provide -c, -s, -v, and -n."
    usage
    exit 1
fi

# Validate the component, scale, view, and count
if ! validate_component "$component"; then
    echo "Invalid component: $component"
    exit 1
fi

if ! validate_scale "$scale"; then
    echo "Invalid scale: $scale"
    exit 1
fi

if ! validate_view "$view"; then
    echo "Invalid view: $view"
    exit 1
fi

if ! validate_count "$count"; then
    echo "Invalid count: $count"
    exit 1
fi

# Update the configuration file with extra arguments
update_conf_file "$view" "$scale" "$component" "$count" "$@"
echo "Conf file updated successfully."
