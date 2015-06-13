require 'rubygems'
require 'bundler'

Bundler.require
require 'sinatra/reloader' if development?

Capybara.register_driver :poltergeist do |app|
  options = {
    phantomjs_options: ["--disk-cache=true", "--load-images=false"],#, "--ignore-host='(google.com|google-analytics.com)'"],
    js_errors: false
  }

  Capybara::Poltergeist::Driver.new(app, options)
end

Capybara.javascript_driver = :poltergeist
Capybara.current_driver = :poltergeist

Capybara.configure do |config|
  config.ignore_hidden_elements = true
  config.visible_text_only = true
  config.page.driver.add_headers( "User-Agent" =>
                                    "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1" )
end

configure :development do
  register Sinatra::Reloader
end

get "/" do
  "try /yad2 , or /yad2.rss "
end

get "/yad2/rent.rss" do
  get_rss('rent')
end

get "/yad2/sales.rss" do
  get_rss('sales')
end

private

def get_rss(ad_type)
  @apartments = load_apartments(ad_type, request.params)
  headers 'Content-Type' => 'text/xml; charset=windows-1255'
  builder :rss
end

def load_apartments(ad_type, request_params)
  3.times.map do |page_number|
    @@url = create_url(ad_type, request_params, page_number + 1)
    Capybara.visit(@@url)
    begin
      table = Capybara.page.find '#main_table'
    rescue Capybara::ElementNotFound
      raise "Couldn't find the ads table"
    end
    trs = table.all "tr[id^='tr_Ad_']"
    apartments = trs.map do |tr|
      cells = tr.all "td"
      Apartment.new(ad_type, cells)
    end
  end.flatten
end

def create_url(ad_type, params, page_number)
  params["Page"] = page_number
  uri = Addressable::URI.new
  uri.host = 'www.yad2.co.il'
  uri.path = "/Nadlan/#{ad_type}.php"
  uri.scheme = 'http'
  uri.query_values = params
  @url = uri.to_s
  @url
end

class Apartment
  attr_accessor :address, :price,:room_count,:entry_date,:floor,:link

  def initialize(ad_type, cells)
    apartment_attributes = ad_type == 'rent' ? apartment_for_rent(cells) : apartment_for_sale(cells)
    apartment_attributes.each do | key, value |
      send("#{key}=", value)
    end
  end

  def apartment_for_rent(cells)
    link = "http://www.yad2.co.il/" +
      cells[21].all("a").last['href'].to_s
    puts link

    {
      address:    cells[8].text,
      price:      cells[10].text,
      room_count: cells[12].text,
      entry_date: cells[14].text,
      floor:      cells[16].text,
      link:       link
    }
  end

  def apartment_for_sale(cells)
    link = "http://www.yad2.co.il" + cells[20].all("a").last['href'].to_s
    {
      address:    cells[8].text,
      price:      cells[10].text,
      room_count: cells[12].text,
      entry_date: cells[18].text,
      floor:      cells[14].text,
      link:       link
    }
  end
end
