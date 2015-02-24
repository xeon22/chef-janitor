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

require 'chef/provider'


class Chef
  class Provider
    class JanitorSweep < Chef::Provider

      def whyrun_supported?
        true
      end

      # We MUST override this method in our custom provider
      def load_current_resource
        # Here we keep the existing version of the resource
        # if none exists we create a new one from the resource we defined earlier
        @current_resource ||= Chef::Resource::JanitorSweep.new(new_resource.name)

        # Now we need to set up any resource defaults
        @current_resource.path(new_resource.name)
        @current_resource.include_only(new_resource.include_only)
        @current_resource.exclude_all(new_resource.exclude_all)
        @current_resource.directory_size(new_resource.directory_size)
        @current_resource.age(new_resource.age)
        @current_resource.size(new_resource.size)
        @current_resource.recursive(new_resource.recursive)
        @current_resource
      end

      # Retrieve a list of files in the path provided.
      #
      # return [Hash]
      #
      def get_file_list
        # Iterate over all files to find the matching criteria for deletion
        Janitor::Directory.new(
            @current_resource.path,
            @current_resource.recursive
        )
      end

      def action_purge
        updated = false

        unless Dir.exists?(@current_resource.path)
          Chef::Application.fatal! "Directory #{@current_resource.path} not found"
        end

        #
        # Build a list of files to process
        #
        fl = get_file_list

        case
          when @current_resource.include_only
            Chef::Log.info "Including only files following the supplied regex: #{@current_resource.include_only}"
            fl.include_only(Regexp.union(@current_resource.include_only))
          when @current_resource.exclude_all
            Chef::Log.info "Excluding all files following the supplied regex: #{@current_resource.exclude_all}"
            fl.exclude_all(Regexp.union(@current_resource.exclude_all))
        end

        del_files = {}

        case
          when @current_resource.age
            del_files.merge!(fl.older_than(@current_resource.age))
          when @current_resource.size
            del_files.merge!(fl.larger_than(@current_resource.size))
          when @current_resource.directory_size
            del_files.merge!(fl.to_dir_size(@current_resource.directory_size))
        end

        longest_str = del_files.keys.group_by(&:size).max.first unless del_files.size == 0
        Chef::Log.info("Total of #{del_files.to_hash.length} files to process")

        del_files.each do |fname, data|
          time_str = Time.at(data[:mtime]).strftime("%Y-%m-%d")
          units    = Janitor::SizeConversion.new("#{data[:size]}b").to_size(:mb)
          c_string = "delete %-#{longest_str}s => %-#{time_str.length}s %8s MB" % [fname, time_str, units]

          converge_by(c_string) do
            #
            # Wrap the delete in a file resources for tracking and better visibility with reporting
            #
            f = Chef::Resource::File.new(fname,run_context)
            f.backup false
            f.run_action(:delete)
          end
          updated = true
        end
        @current_resource.updated_by_last_action(updated)
      end
    end

    class JanitorDirectory < JanitorSweep

      def whyrun_supported?
        true
      end

      # We MUST override this method in our custom provider
      def load_current_resource
        super
        # Here we keep the existing version of the resource
        # if none exists we create a new one from the resource we defined earlier
        @current_resource ||= Chef::Resource::JanitorDirectory.new(new_resource.name)
      end
    end
  end
end
