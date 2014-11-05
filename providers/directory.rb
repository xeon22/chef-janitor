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
  dir_size = new_resource.directory_size
  recursive = new_resource.recursive
  include_only = new_resource.include_only
  exclude_all = new_resource.exclude_all
  updated = false

  raise "Directory #{path} not found" unless ::Dir.exists?(path)

  # Iterate over all files to find the matching criteria for deletion
  fl = Janitor::Directory.new(path, :recursive => recursive)

  fl.include_only(Regexp.union(include_only)) unless include_only.nil?
  fl.exclude_all(Regexp.union(exclude_all)) unless exclude_all.nil?

  Chef::Log.info("#{fl.to_hash.length} files to process")
  
  del_files = {} 
  del_files.merge!(fl.older_than(age)) unless age.nil?
  del_files.merge!(fl.larger_than(size)) unless size.nil?
  del_files.merge!(fl.to_dir_size(dir_size)) unless dir_size.nil?

  longest_str = del_files.keys.group_by(&:size).max.first unless del_files.size == 0

  del_files.each do |fname,data|
    time_str = Time.at(data['mtime']).strftime("%Y-%m-%d")
    convert  = Janitor::SizeConversion.new("#{data['size']}b").to_size(:mb)
    c_string = "delete %-#{longest_str}s => %-#{time_str.length}s %-8s MB" % [fname,time_str,convert]

    converge_by(c_string) do
      file fname do
        backup false
        action :delete
      end
    end
    updated = true
  end
  new_resource.updated_by_last_action(updated)
end

