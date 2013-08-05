xml.instruct!
xml.rss('version' => '2.0') do
  xml.channel do 
    xml.title("Yad2 RSS")
    xml.link(@url)
    xml.description("Apartment listing for #{@url} !")
    @apartments.each { |a|
      xml.item do 
        xml.title("#{a.address} (#{a.price})")
        xml.link(a.link)
        xml.description("room_count: #{a.room_count} -- entry_date: #{a.entry_date} -- floor: #{a.floor}")
      end
    }
  end
end
