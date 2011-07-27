# coding: utf-8

require 'rubygems'
require 'nokogiri'

class ChoppaProcessor
  attr_reader :doc
  
  def initialize(doc)
    @doc = doc
  end
  
  def process!
    @doc.xpath('//*[@text="[daily]"]/*[@type="rss"]').each do |feed|
      daily_groups.each {|node| node.add_child(feed.clone)}
    end

    offset = 0
    
    @doc.xpath('//*[@text="[twice weekly]"]/*[@type="rss"]').each do |feed|
      twice_weekly_groups(offset).each {|node| node.add_child(feed.clone)}
      offset = (offset + 1) % 7
    end
    
    @doc.xpath('//*[@text="[every other day]"]/*[@type="rss"]').each do |feed|
      every_other_day_groups(offset).each {|node| node.add_child(feed.clone)}
      offset = (offset + 1) % 7
    end
  end
  
  private
  
  def daily_groups
    days.map do |name|
      find_or_create_group(name)
    end
  end
  
  def twice_weekly_groups(offset)
    days.values_at(offset, (3 + offset) % 7).map do |name|
      find_or_create_group(name)
    end
  end
  
  def every_other_day_groups(offset)
    days.values_at(*((0..3).map {|i| (i * 2 + offset) % 7})).map do |name|
      find_or_create_group(name)
    end
  end
  
  def find_or_create_group(name)
    @doc.at(%{//*[@text="#{name}"]}) || @doc.at('body').add_child(
      %{<outline text="#{name}" title="#{name}" />}).first
  end
  
  def days(*pick)
    @days ||= (1..7).zip(%w(Monday Tuesday Wednesday Thursday Friday
      Saturday Sunday)).map {|d| d.join(' ')}
  end
end