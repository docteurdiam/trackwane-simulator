class Agent

  def run(filename, sleep_time, error_factor, target, logger)
    while true do
      simulate_tracker(filename, sleep_time, error_factor, target, logger)
    end
  end

  def simulate_tracker(filename, sleep_time, error_factor, target, logger)
    imei_number = File.basename(filename, ".csv.gz")
    parser = Parser.new(logger)
    Zlib::GzipReader.open(filename) do |gz|
      gz.each_line do |line|
        event = parser.parse(line, imei_number)
        next unless event
        wait_time = sleep_time + rand(error_factor)
        begin
          RestClient.post "http://#{target}/events", {data: event}
          logger.debug("#{imei_number} successfully emitted an event. Sleeping for #{wait_time} seconds")
        rescue Exception => e
          logger.error "#{filename}"
          logger.error e
        end
        sleep(wait_time)
        break if gz.eof?
      end

    end
  end

end