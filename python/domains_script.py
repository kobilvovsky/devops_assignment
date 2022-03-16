#!/usr/bin/python

import tldextract
import csv


with open("html_output.txt", "r") as _:
    lines = _.readlines()

urls = []
for line in lines:
    link_line = line.find('<h3>')
    if link_line != -1:
        begin_idx = line.find('"', link_line)
        end_idx = line.find('"', begin_idx + 1)
        link = line[begin_idx + 1: end_idx]
        urls.append(link)

domain_names = [tldextract.extract(url).domain for url in urls]

headers = ['URL', 'Domain']
data = []
for i in range(len(domain_names)):
    data.append([urls[i], domain_names[i]])

try:
    with open('domains.csv', 'w', newline='') as f:
         writer = csv.writer(f)
         writer.writerow(headers)
         writer.writerows(data)

    print("###Successfully created CSV file###")

except Exception as ex:
    print(ex)

