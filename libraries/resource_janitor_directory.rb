#
# Cookbook Name:: janitor
# Resource:: directory
#

# Currently only one action and that is to purge the files

=begin
actions :purge
default_action :purge

attribute :path, kind_of: String, :name_attribute => true
attribute :include_only, kind_of: Array, :default => nil
attribute :exclude_all, kind_of: Array, :default => nil
attribute :age, kind_of: Integer, :default => nil # Days
attribute :size, kind_of: String, regex: /\d+[kmgtpe]{1}b{0,1}/i, :default => nil
attribute :directory_size, kind_of: String, regex: /\d+[kmgtpe]{1}b{0,1}/i, :default => nil
attribute :recursive, kind_of: [TrueClass, FalseClass], :default => false
=end

require 'chef/resource'

class Chef
  class Resource
    class JanitorSweep < Chef::Resource
      # identity_attr :name

      def initialize(name, run_context=nil)
        super
        @resource_name   = :janitor_sweep                 # Bind ourselves to the name with an underscore
        @provider        = Chef::Provider::JanitorSweep  # We need to tie to our provider
        @action          = :purge                   # Define the default action
        @allowed_actions = [:purge]

        # Now we need to set up any resource defaults
        @name            = name
        @path            = name
      end

      # Define the attributes we set defaults for
      def path(arg=nil)
        # set_or_return is a magic function from Chef that does most of the heavy
        # lifting for attribute access.
        set_or_return(:path, arg, kind_of: [String])
      end

      def include_only(arg=nil)
        set_or_return(:include_only, arg, kind_of: [Array])
      end

      def exclude_all(arg=nil)
        set_or_return(:exclude_all, arg, kind_of: [Array])
      end

      def directory_size(arg=nil)
        set_or_return(:directory_size, arg, kind_of: [String], regex: /\d+[kmgtpe]{1}b{0,1}/i)
      end

      def age(arg=nil)
        set_or_return(:age, arg, kind_of: [Integer])
      end

      def size(arg=nil)
        set_or_return(:size, arg, kind_of: [String], regex: /\d+[kmgtpe]{1}b{0,1}/i)
      end

      def recursive(arg=false)
        set_or_return(:recursive, arg, kind_of: [TrueClass, FalseClass])
      end
    end

    class JanitorDirectory < JanitorSweep
      # identity_attr :name

      def initialize(name, run_context=nil)
        Chef::Log.warn "The janitor_directory resource is marked for deprecation:  Please use the janitor_sweep resource"
        super
        @resource_name   = :janitor_directory                 # Bind ourselves to the name with an underscore
        @provider        = Chef::Provider::JanitorDirectory  # We need to tie to our provider
      end
    end
  end
end
