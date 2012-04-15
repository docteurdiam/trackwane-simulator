class AgentTask

  def initialize(logger, working_directory, target, sleep_time, error_factor, max_devices)
    @logger = logger
    @sleep_time = sleep_time.to_i.seconds
    @working_directory = working_directory
    @target = target
    @error_factor = error_factor
    @max_devices = max_devices.to_i
  end

  def execute
    @threads = []
    test_data = File.expand_path(File.join(@working_directory, "*.gz"))
    archives = Dir[test_data].compact
    upper_bound = @max_devices > archives.size ? archives.size : @max_devices
    for i in 0..upper_bound
      launch_agent(archives[i])
    end
    @threads.each { |t| t.join }
  end

  private

  def launch_agent(file)
    unless file && File.exists?(file)
      @logger.error "Cannot read data from {#{file}} as it does not exist. The agent cannot run."
      return
    end
    @threads << Thread.start do
      @logger.info "Reading data from #{file}"
      Agent.new.run(file, @sleep_time, @error_factor, @target, @logger)
    end
  end

end