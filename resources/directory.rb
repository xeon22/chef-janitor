#
# Cookbook Name:: file_cleaner
# Resource:: directory
#

# Currently only one action and that is to purge the files

actions :purge

attribute :path,   	      :kind_of => String,		:name_attribute => true

# Based on the FileList method from rake
# You must include some pattern to have the method return something
attribute :include_files,	:kind_of => Array,		:regex => /()/,		:default => ["**/*"]

attribute :exclude_files,	:kind_of => Array,		:regex => /()/,		:default => ["**/*"]

# default in days
attribute :age,						:kind_of => Integer,	:default => nil

attribute :size,					:kind_of => String,		:regex => /\d+[kmgtpe]{1}b{0,1}/i, :default => nil

attribute :recursive,			:kind_of => [TrueClass,FalseClass],	:default => false
