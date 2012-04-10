require 'rest_client'
require 'ccsv'

class Agent

  def run(filename, sleep_time, target, logger)
    imei_number = File.basename(filename, ".csv").split(".")[0]
    begin
      is_header = true
      Ccsv.foreach(filename) do |row|
        if is_header
          is_header = false
          next
        end
        next if row[1] == /Date:/
        next if row[0] =~ /Alarme:/
        next if row[0] =~ /Total:/
        event = create_event(row, imei_number)
        RestClient.post "http://#{target}/events", {data: event}
        logger.debug("#{imei_number} successfully emitted an event. Sleeping for #{sleep_time} seconds")
        sleep(sleep_time)
      end
    rescue Exception => e
      puts "ERROR: #{filename}"
      puts e
    end
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

end