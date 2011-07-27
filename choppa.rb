# coding: utf-8

require 'rubygems'
require 'nokogiri'

class ChoppaProcessor
  attr_reader :doc
  
  def initialize(doc)
    @doc = doc
  end
  
  def process!
    return unless @doc.at('//body/outline[@text="[daily]"]')

    @doc.xpath('//body/outline[@text="[daily]"]/outline[@type="rss"]').each do |outline|
      daily_nodes.each {|node| node.add_child(outline.clone)}
    end
  end
  
  private
  
  def daily_nodes
    days = %w(Måndag Tisdag Onsdag Torsdag Fredag Lördag Söndag)
    (1..days.size).zip(days).map do |day_parts|
      name = day_parts.join(' ')
      @doc.at(%{//body/outline[@text="#{name}"]}) ||
        @doc.at('body').add_child(
          %{<outline text="#{name}" title="#{name}" />}).first
    end
  end
end