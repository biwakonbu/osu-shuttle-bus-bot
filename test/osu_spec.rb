$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'osu_bus'

describe "OSU Shuttle Bus" do
  it "should say 'Hello RSpec' When it receives the osu() message" do
    bus = OSUBus.new
    tweeting = bus.tweet
    tweeting.should == "Hello RSpec"
  end

  it "should set URL when it create OSUBus object" do
    bus = OSUBus.new
    bus.url == 'http://www.osaka-sandai.ac.jp/cgi-bin/cms/campus_life.cgi?studentlife_cd=5JzeUsFN0i'
  end

  it "should get HTTP Respons '200' when GET URI Page get() respons code" do
    bus = OSUBus.new
    bus.get == '200'
  end
end
