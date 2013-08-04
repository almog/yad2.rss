Capybara.register_driver :poltergeist do |app|
  options = {
    phantomjs_options: ["--disk-cache=true"],
    js_errors: false
  }

  Capybara::Poltergeist::Driver.new(app, options)
end

Capybara.javascript_driver = :poltergeist
Capybara.current_driver = :poltergeist

Capybara.configure do |config|
  config.ignore_hidden_elements = true
  config.visible_text_only = true
end

class ApartmentSearch < Sinatra::Base
Capybara.app = ApartmentSearch
  get "/" do
    "try /yad2 , or /yad2.rss "
  end

  get "/yad2/rent" do
    get_list('rent')
  end

  get "/yad2/sales" do
    get_list('sales')
  end

  get "/yad2/rent.rss" do
    get_rss('rent')
  end

  get "/yad2/sales.rss" do
    get_rss('sales')
  end

  private

  def get_list(ad_type)
    @apartments = load_apartments(ad_type, request.params)
    haml :list
  end

  def get_rss(ad_type)
    @apartments = load_apartments(ad_type, request.params)
    headers 'Content-Type' => 'text/xml; charset=windows-1255'
    builder :rss
  end

  def load_apartments(ad_type, request_params)
    @@url = create_url(ad_type, request_params)
    Capybara.visit(@@url)
    table = Capybara.page.find '#main_table'
    trs = table.all "tr[class^='ActiveLink']"
    trs.map do |tr|
      cells = tr.all "td"

      Apartment.new(ad_type, cells)
    end

  rescue => e
    raise e
  end

  def create_url(ad_type, params)
    uri = Addressable::URI.new
    uri.host = 'www.yad2.co.il'
    uri.path = "/Nadlan/#{ad_type}.php"
    uri.scheme = 'http'
    uri.query_values = params
    @url = uri.to_s
    @url
  end
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
    link = "http://www.yad2.co.il/Nadlan/" +
      cells[24].all("a").last['href'].to_s
    {
      address: cells[8].text,
      price: cells[10].text,
      room_count: cells[12].text,
      entry_date: cells[14].text,
      floor: cells[16].text,
      link: link
    }
  end

  def apartment_for_sale(cells)
    link = "http://www.yad2.co.il/Nadlan/" +
      cells[20].all("a").last['href'].to_s
    {
      address: cells[8].text,
      price: cells[10].text,
      room_count: cells[12].text,
      entry_date: cells[18].text,
      floor: cells[14].text,
      link: link
    }
  end
end
