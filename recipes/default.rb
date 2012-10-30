#
# Cookbook Name:: file_cleaner
# Recipe:: default
#

janitor_directory "/tmp" do
	include_files	["*.log", "*.yumtx", "*.pid"]
	action 				:purge
end

janitor_directory "logs_greater_than_10M" do
  path          "/var/log"
  include_files	["*.log"]
  size          "10M"
  recursive     true
  action 				:purge
end

janitor_directory "logs_older_than_30_days" do
  path          "/var/log"
  include_files	["*.old", "*.2012*", "*.log.*"]
  age           30
  recursive     true
  action 				:purge
end

janitor_directory "gzipped_logs" do
  path          "/var/log"
  include_files	["*.gz"]
  recursive     true
  action 				:purge
end
