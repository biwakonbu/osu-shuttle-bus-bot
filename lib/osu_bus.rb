require 'open-uri'
require 'nokogiri'
require 'twitter'
require 'yaml'
require 'time'

class OSUBus
  attr_reader :url, :doc

  def initialize
    @url = 'http://www.osaka-sandai.ac.jp/cgi-bin/cms/campus_life.cgi?studentlife_cd=5JzeUsFN0i'
  end

  def get
    respons = open(@url)
    @doc = Nokogiri::HTML(respons)
    respons.status[0]
  end

  def tweet
    "Hello RSpec"
  end
end
