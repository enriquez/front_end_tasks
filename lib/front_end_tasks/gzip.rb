require 'zlib'

module FrontEndTasks
  class Gzip

    def self.compress(*files)
      files.each do |file|
        Zlib::GzipWriter.open(file + ".gz") do |gz|
          gz.mtime = File.mtime(file)
          gz.orig_name = file
          gz.write IO.binread(file)
        end
      end
    end

  end
end
