# Description

This cookbook is meant to keep order on a running node to purge files
on the filesystem that are unwanted.  You could also apply some criteria to the files
that are targeted such as regular expressions, age, and size.

# Requirements

Chef, Linux, Windows

## Platform:

* redhat
* centos
* ubuntu
* debian
* macos
* windows

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

* `recursive` - enable recursive searching from the path indicated in the resource
    * Defaults to `false`

### Attribute driven

Can also be driven by attribute settings by running "recipe[janitor::cleanup]"
This can be used by different cookbooks maintaining different directories without
actually having to call the resource

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

    # same examples as above:
    default['manage']['directory']['cleanup']['some-name']['directory'] = "/var/log"
    default['manage']['directory']['cleanup']['some-name']['include_only'] = [/.*\.gz$]

    default['manage']['directory']['cleanup']['some-other-name']['directory'] = "/var/log"
    default['manage']['directory']['cleanup']['some-other-name']['include_only'] = [/.*\.gz$,/.*\.\d/]

    default['manage']['directory']['cleanup']['some-third-name']['directory'] = "/var/log"
    default['manage']['directory']['cleanup']['some-third-name']['include_only'] = [/.*\.gz$]
    default['manage']['directory']['cleanup']['some-third-name']['age'] = 30
    default['manage']['directory']['cleanup']['some-third-name']['size'] = "10M"
    default['manage']['directory']['cleanup']['some-third-name']['recursive'] = true
```
