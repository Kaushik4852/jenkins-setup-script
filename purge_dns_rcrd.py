import requests

def fetch_dns_records(zone_id, auth_email, auth_token, record_type=None):
    # Set up headers for the API request
    headers = {
        'Content-Type': 'application/json',
        'X-Auth-Email': auth_email,
        'Authorization': f'Bearer {auth_token}'
    }

    # Construct the URL for fetching DNS records
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    
    # If record type is specified, add it to the URL as a filter
    if record_type:
        url += f"?type={record_type}"

    # Send GET request to Cloudflare API
    response = requests.get(url, headers=headers)

    # Check if request was successful (status code 200)
    if response.status_code == 200:
        return response.json()['result']
    else:
        print(f"Error fetching DNS records. Status code: {response.status_code}")
        return None

def delete_dns_record(zone_id, auth_email, auth_token, record_id):
    # Set up headers for the API request
    headers = {
        'Content-Type': 'application/json',
        'X-Auth-Email': auth_email,
        'Authorization': f'Bearer {auth_token}'
    }

    # Construct the URL for deleting the DNS record
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}"

    # Send DELETE request to Cloudflare API
    response = requests.delete(url, headers=headers)

    # Check if deletion was successful
    if response.status_code == 200:
        print(f"Record with ID {record_id} deleted successfully.")
    else:
        print(f"Failed to delete record with ID {record_id}. Status code: {response.status_code}")

def fetch_and_delete_records(zone_id, auth_email, auth_token, record_type=None, contains_string=None):
    # Fetch DNS records of the specified type, or all records if no type specified
    dns_records = fetch_dns_records(zone_id, auth_email, auth_token, record_type)

    if dns_records:
        # Delete each fetched DNS record
        for record in dns_records:
            if contains_string and contains_string in record['name']:
                delete_dns_record(zone_id, auth_email, auth_token, record['id'])
            elif not contains_string:
                delete_dns_record(zone_id, auth_email, auth_token, record['id'])

# Example usage:
if __name__ == "__main__":
    # Cloudflare credentials
    zone_id = ""
    auth_email = ""
    auth_token = ""
    
    # Specify the type of record you want to fetch and delete (e.g., A, CNAME, MX, TXT)
    # Set to None to delete all.
    record_type = "MX"  
    
    # Specify a string to filter records to be deleted
    contains_string = ""  

    # Fetch and delete DNS records
    fetch_and_delete_records(zone_id, auth_email, auth_token, record_type, contains_string)
