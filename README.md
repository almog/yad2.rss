#Yad2 RSS API

##What?
This project is aimed for those who're searching for an apartment and tired from checking [Yad2](http://yad2.co.il) manually during the day.

 Sinatra server using the Poltergeist & Capybara to scrape web pages.

##How?
###Prerequisites
PhantomJS >= 1.8

###Starting the server
```
bundle install
rackup
```
###Creating a feed:
Go to [Yad2](http://yad2.co.il), filter your ads using the search and copy the query parameter:

`http://localhost:9292/<ad_type>?<query_parameters>` is the feed url, where <ad_type> can be either 'rent' or 'sales'.

For example, the RSS url for [this](http://www.yad2.co.il/Nadlan/rent.php?AreaID=1&City=%FA%EC+%E0%E1%E9%E1+%E9%F4%E5&Neighborhood=&HomeTypeID=&fromRooms=&untilRooms=&fromPrice=3000&untilPrice=4500&PriceType=1&FromFloor=&ToFloor=&EnterDate=&Info=)
search is:

```http://localhost:9292/rent?AreaID=1&City=%FA%EC+%E0%E1%E9%E1+%E9%F4%E5&Neighborhood=&HomeTypeID=&fromRooms=&untilRooms=&fromPrice=3000&untilPrice=4500&PriceType=1&FromFloor=&ToFloor=&EnterDate=&Info=```


Use your favorite news reader to serve it.
It is worth noting here that your news reader update rate should approximately match the amount of ads your yad2 search filters.

##Acknowledgement
This project is based on [@shaiguitar](http://github.com/shaiguitar)'s old project that aimed to achieve the same goal.
