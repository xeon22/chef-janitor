#
# Cookbook Name:: janitor
# Recipe:: cleanup
#
# Copyright 2014, Schuberg Philis
#

cleanups = node['manage']['directory']['cleanup']
if !cleanups.nil?

  # log("cleanup: #{cleanups.length} entries to process")
  cleanups.sort.each do |jan_info|

    nam = jan_info.first
    jan = jan_info.last

    inc = !jan['include_only'].nil?	? jan['include_only']	: []
    exc = !jan['exclude_all'].nil?	? jan['exclude_all']	: []
    rec = !jan['recursive'].nil?	? jan['recursive']	: false
    dir =				  jan['path']
    age =				  jan['age']
    siz =				  jan['size']

    janitor_directory "#{dir}" do
      age		age unless age.nil?
      size		siz unless siz.nil?
      include_only	inc unless inc.nil?
      exclude_all	exc unless exc.nil?
      recursive		rec
      action		:purge
    end

  end

end

# vim: set sw=2:
