# coding: utf-8

require "test/unit"
require "./choppa"

class TestChoppa < Test::Unit::TestCase

  def test_empty_opml_should_remain_empty
    processor = ChoppaProcessor.new(build_opml)
    processor.process!
    assert_equal(0, processor.doc.xpath('/opml/body/*').count)
  end
  
  def test_two_daily_feeds_should_be_added_to_groups_for_all_days
    processor = ChoppaProcessor.new(
      build_opml('[daily]' => %w(Tesugen BLDGBLOG)))
    processor.process!

    doc = processor.doc

    assert_equal(1, doc.xpath('/opml/body/outline[@text="[daily]"]').count)
    
    days = (1..7).zip(%w(Monday Tuesday Wednesday Thursday Friday Saturday
      Sunday)).map {|x| x * ' '}
    days.each do |day|
      assert_equal(1, doc.xpath("/opml/body/outline[@text='#{day}']").count)
      assert_equal(1, doc.xpath(
        "//*[@text='#{day}']/outline[@text='Tesugen']").count)
      assert_equal(1, doc.xpath(
        "//*[@text='#{day}']/outline[@text='BLDGBLOG']").count)
    end
  end
  
  def test_a_twice_weekly_feed_should_be_added_to_monday_and_thursday
    processor = ChoppaProcessor.new(
      build_opml('[twice weekly]' => %w(Lifehacker)))
    processor.process!
    
    doc = processor.doc

    assert_equal(1, doc.xpath(
      '/opml/body/outline[@text="[twice weekly]"]').count)
    
    ['1 Monday', '4 Thursday'].each do |day|
      assert_equal(1, doc.xpath("/opml/body/outline[@text='#{day}']").count)
      assert_equal(1, doc.xpath(
        "//*[@text='#{day}']/outline[@text='Lifehacker']").count)
    end
  end
  
  def test_many_twice_weekly_feeds_should_be_added_to_different_days
    processor = ChoppaProcessor.new(
      build_opml('[twice weekly]' => %w(Selby ISO50 Waxy Dezeen TABlog)))
    processor.process!
    
    doc = processor.doc
    
    ['1 Monday', '4 Thursday'].each do |day|
      assert_equal(1, doc.xpath(
        "//*[@text='#{day}']/outline[@text='Selby']").count)
    end
    ['2 Tuesday', '5 Friday'].each do |day|
      assert_equal(1, doc.xpath(
        "//*[@text='#{day}']/outline[@text='ISO50']").count)
    end
    ['5 Friday', '1 Monday'].each do |day|
      assert_equal(1, doc.xpath(
        "//*[@text='#{day}']/outline[@text='TABlog']").count)
    end
  end
  
  def test_feeds_for_every_other_day_are_added_to_different_days
    processor = ChoppaProcessor.new(
      build_opml('[every other day]' => %w(Mavenist Thoughtful)))
    processor.process!
    
    doc = processor.doc

    ['1 Monday', '3 Wednesday', '5 Friday', '7 Sunday'].each do |day|
      assert_equal(1, doc.xpath(
        "//*[@text='#{day}']/outline[@text='Mavenist']").count)
    end
    ['2 Tuesday', '4 Thursday', '6 Saturday', '1 Monday'].each do |day|
      assert_equal(1, doc.xpath(
        "//*[@text='#{day}']/outline[@text='Thoughtful']").count)
    end
  end
  
  private
  
  def build_opml(feeds = {})
    Nokogiri::XML::Builder.new do |xml|
      xml.opml {
        xml.head {
          xml.title "Steve subscriptions in Google Reader"
        }
        xml.body {
          feeds.each do |group, feed_names|
            xml.outline(:text => group, :title => group) {
              feed_names.each do |feed|
                xml.outline :text => feed, :title => feed, :type => 'rss',
                  :'htmlUrl' => "http://#{feed.downcase}.com/",
                  :'xmlUrl' => "http://#{feed.downcase}.com/feed"         
              end
            }
          end
        }
      }
    end.doc
  end
  
end