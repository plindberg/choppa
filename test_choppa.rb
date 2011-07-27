# coding: utf-8

require "test/unit"
require "./choppa"

class TestChoppa < Test::Unit::TestCase

  def test_processing_empty_opml
    processor = ChoppaProcessor.new(empty_opml)
    processor.process!
    assert_equal(0, processor.doc.xpath('/opml/body/*').count)
  end
  
  def test_processing_opml_with_one_feed_tagged_daily
    processor = ChoppaProcessor.new(build_opml)
    processor.process!

    doc = processor.doc

    assert_equal(1, doc.xpath('/opml/body/outline[@text="[daily]"]').count)
    
    days = (1..7).zip(%w(Måndag Tisdag Onsdag Torsdag Fredag Lördag Söndag)).map {|x| x * ' '}
    days.each do |day|
      assert_equal(1, doc.xpath("/opml/body/outline[@text='#{day}']").count)
      assert_equal(1, doc.xpath("//outline[@text='#{day}']/outline[@text='Interconnected']").count)
    end
  end
  
  def build_opml
    doc = empty_opml
    Nokogiri::XML::Builder.with(doc.at('body')) do |xml|
      xml.outline(:text => '[daily]', :title => '[daily]') {
        xml.outline :text => 'Interconnected', :title => 'Interconnected',
          :type => 'rss', :'xmlUrl' => 'http://interconnected.org/home/;atom',
          :'htmlUrl' => 'http://interconnected.org/home/'
      }
    end
    doc
  end
  
  def empty_opml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.opml {
        xml.head {
          xml.title "Steve subscriptions in Google Reader"
        }
        xml.body
      }
    end.doc
  end
  
end