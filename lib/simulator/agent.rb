require 'rest_client'
require 'csv'

class Agent

  def run(filename, sleep_time, target, logger)
    while (true) do
      simulate_tracker(filename, sleep_time, target, logger)
    end
  end

  def simulate_tracker(filename, sleep_time, target, logger)
    imei_number = File.basename(filename, ".csv.gz")
    parser = Parser.new(logger)
    Zlib::GzipReader.open(filename) do |gz|
      gz.each_line do |line|
        event = parser.parse(line, imei_number)
        next unless event
        begin
          RestClient.post "http://#{target}/events", {data: event}
          logger.debug("#{imei_number} successfully emitted an event. Sleeping for #{sleep_time} seconds")
          sleep(sleep_time)
        rescue Exception => e
          logger.error "#{filename}"
          logger.error e
        end
        break if gz.eof?
      end

    end
  end

end