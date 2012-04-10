require 'zip/zip'
require 'zip/zipfilesystem'

class Storage

  def self.unzip(file, output_dir)
    Zip::ZipFile.open(file) { |zip_file|
      zip_file.each { |f|
        zip_file.extract(f, File.join(output_dir, f.to_s))
      }
    }
  end

end