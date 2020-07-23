require "open-uri"
require "json"
require "time"
require "pp"

class APIs
  #Name: getMarket
  #Parameters: None
  #Description: Obtain a complete list of identifiers through the call to the Markets endpoint
  def getMarket()
    tradesId=[]
    response = open("https://www.buda.com/api/v2/markets").read
    json = JSON.parse(response)
    i=0
    while i < json["markets"].length
      json["markets"][i].each do |key, value|
        if key == "id"
          tradesId = tradesId.append(json["markets"][i]["id"])
        end
      end
      i+=1
    end
    return tradesId
  end

  #Name: getTrade
  #Parameters: id of the specific market
  #Description: Obtain a complete trade's list of the id through the call to the specific Trade market link
  def getTrade(id)
    function = Functions.new
    t = Time.now.to_f - 60 * 60 * 24
    time = function.timeCutter(t)
    markets = 'https://www.buda.com/api/v2/markets/' + id + '/trades?limit=100&timestamp=' + time
   response = open(markets).read
   json = JSON.parse(response)
   return json["trades"]
  end
end


class Functions
  #Name: entriesCollector
  #Parameters: None
  #Description: Obtain a hash, which has id as a key and a list of entries as a value
  def entriesCollector()
    entries = []
    tAmount = {}
    t = Time.now.to_f
    api = APIs.new
    function = Functions.new
    tradesId = api.getMarket()
    tradesId.each do |market|
      entries = api.getTrade(market)["entries"]
      lastTime = api.getTrade(market)["last_timestamp"]
      tAmount[market] = entries
      while lastTime > function.timeCutter(t)
        newEntries = api.getTrade(market)["entries"]
        tAmount[market] = tAmount[market].append(newEntries)
      end
    end
    return tAmount
  end

  #Name: timeCutter
  #Parameters: Time with seconds
  #Description: Make a string with the necessary seconds for the time format
  def timeCutter(t)
    t = t.to_s
    timeCut = t.split('.')
    timeCut = timeCut[0] + timeCut[1].slice(0,3)
    return timeCut
  end

  #Name: nameCutter
  #Parameters: id
  #Description: Divide the first type of cryptocurrency from the another one, keeping the first part
  def nameCutter(id)
    idCut = id.split('-')
    idCut = idCut[0]
    return idCut
  end

end


#===================MAIN========================#
function = Functions.new
hashAmounts=function.entriesCollector()
puts "The largest amounts of each market in the last 24H are: "
hashAmounts.each do |key, value|
  amounts = []
  id = function.nameCutter(key)
  value.each do |element|
    amounts = Array(amounts).push(element[1])
  end
  amounts.sort do |a,b| b <=> a end
  puts "#{key} : #{amounts[0]} #{id}"
end
