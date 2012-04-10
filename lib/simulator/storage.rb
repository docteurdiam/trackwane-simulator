require 'zip/zip'
require 'zip/zipfilesystem'

class Storage

  def self.unzip(file, output_dir)
    Zip::ZipFile.open(file) { |zip_file|
      zip_file.each { |f|
        filename = File.join(output_dir, f.to_s)
        File.delete(filename) if File.exists?(filename)
        zip_file.extract(f, filename)
      }
    }
  end

end