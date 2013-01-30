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
  bus_stop = []
  nokogiri.xpath(from).each do |node|
    if bus_stop[-1] != nil and /\d時/ =~ bus_stop[-1][0]
      bus_stop[-1] = format_diagram(node).map{|x| bus_stop[-1][0].sub('時', ':') + x if x != ''}
      bus_stop[-1].delete(nil)
      next
    end
    bus_stop << format_diagram(node)
  end
  bus_stop
end

from_suminodo = split_table(1)
from_daisan = split_table(2)

def concat_to(table)
  array = []
  table.each do |x|
    if x[-1] != nil and /\d+:/ =~ x[0]
      array[-1].concat(x)
      next
    end
    array << x
  end
  array
end


timetable = concat_to bus_timetable(doc, from_suminodo)

doc.xpath(from_daisan).each do |node|
  format_diagram(node)
end
