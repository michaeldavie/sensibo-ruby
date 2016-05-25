require 'open-uri'
require 'json'
require 'httparty'

module Sensibo
  
  class System

    attr_reader :pods

    def initialize(apiKey:)
      @apiKey = apiKey
      @urlBase = 'https://home.sensibo.com/api/v2/'
      @urlEnd = '?apiKey=' + @apiKey
    
      @pods = Array.new
      
      podsURL = @urlBase + 'users/me/pods' + @urlEnd
      podResults = JSON.parse(open(podsURL).string)['result']

      podResults.each do |pod|
        pods.push(Pod.new(@apiKey, pod['id']))
      end      
    end    
  end

  class Pod
  
    attr_reader :id, :measurementAge, :measurementTime, :currentTemp, :currentHumidity
    attr_accessor :on, :mode, :fan, :targetTemp
  
    def initialize(key, id)
      @apiKey = key
      @id = id
      @urlBase = 'https://home.sensibo.com/api/v2/'
      @urlEnd = '?apiKey=' + @apiKey
      
      getState
      getMeasurements
    end
  
    def getState
      stateIDsURL = @urlBase + 'pods/' + @id + '/acStates' + @urlEnd
      stateID = JSON.parse(open(stateIDsURL).string)['result'][0]['id']

      stateURL = @urlBase + 'pods/' + @id + '/acStates/' + stateID + @urlEnd
      stateData = JSON.parse(open(stateURL).string)['result']['acState']
      
      @on = stateData['on']
      @mode = stateData['mode']
      @fan = stateData['fan']
      @targetTemp = stateData['targetTemperature']
    end
    
    def getMeasurements
      podDataURL = @urlBase + 'pods/' + @id + '/measurements' + @urlEnd
      podData = JSON.parse(open(podDataURL).string)['result'][0]
      
      @measurementAge = podData['time']['secondsAgo']
      @measurementTime = podData['time']['time']
      @currentTemp = podData['temperature']
      @currentHumidity = podData['humidity']    
    end
    
    def update (on: @on, mode: @mode, fan: @fan, targetTemp: @targetTemp)
      @on = on
      @mode = mode
      @fan = fan
      @targetTemp = targetTemp
    end
    
    def setState
      podUpdateURL = @urlBase + 'pods/' + @id + '/acStates' + @urlEnd

      response = HTTParty.post(
        podUpdateURL,
        { 
          :body => { 'acState' => {"on" => @on, "mode" => @mode, "fanLevel" => @fan, "targetTemperature" => @targetTemp } }.to_json,
          :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
        }
      )
    end
  end
end