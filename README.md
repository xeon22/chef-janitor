Description
===========
This cookbook is meant to keep order on a running node to purge files
on the filesystem that are unwanted.  You could also apply some criteria to the files
that are targeted such as glob patterns, age, and size.

Requirements
============
Chef, Linux

Actions
=======

* purge
  Purge the files in the directory as either the resource name,
  or the path attribute to the janitor_directory LWRP
  Can also apply criteria such age file age, file size
  
Attributes
==========
No attributes are required for the use of this cookbook

Usage
=====
An LWRP "janitor_directory" is provided for declaring a directory
for which to search in and purge files in that directory.
Some criteria can also be supplied to include an age and size threshold.

Examples
========

* This will delete all files with the .log extension in /tmp

> janitor_directory "/tmp" do
>   include_files	["*.log"]
>   action        :purge
> end

* This will delete all files in the /var/log directory recursively,
  that are larger than 1 MegaByte

> janitor_directory "/var/log" do
>   include_files ["*.log"]
>   size			"1M"
>   recursive		true
>   action 		:purge
> end

* This will delete all files in the /var/log directory recursively,
  that are older than 5 days

> janitor_directory "/var/log" do
>   include_files	["*.log"]
>   age			5
>   recursive		true
>   action 		:purge
> end

