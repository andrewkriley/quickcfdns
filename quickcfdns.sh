#!/bin/bash

# Configuration file for API credentials
CONFIG_FILE="$PWD/.cf_api_key"

# Function to load API credentials from the config file
load_config() {
  if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
      echo "Error: CLOUDFLARE_API_TOKEN not set in $CONFIG_FILE"
      exit 1
    fi
  else
    echo "Error: Configuration file $CONFIG_FILE not found."
    echo "Please create it with CLOUDFLARE_API_TOKEN variable."
    exit 1
  fi
}

# Function to get the zone ID from the domain name
get_zone_id() {
  local domain="$1"
  local zones=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json")

  local zone_id=$(echo "$zones" | jq -r ".result[] | select(.name == \"$domain\") | .id")

  if [ -z "$zone_id" ]; then
    echo "Error: Zone not found for domain: $domain"
    exit 1
  fi

  echo "$zone_id"
}

# Function to list DNS records
list_records() {
  local zone_id="$1"
  local records=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json")

  local record_count=$(echo "$records" | jq '.result | length')

  if [[ "$record_count" -gt 0 ]]; then
    echo "Current DNS Records: name | type | value | Record ID"
    echo "----------------------------------------------------"
    echo "$records" | jq -r '.result[] | select(.type == "A" or .type == "CNAME") | "\(.name) \(.type) \(.content) \(.id)"'
  else
    echo "No A or CNAME records found."
  fi
}

# Function to add a DNS record
add_record() {
  local zone_id="$1"
  read -p "Enter record name (e.g., www): " name
  read -p "Enter record type (A or CNAME): " type
  read -p "Enter record content (IP address or hostname): " content

  local payload="{\"type\":\"$type\",\"name\":\"$name\",\"content\":\"$content\",\"ttl\":120,\"proxied\":false}"

  local result=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "$payload")

  local success=$(echo "$result" | jq -r '.success')
  if [[ "$success" == "true" ]]; then
    echo "Record added successfully."
  else
    echo "Failed to add record: $(echo "$result" | jq -r '.errors[0].message')"
  fi
}

# Function to edit a DNS record
edit_record() {
  local zone_id="$1"
  read -p "Enter record ID to edit: " record_id
  read -p "Enter new record name (leave blank to keep current): " new_name
  read -p "Enter new record content (leave blank to keep current): " new_content

  local current_record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json")

  local old_name=$(echo "$current_record" | jq -r '.result.name')
  local old_content=$(echo "$current_record" | jq -r '.result.content')

  local update_name="${new_name:-$old_name}"
  local update_content="${new_content:-$old_content}"

  local payload="{\"name\":\"$update_name\",\"content\":\"$update_content\"}"

  local result=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "$payload")

  local success=$(echo "$result" | jq -r '.success')
  if [[ "$success" == "true" ]]; then
    echo "Record edited successfully."
  else
    echo "Failed to edit record: $(echo "$result" | jq -r '.errors[0].message')"
  fi
}

# Function to delete a DNS record
delete_record() {
  local zone_id="$1"
  read -p "Enter record ID to delete: " record_id

  local result=$(curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json")

  local success=$(echo "$result" | jq -r '.success')
  if [[ "$success" == "true" ]]; then
    echo "Record deleted successfully."
  else
    echo "Failed to delete record: $(echo "$result" | jq -r '.errors[0].message')"
  fi
}

# Main menu
main_menu() {
  read -p "Enter your domain name: " domain
  local zone_id=$(get_zone_id "$domain")

  while true; do
    echo "Cloudflare DNS Management - $domain"
    echo "-------------------------"
    echo "1. List DNS Records"
    echo "2. Add DNS Record"
    echo "3. Edit DNS Record"
    echo "4. Delete DNS Record"
    echo "5. Exit"
    read -p "Enter your choice: " choice

    case "$choice" in
    1) list_records "$zone_id" ;;
    2) add_record "$zone_id" ;;
    3) edit_record "$zone_id" ;;
    4) delete_record "$zone_id" ;;
    5) exit 0 ;;
    *) echo "Invalid choice." ;;
    esac
  done
}

# Main script execution
load_config
main_menu