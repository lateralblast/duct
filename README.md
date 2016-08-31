![alt tag](https://raw.githubusercontent.com/lateralblast/duct/master/duct.jpg)

DUCT
====

DC Utilisation/Capacity Tool

Introduction
------------

This is a tool to help with DC Utilisation/Capacity calculations.

It is designed to calculate and chart usage in terms of:

- Systems
- Racks
- Power

Currently the tool is Sun/Oracle focused, but can easily be extended to include other vendors.

License
-------

This software is licensed as CC-BA (Creative Commons By Attrbution)

http://creativecommons.org/licenses/by/4.0/legalcode

Features
--------

Currently the tool has the ability to:

- Import MOS Sun System Handbook HTML pages into a CSV file with system data do that it is more searchable
- Clean up of some commonly used data such as the number of processors and rack units
- Do some capacity calculations and charting based on a MOS system extract in CSV format
- Search MOS Sun System Handbook HTML pages for information
- Mask data from MOS extract, e.g. (Serial Number, Support Identifier, Company and Contact details)

Planned features:

- Be able to import a CSV with server and rack locations and export a diagram


Requirements
------------

Required Ruby Gems:

- rubygems
- csv
- securerandom
- date
- multiset
- faker 
- nokogiri
- getopt

Optional Ruby Gems (for webserver):

- sinatra
- chartkick
- erb

Packages required for webserver:

- <a href="http://www.chartjs.org/">Chart.js</a>

To search and import MOS Sun System Handbook HTML pages a valid MOS account is required.
Save the HTML files into a directory and point the script at the directory.

Usage
-----

Import MOS HTML pages to CSV and export to file:

```
$ ./duct.rb --vendor sun --output data/mos_all.csv
```

Return only the Rack Unit information for a specific model:

```
$ ./duct.rb --vendor sun  --model t5-4 --search "rack units"
"Model","rack units"
"T5-4","5"
```

Return number of processors and cores for a specific model:

```
./duct.rb --vendor sun  --model t5-4 --search "processor number"
"Model","processor number"
"T5-4","2,4:16"
```

Run webserver:

```
$ ./webserver.rb 
[2016-08-31 16:01:40] INFO  WEBrick 1.3.1
[2016-08-31 16:01:40] INFO  ruby 2.3.0 (2015-12-25) [x86_64-darwin15]
== Sinatra (v1.4.7) has taken the stage on 4567 for development with backup from WEBrick
[2016-08-31 16:01:40] INFO  WEBrick::HTTPServer#start: pid=96269 port=4567
```

Example chart output:

![alt tag](https://raw.githubusercontent.com/lateralblast/duct/master/chart1.png)


