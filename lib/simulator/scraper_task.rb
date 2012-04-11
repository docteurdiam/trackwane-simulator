class ScraperTask

  def initialize(logger)
    @logger = logger
  end

  def execute(cfg)
    start_date = 2.days.ago.to_date
    end_date = Date.today
    @logger.info "Fetching data between #{start_date} and #{end_date}"
    Scraper.new(Mechanize.new, cfg, @logger).run(start_date, end_date)
  end

end