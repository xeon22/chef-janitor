
require 'rake'
require 'fileutils'

def convert_to_epoch(days)
	return days - (60 * 60 * 24 * days.to_i)
end

def file_exceeds_age(file, days)
	time = Time.now
	tstamp = time.strftime("%b%d%Y-%H%M")
	
  filetime = ::File.new(file).mtime.to_i
  purge_time = time - convert_to_epoch(days)
  
  return true if filetime < purge_time.to_i
end

def filelist(path, recursive, include_glob, exclude_glob)
  # Iterate over all files to find the matching criteria for deletion
  files = FileList.new() do |f|
    exclude_glob.each do |t|
      r = Regexp.try_convert(t)
      f.exclude(r) unless r.nil?
    end
  end

  include_glob.each do |t|
    path = [path]
    path.push("**") if recursive
    path.push(t)

    files.include(::File.join(path))
  end

  return files
end

def oldfile(file,isold=false)
  if file_exceeds_age(file, new_resource.age)
    isold = true
  end

  return isold
end

def bigfile(file,isbig=false)
  c = SizeConversion.new(new_resource.size)
  maxsize = c.to_size(:b)
  if ::File.new(file).size > maxsize
    isbig = true
  end

  return isbig
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

  	@sizeunit = String.new
    @sizeint 	= size.partition(/\D{1,2}/).at(0).to_i
    unit = size.partition(/\D{1,2}/).at(1).to_s.downcase
  	
    case 
    when unit.match(/[kmgtpe]{1}/)
      # append the b
      @sizeunit = unit.concat('b')
    when unit.match(/[kmgtpe]{1}b/)
      @sizeunit = unit
    else
      @sizeunit = 'b'
    end
  end
  
  def to_size(unit, places=1)
  	# expects bytes, returns chosen unit
    bytes = @sizeint * @units[@sizeunit.to_sym]
    size = bytes / @units[unit]
    return size
    # return sprintf("%.#{places}f", bytes / unitval)
  end

  def from_size(places=1)
  	# expects any, returns bytes
    unitval = @units[@sizeunit.to_s.downcase.to_sym]
    return sprintf("%.#{places}f", @sizeint * unitval)
  end
end
