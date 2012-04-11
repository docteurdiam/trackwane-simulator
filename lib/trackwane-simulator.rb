require 'simulator/agent'
require 'simulator/storage'
require 'mechanize'
require 'simulator/scraper'
require 'simulator/scraper_task'
require 'simulator/agent_task'
require 'simulator/configuration'
require 'active_support/all'
require 'yell'
require 'trollop'

opts = Trollop::options do
  opt :file, "Required configuration file", :type => String  
  opt :mode, "The mode in which the simulator should run, either scraper mode or agent mode", :type => String
end

Trollop::die :file, "must be provided" unless opts[:file]
Trollop::die :mode, "must be either agent or scraper" unless opts[:mode] && ["agent", "scraper"].include?(opts[:mode])
Trollop::die :file, "must exist" unless File.exists?(opts[:file])

cfg = Configuration.new.parse(opts[:file])

logger = Yell.new do |log|
  log.adapter :datefile, File.join(cfg["log_directory"], 'production.log')
end

logger.info "Running the Trackwane Simulator"

case opts[:mode]
  when "scraper"
    ScraperTask(logger).new.execute(cfg)
  when "agent"
    AgentTask.new(logger, cfg["working_directory"], cfg["target"], 30.seconds).execute   
end




