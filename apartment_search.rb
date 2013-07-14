Bundler.require(:default)
require "addressable/uri"
class ApartmentSearch < Sinatra::Base
  get "/" do
    "try /yad2 , or /yad2.rss "
  end

  get "/yad2" do
    @apartments = load_apartments
    haml :list
  end

  get "/yad2.rss" do
    @apartments = load_apartments(request.params)
    headers 'Content-Type' => 'text/xml; charset=windows-1255'
    builder :rss
  end

  def load_apartments(request_params)
    agent = Mechanize.new { |a| a.log = Logger.new('apartment.log') }
    agent.user_agent_alias = "Mac Mozilla"
    url = create_url(request_params)
    page = agent.get(url)
    trs = page.search('//div[@id="main_table"]//tr[@class="ActiveLink"]')
    trs.map do |tr|
      cells = tr / "td"

      address = cells[8]
      price = cells[10]
      room_count = cells[12]
      entry_date = cells[14]
      floor = cells[16]
      link = "http://www.yad2.co.il/Nadlan/" + ((cells[24]/"a")[1]/"@href").to_s
      # posted_on = (cells/"font").inner_html
      Apartment.new(address,price,room_count,entry_date,floor,link)
    end

  rescue => e
    agent.log.warn "an error (#{e}) occured on #{ApartmentSearch.url}"
    raise e
  end

  def create_url(params)

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



