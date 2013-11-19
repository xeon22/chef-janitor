#
# Cookbook Name:: file_cleaner
# Resource:: directory
#

# Currently only one action and that is to purge the files

actions :purge
default_action  :purge

attribute :path, :kind_of => String, :name_attribute => true
attribute :include_only, :kind_of => Array, :default => nil
attribute :exclude_all, :kind_of => Array, :default => nil
attribute :age, :kind_of => Integer, :default => nil # Days
attribute :size, :kind_of => String, :regex => /\d+[kmgtpe]{1}b{0,1}/i, :default => nil
attribute :recursive, :kind_of => [TrueClass, FalseClass], :default => false
