#
# Cookbook Name:: file_cleaner
# Provider:: default
#

# An lwrp for cleaning up directories

action :purge do
  raise "Directory #{new_resource.path} not found" unless ::Dir.exists?(new_resource.path)
  
  # Iterate over all files to find the matching criteria for deletion
  fl = filelist(new_resource.path, new_resource.recursive, new_resource.include_files, new_resource.exclude_files)

  fl.each do |f|
		Chef::Log.debug("Examining file: #{f}")
		case
		when !new_resource.age.nil?
			Chef::Log.debug("Max file age attribute defined to #{new_resource.age} days")
			if oldfile(f)
        begin
          ::FileUtils.rm_f(f)
          Chef::Log.info("#{new_resource.resource_name}[#{new_resource.name}] file #{f} exceeds age of #{new_resource.age} days: action #{new_resource.action} (#{new_resource.defined_at})")
        rescue Exception=>e
          Chef::Log.warn("Unable to delete #{f}: #{e}")
        end
			end

		when !new_resource.size.nil?
			if bigfile(f)
        begin
          ::FileUtils.rm_f(f)
          Chef::Log.info("#{new_resource.resource_name}[#{new_resource.name}] file #{f} exceeds size #{new_resource.size}: action #{new_resource.action.to_s} (#{new_resource.defined_at})")
        rescue Exception=>e
          Chef::Log.warn("Unable to delete #{f}: #{e}")
        end
			end

		when (new_resource.age.nil? && new_resource.size.nil?)
      begin
        ::FileUtils.rm_f(f)
        Chef::Log.info("#{new_resource.resource_name}[#{new_resource.name}] file #{f} no extra critiria defined: action #{new_resource.action} (#{new_resource.defined_at})")
      rescue Exception=>e
        Chef::Log.warn("Unable to delete #{f}: #{e}")
      end
		else
			Chef::Log.debug("Cannot determine suitable rule for deletion for file: #{f}")
		end
	end
end
