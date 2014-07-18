#
# Cookbook Name:: janitor
# Recipe:: cleanup
#
# Copyright 2014, Schuberg Philis
#

if !node['janitor'].nil? and !node['janitor']['directory'].nil? and !node['janitor']['directory'].empty?
  Chef::Log.info("janitor: #{node['janitor']['directory'].length} entries to process")
  node['janitor']['directory'].each do |dir|
    name = dir.first
    conf = dir.last

    janitor_directory "#{conf['path']}" do
      age		conf['age']		unless conf['age'].nil?
      size		conf['size']		unless conf['size'].nil?
      include_only	conf['include_only']	unless conf['include_only'].nil?
      exclude_all	conf['exclude_all']	unless conf['exclude_all'].nil?
      recursive		conf['recursive']	unless conf['recursive'].nil?
      action		:purge
    end
  end
end
