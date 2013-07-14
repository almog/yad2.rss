xml.instruct!
xml.rss('version' => '2.0') do
  xml.channel do 
    xml.title("Yad2fu")
    xml.link(ApartmentSearch.url)
    xml.description("Get the friggin' apartments, for #{ApartmentSearch.url} !")
    @apartments.each { |a|
      xml.item do 
        xml.title("#{a.address} (#{a.price})")
        xml.link(a.link)
        xml.description("room_count: #{a.room_count} -- entry_date: #{a.entry_date} -- floor: #{a.floor}")
        #xml.guid a.link
      end
    }
  end
end
