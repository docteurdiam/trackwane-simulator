class ScraperTask

  def initialize(logger)
    @logger = logger
  end

  def execute(cfg)
    start_date = 2.days.ago.to_date
    end_date = Date.today
    @logger.info "Fetching data between #{start_date} and #{end_date}"
    Scraper.new(cfg, @logger).run(start_date, end_date, cfg['max_devices'].to_i, cfg["working_directory"])
  end

end