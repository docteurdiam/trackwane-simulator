class AgentTask

  def initialize(logger, working_directory, target, sleep_time, max_devices)
    @logger = logger
    @sleep_time = sleep_time.to_i.seconds
    @working_directory = working_directory
    @target = target
    @max_devices = max_devices.to_i
  end

  def execute
    @threads = []
    test_data = File.expand_path(File.join(@working_directory, "*.zip"))
    archives = Dir[test_data]
    upper_bound = @max_devices > archives.size ? archives.size : @max_devices
    for i in 0..upper_bound
      @logger.info "Launching an agent with #{archives[i]}"
      file = extract_csv(archives[i])
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