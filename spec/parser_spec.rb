# encoding: UTF-8

require 'spec_helper'

describe Parser do

  describe "when parsing" do

    it "identifies invalid lines" do
      parser = Parser.new(double('Logger'))
      parser.is_invalid?(nil).should be_true
      parser.is_invalid?('<U+FEFF>"IMEI Traceur","Date:","Lat:","Long:","Vitesse:","Signal:","Orient:","Etat:","Distance:","Odometer(KM)","Addresse:",').should be_true
      parser.is_invalid?('"Total:","3338 Record(s)",').should be_true
      parser.is_invalid?('"Alarme:","Alarme Key 5 x 35",').should be_true
      parser.is_invalid?('').should be_true
    end

    it "identifies valid lines" do
      parser = Parser.new(double('Logger'))
      parser.is_invalid?("asdad,asdasd,asdasd").should be_false
    end

    it "creates an event from a row of data" do
      logger = double('Logger')
      parser = Parser.new(logger)
      data = ["FORD 4X4 2787FK01", "2012-04-13 00:23:52", "6.559383", "-5.024245", "0.2035", "1", "89.63", "Position GPS<!--295550-->"]
      event = parser.create_event(data, "2323")
      event[:date].should == "2012-04-13 00:23:52"
      event[:imei_number].should == "2323"
      event[:latitude].should == "6.559383"
      event[:longitude].should == "-5.024245"
      event[:speed].should == "0.2035"
      event[:gps_signal].should == "1"
      event[:heading].should == "89.63"
    end

    it "logs an error if the line is not a valid CSV entry" do
      logger = double('Logger')
      parser = Parser.new(logger)
      parser.parse('"FORD 4X4 2787FK01","2012-04-13 00:23:52","6.559383","-5.024245","0.2035","1","89.63","Position GPS<!--295550-->","0.00","6,563.65","A3, Toumodi, Côte d\'Ivoire",', "234234")
    end

  end

end