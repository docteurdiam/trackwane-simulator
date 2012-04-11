class Configuration

  def parse(filename)
    cfg = YAML.load(filename)
    unless Dir.exists?(cfg["working_directory"])
      raise "The working directory #{cfg["working_directory"]} does not exist"
    end
    unless File.writable?(cfg["working_directory"])
      raise "The working directory #{cfg["working_directory"]} cannot be written to"
    end
    cfg
  end

end