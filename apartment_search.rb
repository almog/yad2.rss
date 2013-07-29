Bundler.require(:default)
require "addressable/uri"
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.current_driver = :poltergeist

Capybara.configure do |config|
  config.ignore_hidden_elements = true
  config.visible_text_only = true
end
#Capybara.page.driver.headers =
#  {"User-Agent" =>
#   "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20130328 Firefox/22.0"}
#
class ApartmentSearch < Sinatra::Base
Capybara.app = ApartmentSearch
  get "/" do
    "try /yad2 , or /yad2.rss "
  end

  get "/yad2" do
    @apartments = load_apartments(request.params)
    haml :list
  end

  get "/yad2.rss" do
    @apartments = load_apartments(request.params)
    headers 'Content-Type' => 'text/xml; charset=windows-1255'
    builder :rss
  end

  def self.url
    "Just a place holder for the list.haml"
  end

  def load_apartments(request_params)
    #agent = Mechanize.new { |a| a.log = Logger.new('apartment.log') }
    #agent.user_agent_alias = "Mac Mozilla"
    url = create_url(request_params)
    Capybara.visit(url)
    begin
      table = Capybara.page.find '#main_table'
    rescue Exception => e
      binding.pry
    end
    trs = table.all "tr[class^='ActiveLink']"
    trs.map do |tr|
      cells = tr.all "td"

      address = cells[8].text
      price = cells[10].text
      room_count = cells[12].text
      entry_date = cells[14].text
      floor = cells[16].text
      link = "http://www.yad2.co.il/Nadlan/" + cells[24].all("a").last['href']
      # posted_on = (cells/"font").inner_html
      Apartment.new(address,price,room_count,entry_date,floor,link)
    end

  rescue => e
#    agent.log.warn "an error (#{e}) occured on #{ApartmentSearch.url}"
    raise e
  end

  def create_url(params)
    uri = Addressable::URI.new
    uri.host = 'www.yad2.co.il'
    ad_type = params.delete('ad_type')
    uri.path = "/Nadlan/#{ad_type}.php"
    uri.scheme = 'http'
    uri.query_values = params
    @url = uri.to_s
    @url
  end

end

class Apartment

  attr_accessor :address, :price,:room_count,:entry_date,:floor,:link #,:posted_on

=begin
    def parse_time_string(text)
       if (cells/"font").inner_html.match(/^(\d\d)\/(\d\d)\/(\d\d\d\d)$/) # 05/08/2009
         Time.parse("#{$2,$1,$3}}") # israel vs US month/day thing. (2,1,3)
       else
         @agent.log.warn "Put Time.now, could not parse out yad2 td/font date."
         Time.now
       end
    end
=end

  def initialize(address,price,room_count,entry_date,floor,link)
    @address,@price,@room_count,@entry_date,@floor,@link,@posted_on = address,price,room_count,entry_date,floor,link
  end

end



