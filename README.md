#Yad2 RSS API

##What?
This project is aimed for those who're searching for an apartment and tired of refreshing [Yad2](http://yad2.co.il) manually during the day.

##How?
Sinatra server, Poltergeist and Capybara.

###Prerequisites
PhantomJS >= 1.8

###Starting the server
```
bundle install
rackup
```
###Creating a feed:
Go to [Yad2](http://yad2.co.il), filter your ads using the search and copy the query parameter.

Your RSS feed will be constructed as follow:  
`http://localhost:9292/<ad_type>?<query_parameters>`.

Where:

* `<ad_type>` can be either `rent` or `sales`
* `<query_parameters>` is the exact string that is yad2's query parameters

For example, the RSS url for [this](http://www.yad2.co.il/Nadlan/rent.php?AreaID=&City=&HomeTypeID=&fromRooms=&untilRooms=&fromPrice=100&untilPrice=200&PriceType=1&FromFloor=&ToFloor=&EnterDate=&Info=)
search is:

```http://localhost:9292/rent?AreaID=&City=&HomeTypeID=&fromRooms=&untilRooms=&fromPrice=100&untilPrice=200&PriceType=1&FromFloor=&ToFloor=&EnterDate=&Info=```


Use your favorite news reader to serve it.
It is worth noting here that your news reader update rate should approximately match the amount of ads your yad2 search filters.

##Acknowledgement
This project is based on [@shaiguitar](http://github.com/shaiguitar)'s old project that aimed to achieve the same goal.
