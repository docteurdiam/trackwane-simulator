require 'spec_helper'

describe Agent do

  describe "when simulating a tracker" do

    it "successfully reads a typical report file" do
      filename = File.join(File.dirname(__FILE__), "fixtures/27126.csv.gz")
      sleep_time = 0.01
      target = "nowhere.com"
      logger = double('Logger').as_null_object
      Agent.new.simulate_tracker(filename, sleep_time, target, logger)
    end

  end

end