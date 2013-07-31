class OSUBus
  attr_reader :url

  def initialize()
    @url = 'http://www.osaka-sandai.ac.jp/cgi-bin/cms/campus_life.cgi?studentlife_cd=5JzeUsFN0i'
  end
  
  def tweet
    "Hello RSpec"
  end
end
