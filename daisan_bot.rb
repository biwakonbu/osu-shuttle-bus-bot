# -*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'time'
require 'pp'

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
    array << x if /[^(平日便|土曜日便|夏期ダイヤ)]/ =~ x[0]
  end
  array
end

def collect_table(timetable)
  text = ''
  tweets = []
  diagrum = ['平日便', '土曜日便', '夏期ダイヤ']
  timetable.each do |wday|
    
    time = []
    wday.each do |index|
      if /住道発|大学発/ =~ index
        text = diagrum.shift + ", #{index}:\r\n"
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

tweets = "現在直近のシャトルバス運行時間 \r\n"
tweets << collect_table(suminodo_table)
tweets << collect_table(daisan_table)

puts tweets
