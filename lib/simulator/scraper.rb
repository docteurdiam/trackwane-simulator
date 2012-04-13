require 'ruby-debug'

require 'date'
require 'active_support/all'

class Scraper

  IGNORE_PREFIXES = ["All Sub User Trackers", "Sans", "AGEROUTE"]

  def initialize(cfg, logger)
    @agent = Mechanize.new
    @logger = logger
    @gateway = cfg["gateway"]
    @email = cfg["email"]
    @password = cfg["password"]
    @report_page = cfg["report_page"]
  end

  def run(start_date, end_date, max_devices, working_directory)
    login
    tmpdir = Dir.mktmpdir(nil)
    @logger.debug "Downloading to #{tmpdir}"
    start_date.upto(end_date) {|day| download(day, tmpdir, max_devices)}
    Dir[File.join(working_directory, "*.gz")].each do |file|
      FileUtils.rm file
    end
    Dir[File.join(tmpdir, "/*.gz")].each do |file|
      FileUtils.move file, File.join(working_directory, File.basename(file))
    end
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

  def download(day, tmpdir, max_devices)
    page = @agent.get(@report_page)
    form = page.form
    form.r_from_date = day
    form.r_to_date = day
    options = form.field("r_uin").options
    counter = 0
    options.each do |option|
      break if counter == max_devices
      next if option.text == "All Sub User Trackers"
      next if option.text == "Sans"
      next if option.text == "AGEROUTE"
      option.select
      csv = form.submit(form.button_with(:name => "r_save_to_csv"))
      filename = "#{option.value}.csv"
      csv_body = clean(csv.body)
      save_uncompressed(filename, csv_body, tmpdir)
      @logger.info "Report for #{option.text} (#{day}) successfully retrieved"
      counter = counter + 1
    end
  end

  def clean(contents)
    contents.gsub(/^.+"Total:".+$/, '').gsub(/^.+"Alarme:".+$/, '').gsub(/\n\n+/, "\n")
  end

  def save_uncompressed(filename, contents, tmpdir)
    archive = File.join(tmpdir, "#{filename}.gz")
    File.open(archive, 'ab') do |f|
      gz = Zlib::GzipWriter.new(f, nil, nil)
      gz << contents
      gz.close
    end
  end

end
