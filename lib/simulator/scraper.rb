require 'ruby-debug'

require 'date'
require 'active_support/all'
require 'zip/zip'
require 'zip/zipfilesystem'

class Scraper

  IGNORE_PREFIXES = ["All Sub User Trackers", "Sans", "AGEROUTE"]

  def initialize(agent, cfg, logger)
    @agent = agent
    @logger = logger
    @output_directory = cfg["working_directory"]
    @gateway = cfg["gateway"]
    @email = cfg["email"]
    @password = cfg["password"]
    @report_page = cfg["report_page"]
  end

  def run(start_date, end_date)
    login
    start_date.upto(end_date) {|day| download(day)}
    @logger.info "Finished downloading GPS data"
  end

  private

  def login
    @logger.debug "Connecting to [#{@gateway}] using login [#{@email}] and password [#{@password}]"
    page = @agent.get(@gateway)
    page.form.email = @email
    page.form.Password = @password
    page.form.submit
  end

  def download(day)
    page = @agent.get(@report_page)
    form = page.form
    form.r_from_date = day
    form.r_to_date = day
    options = form.field("r_uin").options
    options.each do |option|
      next if option.text == "All Sub User Trackers"
      next if option.text == "Sans"
      next if option.text == "AGEROUTE"
      option.select
      csv = form.submit(form.button_with(:name => "r_save_to_csv"))
      filename = "#{option.value}.#{day}.csv"
      save_report(filename, csv.body)
      @logger.info "Report for #{option.text} (#{day}) successfully retrieved"
    end
  end

  def save_report(filename, contents)
    archive = File.join(@output_directory, "#{filename}.zip")
    File.delete(archive) if File.exists?(archive)
    File.open(filename, "a") do |file|
      file << contents
      Zip::ZipFile.open(archive, Zip::ZipFile::CREATE) do |zipfile|
        zipfile.add(filename, filename)
      end
      File.delete(file)
    end
  end

end
