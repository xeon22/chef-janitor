#
# Cookbook Name:: file_cleaner
# Resource:: directory
#

# Currently only one action and that is to purge the files

actions :purge

attribute :path,   	      :kind_of => String,		:name_attribute => true
attribute :includes,	:kind_of => Array,		:regex => /()/
attribute :excludes,	:kind_of => Array,		:regex => /()/
attribute :age,						:kind_of => Integer,	:default => nil # Days
attribute :size,					:kind_of => String,		:regex => /\d+[kmgtpe]{1}b{0,1}/i, :default => nil
attribute :recursive,			:kind_of => [TrueClass,FalseClass],	:default => false
