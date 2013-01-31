# -*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'twitter'
require 'yaml'
require 'time'

Process.daemon
config_file = "#{ENV['HOME']}/.key.yml"

env = YAML::load File.open(config_file)

CONSUMER_KEY = env['consumer_key']
CONSUMER_SECRET = env['consumer_secret']
OAUTH_TOKEN = env['oauth_token']
OAUTH_TOKEN_SECRET = env['oauth_token_secret']

Twitter.configure do |config|
  config.consumer_key = CONSUMER_KEY
  config.consumer_secret = CONSUMER_SECRET
  config.oauth_token = OAUTH_TOKEN
  config.oauth_token_secret = OAUTH_TOKEN_SECRET
end

bus_schedule = 'http://www.osaka-sandai.ac.jp/cgi-bin/cms/campus_life.cgi?studentlife_cd=5JzeUsFN0i'
doc = Nokogiri::HTML(open(bus_schedule))
SATURDAY = 6

def split_table(column)
  timetable = "table[@class='timetable_suminodo']"
  "//#{timetable}//td[#{column}]|//#{timetable}//th[#{column}]"
end

def format_diagram(node)
  node.content.gsub(/中|\(臨\)/, '').split(/ |　/)
end

def bus_timetable(nokogiri, from)
  array = []
  nokogiri.xpath(from).each do |node|
    if array[-1] != nil and /\d時/ =~ array[-1][0]
      array[-1] = format_diagram(node).map{|x| array[-1][0].sub('時', ':') + x if x != ''}
      array[-1].delete(nil)
      next
    end
    array << format_diagram(node)
  end
  array
end

def concat_to(table)
  array = []
  table.each do |x|
    if x[-1] != nil and /\d+:/ =~ x[0]
      array[-1].concat(x)
      next
    end
    array << ['']
  end
  array
end

def collect_table(timetable)
  text = ''
  tweets = []
  timetable.each do |wday|
    
    time = []
    wday.each do |index|
      if /住道発|大学発/ =~ index
        index.sub!(/\(.+\)/, "【#{$1}】")
        text = " #{index}:\n"
        next
      end
      
      unless /:－$/ =~ index
        if Time.now < Time.parse(index) and time.length <= 2
          time << index + ', '
        end
      end
    end
    
    text << ' ' << time.join.strip.chop
    tweets << text + "\r\n"
  end
  
  if Time.now.wday < SATURDAY
    tweets[0]
  else
    tweets[1]
  end
end

from_suminodo = split_table(1)
from_daisan = split_table(2)

suminodo_table = concat_to bus_timetable(doc, from_suminodo)
daisan_table = concat_to bus_timetable(doc, from_daisan)

client = Twitter::Client.new

while true
  begin
    if Time.now.min % 10 == 0 and (7 <= Time.now.hour and Time.now.hour <= 23)
      tweets = "現在直近のシャトルバス運行時間 \n"
      tweets << collect_table(suminodo_table)
      tweets << collect_table(daisan_table)
      client.update(tweets)
    end

    sleep 60
  rescue => ex
    sleep 10
    retry
  end
end
