#
# Cookbook Name:: janitor
# Library:: util
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

class Janitor

  def initialize(path)
    raise "Directory not found: #{path}" unless File.directory?(path)
  end

  def self.convert_to_epoch(days)
  	return days - (60 * 60 * 24 * days.to_i)
  end
  
  def self.file_exceeds_age(file, days)
  	time = Time.now

    file_time = File.stat(file).mtime.to_i
    purge_time = time - convert_to_epoch(days)
    
    return true if file_time < purge_time.to_i
  end
  
  def self.file_list(path, recursive, includes, excludes)
    # Iterate over all files to find the matching criteria for deletion
    if recursive
      path_str = File.join(path, '**', '*')
    else
      path_str = File.join(path, '*')
    end

    files = Dir[path_str]

    Chef::Log.debug("#{files.length} files to process")

    files.select! do |f|
      regex_inc = Regexp.union(includes)
      f.match(regex_inc) unless regex_inc.nil?
    end

    Chef::Log.debug("#{files.length} files matched")
    return files
  end
  
  def self.oldfile(file,age)
    unless File.directory?(file)
      file_exceeds_age(file, age)
    end
  end
  
  def self.bigfile(file,size)
    unless File.directory?(file)
      c = SizeConversion.new(size)
      maxsize = c.to_size(:b)

      File.size?(file) > maxsize
    end
  end

  def self.longest_word(list)
    list.group_by(&:size).max.last
  end

  class SizeConversion
    def initialize(size)
    	@units = { 
      	:b  => 1,
        :kb => 1024**1,
        :mb => 1024**2,
        :gb => 1024**3,
        :tb => 1024**4,
        :pb => 1024**5,
        :eb => 1024**6
      }
  
    	@size_unit  = String.new
      @size_int 	= size.partition(/\D{1,2}/).at(0).to_i
      unit        = size.partition(/\D{1,2}/).at(1).to_s.downcase
    	
      case 
      when unit.match(/[kmgtpe]{1}/)
        # append the b
        @size_unit = unit.concat('b')
      when unit.match(/[kmgtpe]{1}b/)
        @size_unit = unit
      else
        @size_unit = 'b'
      end
    end
    
    def to_size(unit, places=1)
    	# expects bytes, returns chosen unit
      bytes = @size_int * @units[@size_unit.to_sym]
      size = bytes / @units[unit]
      # return sprintf("%.#{places}f", bytes / unit_val)
    end
  
    def from_size(places=1)
    	# expects any, returns bytes
      unit_val = @units[@size_unit.to_s.downcase.to_sym]
      return sprintf("%.#{places}f", @size_int * unit_val)
    end
  end
end
