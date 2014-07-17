name             "janitor"
maintainer       "Mark Pimentel"
maintainer_email "markpimentel22@gmail.com"
license          "Apache 2.0"
description      "A General Cookbook used to cleanup files and directories on nodes"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version    "1.0.3"

%w{windows redhat centos debian ubuntu mac_os_x mac_os_x_server}.each do |os|
  supports os
end
