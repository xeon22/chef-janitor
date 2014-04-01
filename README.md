# Description

This cookbook is meant to keep order on a running node to purge files
on the filesystem that are unwanted.  You could also apply some criteria to the files
that are targeted such as regular expressions, age, and size.

# Requirements

Chef, Linux

## Platform:

* redhat
* centos
* ubuntu
* debian
* macos
* Good possibility it will work in windows as all path references have been abstracted. (Not tested)

## Cookbooks:

*No cookbooks defined*

# Resources

* [janitor_directory](#janitor_directory)

## janitor\_directory

### Actions

- purge:  Default action.

### Attribute Parameters

### janitor\_directory

* `path` - Resource name or path parameter will pass the path to be examined to the lwrp.

* `include_only`
    * Array of regular expressions that are applied to the list of files present in `path`.
    * This will eliminate all entries except for those matching the regular expressions.
    * Defaults to `nil`.

* `exclude_all`
    * Array of regular expressions that are applied to the list of files present in `path`.
    * This will eliminate all entries matching the regular expressions.
    * Defaults to `nil`.

* `age` - Files older than `age` (in days) will be deleted.
    * Defaults to `nil`.

* `size` - Files larger than the `size` (in b,M,G,T,P) will be deleted.
    * Defaults to `nil`.

* `directory_size` - Old files are removed until directory is at or below given size
    * Defaults to `nil`.

* `recursive` - enable recursive searching from the path indicated in the resource
    * Defaults to `false`

### Examples

```
    #  Delete all files in /var/log with the .gz extension
    janitor_directory "/var/log" do
      include_only    [/.*\.gz$]
      action          :purge
    end

    #  Delete all files in /var/log with the .gz and numeric extension
    janitor_directory "/var/log" do
      include_only    [/.*\.gz$/,/.*\.\d/]
      action          :purge
    end

    # Delete all files in /var/log (recusively) with the .gz and numeric extension
    # And are also larger than 10M and older than 30 days
    janitor_directory "/var/log" do
      include_only    [/.*\.gz$/,/.*\.\d/]
      age             30
      size            "10M"
      recursive       true
      action          :purge
    end
    
    # Delete old files fom /var/log until directory is below 2G
    janitor_directory "/var/log" do
      directory_size  "2G"
      action          :purge
    end
```
