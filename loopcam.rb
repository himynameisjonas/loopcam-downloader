require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'pry'

username = "himynameisjonas"

class LoopcamFetcher
  attr_accessor :page

  def initialize(first_loop_url)
    @url = first_loop_url
    start
  end

  def start
    puts "Starting..."
    self.page = agent.get(@url)
    loop do
      download
      next_url = next_page_url
      break if next_url.nil?
      puts "next page"
      self.page = agent.get(next_url)
    end
    puts "done!"
  end

  def next_page_url
    if link = page.search(".koto-sidebar-left a.koto-sidebar-item").first
      link.attr('href')
    end
  end

  def agent
    @agent ||= begin
      Mechanize.new.tap do |agent|
        agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.94 Safari/537.36'
        agent.request_headers = { "Accept" => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'}
      end
    end
  end

  def download
    print "Downloading "
    media = page.search('.koto-loop-wrapper source').first || page.search('.koto-loop-wrapper img').first
    src = media.attr('src')
    print src.inspect
    date = DateTime.parse(page.search('.koto-posted-date a').first.attr('title'))
    title = page.search('.koto-loop-title').text().strip.gsub(/\/|\\/,"-")
    filename = "media/#{date.strftime "%F-%H%M"}-#{title}.#{src.split(".").last}"
    puts " as #{filename}"
    agent.download src, filename
  end
end

LoopcamFetcher.new("http://loopc.am/#{username}")
