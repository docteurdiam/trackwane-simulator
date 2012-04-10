require 'simulator/agent'
require 'simulator/storage'
require 'mechanize'
require 'simulator/scraper'
require 'active_support/all'
require 'yell'
require 'trollop'

logger = Yell.new STDOUT
logger.info "Running the Trackwane Simulator"

opts = Trollop::options do
  opt :file, "Required configuration file", :type => String  
  opt :mode, "The mode in which the simulator should run, either scraper mode or agent mode", :type => String
end

Trollop::die :file, "must be provided" unless opts[:file]
Trollop::die :mode, "must be either agent or scraper" unless opts[:mode] && ["agent", "scraper"].include?(opts[:mode])
Trollop::die :file, "must exist" unless File.exists?(opts[:file])

settings = YAML.load(File.open(opts[:file]))
puts settings
settings[:logger] = logger

if opts[:mode] == "scaper"
  start_date = 2.days.ago.to_date
  end_date = Date.today
  logger.info "Fetching data between #{start_date} and #{end_date}" 
  Scraper.new(Mechanize.new, settings).run(start_date, end_date)
elsif opts[:mode] == "agent"              
  threads = []
  test_data = File.expand_path(File.join(settings["output_directory"], "*.zip"))
  Dir[test_data].each do |archive|
    logger.info "Launching an agent with #{archive}"
    csv_file = archive[0..archive.length()-5]
    Storage.unzip(archive)
    threads << Thread.start do
      puts "Reading data from #{csv_file}"
      Agent.new.run(csv_file, 5)
    end
  end
  threads.each { |t| t.join }   
else
  raise "Invalid mode"
end



