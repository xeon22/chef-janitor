#
# Cookbook Name:: janitor
# Provider:: directory
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

# An lwrp for cleaning up directories

def whyrun_supported?
  true
end

action :purge do
  name = new_resource.name
  path = new_resource.path
  age = new_resource.age
  size = new_resource.size
  recursive = new_resource.recursive
  include_only = new_resource.include_only
  exclude_all = new_resource.exclude_all

  raise "Directory #{path} not found" unless ::Dir.exists?(path)

  # Iterate over all files to find the matching criteria for deletion
  fl = Janitor::Directory.new(path, :recursive => recursive)

  fl.include_only(Regexp.union(include_only)) unless include_only.nil?
  fl.exclude_all(Regexp.union(exclude_all)) unless exclude_all.nil?

  Chef::Log.info("#{fl.to_hash.length} files to process")

  case
  when (!age.nil? and !size.nil?)
    # Execute both
    list = fl.older_than(age)

    begin
      longest_str = list.keys.group_by(&:size).max.first
    rescue NoMethodError
      Chef::Log.warn("*** Criteria supplied produces no results ***")
      longest_str = 1
    end

    list.each do |file, data|
      time_str = Time.at(data['mtime']).strftime("%Y-%m-%d")
      converge_by("delete %-#{longest_str}s => %-#{time_str.length}s" % [file, time_str]) do
        delete file
      end
    end

    list = fl.larger_than(size)
    longest_str = list.keys.group_by(&:size).max.first

    list.each do |file, data|
      convert = Janitor::SizeConversion.new("#{data[size]}b")
      converge_by("delete %-#{longest_str}s => %-8smb" % [file, convert.to_size(:mb)]) do
        file file do
          action  :delete
        end
      end
    end

  when !age.nil?
    # Age only
    list = fl.older_than(age)

    begin
      longest_str = list.keys.group_by(&:size).max.first
    rescue NoMethodError
      Chef::Log.warn("*** Criteria supplied produces no results ***")
      longest_str = 1
    end


    list.each do |file, data|
      time_str = Time.at(data['mtime']).strftime("%Y-%m-%d")
      converge_by("delete %-#{longest_str}s => %-#{time_str.length}s" % [file, time_str]) do
        file file do
          action  :delete
        end
      end
    end

  when !size.nil?
    # Size only
    list = fl.larger_than(size)

    begin
      longest_str = list.keys.group_by(&:size).max.first
    rescue NoMethodError
      Chef::Log.warn("*** Criteria supplied produces no results ***")
      longest_str = 1
    end

    list.each do |file, data|
      convert = Janitor::SizeConversion.new("#{data[size]}b")
      converge_by("delete %-#{longest_str}s => %-8smb" % [file, convert.to_size(:mb)]) do
        file file do
          action  :delete
        end
      end
    end

  else
    list = fl.larger_than(size)
    longest_str = list.keys.group_by(&:size).max.first

    list.each do |file, data|
      converge_by("delete %-#{longest_str}s" % [file]) do
        file file do
          action  :delete
        end
      end
    end
  end

  new_resource.updated_by_last_action(true)
end

