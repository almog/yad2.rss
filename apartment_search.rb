Bundler.require(:default)
require "addressable/uri"
class ApartmentSearch < Sinatra::Base
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
      binding.pry
    ad_type = request_params.delete('ad_type')
    agent = Mechanize.new { |a| a.log = Logger.new('apartment.log') }
    agent.user_agent_alias = "Mac Mozilla"
    url = create_url(ad_type, request_params)
    page = agent.get(url)
    trs = page.search('//div[@id="main_table"]//tr[@class="ActiveLink"]')
    trs.map do |tr|
      cells = tr / "td"
      # posted_on = (cells/"font").inner_html
      Apartment.new(ad_type, cells)
    end

  rescue => e
    agent.log.warn "an error (#{e}) occured on #{@url}"
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

  def initialize(ad_type, cells)
      binding.pry
    apartment_attributes = ad_type == 'rent' ? apartment_for_rent(cells) : apartment_for_sale(cells)
    apartment_attributes.each do | key, value |
      binding.pry
      send("#{key}=", value)
    end
    #@address,@price,@room_count,@entry_date,@floor,@link,@posted_on = address,price,room_count,entry_date,floor,link
  end

  def apartment_for_rent(cells)
    {address => cells[8],
     price => cells[10],
     room_count => cells[12],
     entry_date => cells[14],
     floor => cells[16],
     link => "http://www.yad2.co.il/Nadlan/" + ((cells[24]/"a")[1]/"@href").to_s}
  end

  def apartment_for_sale(cells)
    {address => cells[8],
     price => cells[10],
     room_count => cells[12],
     entry_date => cells[14],
     floor => cells[16],
     link => "http://www.yad2.co.il/Nadlan/" + ((cells[24]/"a")[1]/"@href").to_s}
  end


end



