class Program

  def self.run
    opts = Trollop::options do
      opt :file, "Required configuration file", :type => String
      opt :mode, "The mode in which the simulator should run, either scraper mode or agent mode", :type => String
    end

    Trollop::die :file, "must be provided" unless opts[:file]
    Trollop::die :mode, "must be either agent or scraper" unless opts[:mode] && ["agent", "scraper"].include?(opts[:mode])
    Trollop::die :file, "must exist" unless File.exists?(opts[:file])

    cfg = Configuration.new.parse(opts[:file])

    logger = Yell.new do |log|
      if cfg["log"] == "console"
        log.adapter STDOUT
      else
        log.adapter :datefile, File.join(cfg["log_directory"], 'production.log')
      end
    end

    logger.info "Running the Trackwane Simulator"

    case opts[:mode]
      when "scraper"
        ScraperTask.new(logger).execute(cfg)
      when "agent"
        AgentTask.new(logger, cfg["working_directory"], cfg["target"], cfg["delta"], cfg["max_devices"]).execute
    end
  end

end