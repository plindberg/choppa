# coding: utf-8

require "test/unit"
require "minitest/spec"
require "./choppa"

describe ChoppaProcessor do

  it 'does nothing with an empty OPML' do
    processor = ChoppaProcessor.new(build_opml)
    processor.process!
    assert_equal(0, processor.doc.xpath('/opml/body/*').count)
  end
  
  it 'sorts two daily feeds into groups for every day of the week' do
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
  
  it 'adds a twice weekly feed to groups for Monday and Thursday' do
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
  
  it 'adds a bunch of twice weekly feeds to groups for different days' do
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
  
  it 'adds every-other-day feeds to groups for different days' do
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
  
  it 'discards day groups from previous runs' do
    processor = ChoppaProcessor.new(
      build_opml('[twice weekly]' => %w(Mymarkup), '2 Tuesday' => %w(Mymarkup),
        '[every other day]' => %w(POKE), '5 Friday' => %w(POKE)))
    processor.process!
    
    doc = processor.doc

    assert_equal(0, doc.xpath("//*[@text='2 Tuesday']/outline[@text='Mymarkup']").count)
    assert_equal(0, doc.xpath("//*[@text='5 Friday']/outline[@text='POKE']").count)

    ['1 Monday', '4 Thursday'].each do |day|
      assert_equal(1, doc.xpath(
        "//*[@text='#{day}']/outline[@text='Mymarkup']").count)
    end
    ['2 Tuesday', '4 Thursday', '6 Saturday', '1 Monday'].each do |day|
      assert_equal(1, doc.xpath(
        "//*[@text='#{day}']/outline[@text='POKE']").count)
    end
  end

  it 'preserves day groups for feeds not in twice daily or every other day' do
    processor = ChoppaProcessor.new(
      build_opml('2 Tuesday' => %w(Mymarkup), '5 Friday' => %w(Mymarkup)))
    processor.process!

    doc = processor.doc

    ['2 Tuesday', '5 Friday'].each do |day|
      assert_equal(1, doc.xpath("/opml/body/outline[@text='#{day}']").count)
      assert_equal(1, doc.xpath(
        "//*[@text='#{day}']/outline[@text='Mymarkup']").count)
    end
  end

  private
  
  def build_opml(feeds = {})
    Nokogiri::XML::Builder.new do |xml|
      xml.opml {
        xml.head {
          xml.title "Choppa them Google Reader feeds"
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