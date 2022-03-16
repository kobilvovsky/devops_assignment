#!/usr/bin/python
import sys
import paramiko
import tldextract
import csv
import os

# Set workstation credentials
workstation_ip = "13.49.66.94"
workstation_usr = 'ubuntu'
workstation_pw = os.environ['WORKSTATION_PW']  # Need to set 'WORKSTATION_PW' (password) as env. variable

# Establish SSH connection to workstation
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(hostname=workstation_ip, username=workstation_usr, password=workstation_pw)

# Build and execute curl command to get HTML page
curl_command = f'curl http://{str(sys.argv[1])}/Test/'
stdin, stdout, stderr = client.exec_command(command=curl_command)

# Parse stdout (HTML page)
lines = stdout.readlines()
urls = []
for line in lines:
    link_line = line.find('<h3>')
    if link_line != -1:
        begin_idx = line.find('"', link_line)
        end_idx = line.find('"', begin_idx + 1)
        link = line[begin_idx + 1: end_idx]
        urls.append(link)

domain_names = [tldextract.extract(url).domain for url in urls]

# Create data and CSV
headers = ['URL', 'Domain']
data = []
for i in range(len(domain_names)):
    data.append([urls[i], domain_names[i]])

try:
    with open('domains_result.csv', 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(headers)
        writer.writerows(data)

    print("##### Successfully created CSV file #####")

except Exception as ex:
    print(ex)
