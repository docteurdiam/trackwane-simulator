class AgentTask

  def initialize(logger, working_directory, target, sleep_time)
    @logger = logger
    @sleep_time = sleep_time
    @working_directory = working_directory
    @target = target
  end

  def execute
    @threads = []
    test_data = File.expand_path(File.join(@working_directory, "*.zip"))
    Dir[test_data].each do |archive|
      @logger.info "Launching an agent with #{archive}"
      file = extract_csv(archive)
      launch_agent(file)
    end
    @threads.each { |t| t.join }
  end

  private

  def extract_csv(archive)
    Storage.unzip(archive, @working_directory)
    archive[0..archive.length() - 5]
  end

  def launch_agent(file)
    @threads << Thread.start do
      @logger.info "Reading data from #{file}"
      Agent.new.run(file, @sleep_time, @target, @logger)
    end
  end

end