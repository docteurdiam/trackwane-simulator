class Parser

  def initialize(logger)
    @logger = logger
  end

  def parse(line, imei_number)
    line = line.chomp
    return nil if is_invalid?(line)
    begin
      data = CSV.parse(line)
    rescue Exception => e
      @logger.error "Failed to parse \"#{line}\""
      @logger.error e
    end
    create_event(data[0], imei_number)
  end

  def create_event(data, imei_number)
  {
      date: data[1].gsub('"', ''),
      imei_number: imei_number,
      latitude: data[2].gsub('"', ''),
      longitude: data[3].gsub('"', ''),
      speed: data[4].gsub('"', ''),
      gps_signal: data[5].gsub('"', ''),
      heading: data[6].gsub('"', '')
    }
  end

  def is_invalid?(line)
    !line || line == "" || !!(line =~ /IMEI Traceur/)  || !!(line =~ /Alarme:/) || !!(line =~ /Total:/)
  end

end
