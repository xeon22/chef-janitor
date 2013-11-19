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

module Janitor
  class Directory
    def initialize(path, recursive=false)
      raise "Directory not found: #{path}" unless File.directory?(path)
      # Iterate over all files to find the matching criteria for deletion
      if recursive
        path_str = File.join(path, '**', '*')
      else
        path_str = File.join(path, '*')
      end

      @file_table = Hash.new

      Dir[path_str].each do |file|
        fstat = File.stat(file)
        @file_table.store(
            file,
            {
                'ctime' => fstat.ctime.to_i,
                'mtime' => fstat.mtime.to_i,
                'size'  => fstat.size
            }
        )
      end
    end

    def older_than(days)
      purge_time = Time.now - (60 * 60 * 24 * days.to_i)

      list = @file_table.select do |file,data|
               data['mtime'] < purge_time.to_i
             end

      return list
    end

    def larger_than(size)
      list = @file_table.select do |file,data|
               c = SizeConversion.new(size.to_s)
               data['size'].to_f > c.to_size(:b).to_f
      end
      return list
    end

    def filter(regexp)
      @file_table.select do |file,data|
        file.match(Regexp.new(regexp))
      end
    end

    def get_list
      @file_table.each_key {|t| puts t }
      puts "Current number of files: #{@file_table.length}"
    end

    def to_hash
      return @file_table
    end
  end

  class SizeConversion
    def initialize(size)
      @units = {
          :b => 1,
          :kb => 1024**1,
          :mb => 1024**2,
          :gb => 1024**3,
          :tb => 1024**4,
          :pb => 1024**5,
          :eb => 1024**6
      }

      @size_int = size.partition(/\D{1,2}/).at(0).to_i
      unit = size.partition(/\D{1,2}/).at(1).to_s.downcase

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
      unit_val = @units[unit.to_s.downcase.to_sym]
      bytes = @size_int * @units[@size_unit.to_sym]
      size = bytes.to_f / unit_val.to_f
      return sprintf("%.#{places}f", size).to_f
    end

    def from_size(places=1)
      # expects any, returns bytes
      unit_val = @units[@size_unit.to_s.downcase.to_sym]
      return sprintf("%.#{places}f", @size_int * unit_val)
    end
  end
end
