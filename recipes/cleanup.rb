#
# Cookbook Name:: janitor
# Recipe:: cleanup
#
# Copyright 2014, Schuberg Philis
#

if !node['janitor'].nil? and !node['janitor']['directory'].nil?

  Chef::Log.info("janitor: #{node['janitor']['directory'].length} entries to process")
  node['janitor']['directory'].sort.each do |jan_info|
    jan = jan_info.last
    janitor_directory "#{jan['path']}" do
      age		jan['age'] unless jan['age'].nil?
      size		jan['size'] unless jan['size'].nil?
      include_only	!jan['include_only'].nil? ? jan['include_only'] : []
      exclude_all	!jan['exclude_all'].nil?  ? jan['exclude_all']  : []
      recursive		!jan['recursive'].nil?    ? jan['recursive']    : false
      action		:purge
    end

  end

end
