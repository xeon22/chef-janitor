#
# Cookbook Name:: janitor
# Recipe:: default
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
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
