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

action :purge do
  name        = new_resource.name
  path        = new_resource.path
  age         = new_resource.age
  size        = new_resource.size
  recursive   = new_resource.recursive
  includes    = new_resource.includes
  excludes    = new_resource.excludes
  debug_mode  = new_resource.debug_mode

  action      = new_resource.action
  defined_at  = new_resource.defined_at

  raise "Directory #{path} not found" unless ::Dir.exists?(path)
  
  # Iterate over all files to find the matching criteria for deletion
  fl = Janitor.file_list(path, recursive, includes, excludes)

  Chef::Log.info(fl)

  fl.each do |f|
		Chef::Log.debug("Examining file: #{f}")
		case
		when not(age.nil?)
			Chef::Log.debug("Max file age attribute defined to #{age} days")
			if Janitor.oldfile(f,age)
        begin
          ::FileUtils.rm_f(f, verbose => true) unless debug_mode
          Chef::Log.info("Purging file older than #{age} days: #{f}")
          new_resource.updated_by_last_action(true)
        rescue Exception=>e
          Chef::Log.warn("Unable to delete #{f}: #{e.message}")
        end
			end

		when not(size.nil?)
			if Janitor.bigfile(f,size)
        begin
          ::FileUtils.rm_f(f) unless debug_mode
          Chef::Log.info("Purging file exceeding #{size}: #{f}")
          new_resource.updated_by_last_action(true)
        rescue Exception=>e
          Chef::Log.warn("Unable to delete #{f}: #{e.message}")
        end
			end

		when not(age.nil? && size.nil?)
      begin
        ::FileUtils.rm_f(f) unless debug_mode
        Chef::Log.info("File #{f} no extra critiria defined: action #{new_resource.action} (#{new_resource.defined_at})")
        new_resource.updated_by_last_action(true)
      rescue Exception=>e
        Chef::Log.warn("Unable to delete #{f}: #{e}")
      end
		else
			Chef::Log.debug("Cannot determine suitable rule for deletion for file: #{f}")
		end
	end
end
