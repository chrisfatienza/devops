#!/usr/bin/env python

import httplib
import urllib

def main():
    # Adjust the URL as needed
    url = "10.1.3.12:900"
    path = "/login"  # Adjust the path as needed

    # Data for the POST request
    data = {
	"User": "C_atienza",
        "password": "@t13nz@CFChrs522@",
        "choice": "1"
    }

    # Encode the data for the POST request
    encoded_data = urllib.urlencode(data)

    # Create an HTTPS connection
    connection = httplib.HTTPSConnection(url)

    # Perform the POST request
    headers = {"Content-type": "application/x-www-form-urlencoded"}
    connection.request("POST", path, encoded_data, headers)

    response = connection.getresponse()
    content = response.read()

    print(content)

if __name__ == "__main__":
    main()
