# Cloudflare DNS Management Script

This Bash script provides a command-line interface to manage DNS records (A and CNAME) on Cloudflare. It uses the Cloudflare API to list, add, edit, and delete DNS records for a specified domain.

**Key Features:**

* **Domain-Based Management:** You provide the domain name, and the script automatically retrieves the corresponding Cloudflare zone ID.
* **Interactive Menu:** A user-friendly menu allows you to choose between listing, adding, editing, or deleting records.
* **A and CNAME Support:** Manages A and CNAME records.
* **API Token Security:** API token is loaded from a secure configuration file in the working directory of this script (`$PWD/cf_api_key`).
* **Clear Output:** Displays record information and success/error messages.

**Prerequisites:**

* **Cloudflare API Token:** You need a Cloudflare API token with DNS management permissions.
* **`jq`:** The script uses `jq` to parse JSON responses from the Cloudflare API. Install it using your system's package manager (e.g., `sudo apt-get install jq` on Debian/Ubuntu, `brew install jq` on macOS). NOTE: During my testing this worked natively on macOS Sequoia 15.3.2 with no extra packages needing to be installed.

**Setup:**

1.  **Create Configuration File:**
    * Create a file named `.cf_api_key` in the current working directory: `$PWD/.cf_api_key`.
    * Add your Cloudflare API token to this file:

        ```bash
        export CLOUDFLARE_API_TOKEN="your_api_token"
        ```

    * Replace `"your_api_token"` with your actual API token.
    * Set appropriate file permissions: `chmod 600 ~/.cf_api_key`.
2.  **Save the Script:**
    * Save the script to a file (e.g., `quickcfdns.sh`).
3.  **Make it Executable:**
    * Run `chmod +x quickcfdns.sh`.

**Usage:**

1.  **Run the Script:**

    ```bash
    ./quickcfdns.sh
    ```

2.  **Enter Domain Name:**
    * The script will prompt you to enter the domain name you want to manage.

    ```
    Enter your domain name: example.com
    ```

3.  **Use the Menu:**
    * The script will display a menu:

    ```
    Cloudflare DNS Management - example.com
    -------------------------
    1. List DNS Records
    2. Add DNS Record
    3. Edit DNS Record
    4. Delete DNS Record
    5. Exit
    Enter your choice:
    ```

**Examples:**

* **Listing DNS Records:**

    1.  Run the script and enter your domain.
    2.  Select option `1`.

    The script will display a list of A and CNAME records for your domain:

    ```
    Current DNS Records: name | type | value | Record ID
    ----------------------------------------------------
    [www.example.com](https://www.example.com) CNAME example.com your_record_id
    example.com A 192.168.1.10 your_record_id2
    ```

* **Adding a DNS Record:**

    1.  Run the script and enter your domain.
    2.  Select option `2`.
    3.  Enter the record name, type, and content when prompted.

    ```
    Enter record name (e.g., www): test
    Enter record type (A or CNAME): A
    Enter record content (IP address or hostname): 192.168.1.11
    ```

* **Editing a DNS Record:**

    1.  Run the script and enter your domain.
    2.  Select option `3`.
    3.  Enter the record ID and the new record name/content when prompted.

    ```
    Enter record ID to edit: your_record_id
    Enter new record name (leave blank to keep current): [new.example.com](https://www.google.com/search?q=new.example.com)
    Enter new record content (leave blank to keep current):
    ```

* **Deleting a DNS Record:**

    1.  Run the script and enter your domain.
    2.  Select option `4`.
    3.  Enter the record ID to delete.

    ```
    Enter record ID to delete: your_record_id
    ```

**Security Notes:**

* Storing API tokens directly in scripts is a security risk. This script loads the token from a configuration file with restricted permissions.
* Ensure your Cloudflare API token has only the necessary permissions.

**Contributing:**

Feel free to contribute to this script by submitting pull requests or reporting issues.
