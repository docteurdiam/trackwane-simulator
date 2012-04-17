class Configuration

  def parse(filename)
    cfg = YAML.load_file(filename)

    unless Dir.exists?(cfg["working_directory"])
      raise "The working directory #{cfg["working_directory"]} does not exist"
    end

    event_files = Dir[File.join(cfg["working_directory"], "*.csv.gz")]
    unless event_files.size > 0
      raise "The working directory #{cfg["working_directory"]} does not contain any event files named {imei_number}.csv.gz"
    end

    unless File.writable?(cfg["working_directory"])
      raise "The working directory #{cfg["working_directory"]} cannot be written to"
    end

    cfg
  end

end