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

  get "/yad2" do
    @apartments = load_apartments(request.params)
    haml :list
  end

  get "/yad2.rss" do
    @apartments = load_apartments(request.params)
    headers 'Content-Type' => 'text/xml; charset=windows-1255'
    builder :rss
  end

  def load_apartments(request_params)
    @@url = create_url(request_params)
    Capybara.visit(@@url)
    table = Capybara.page.find '#main_table'
    trs = table.all "tr[class^='ActiveLink']"
    trs.map do |tr|
      cells = tr.all "td"

      address = cells[8].text
      price = cells[10].text
      room_count = cells[12].text
      entry_date = cells[14].text
      floor = cells[16].text
      link = "http://www.yad2.co.il/Nadlan/" + cells[24].all("a").last['href']
      Apartment.new(address,price,room_count,entry_date,floor,link)
    end

  rescue => e
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

  attr_accessor :address, :price,:room_count,:entry_date,:floor,:link

  def initialize(address,price,room_count,entry_date,floor,link)
    @address,@price,@room_count,@entry_date,@floor,@link,@posted_on = address,price,room_count,entry_date,floor,link
  end

end
