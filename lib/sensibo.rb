require 'open-uri'
require 'json'
require 'httparty'

module Sensibo
  class System

    attr_reader :pods

    def initialize(key)
  
      @apiKey = key
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
  
    attr_reader :id, :measurementAge, :measurementTime, :currentTemp, :currentHumidity, :on, :mode, :fanLevel, :targetTemp
  
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
      @fanLevel = stateData['fanLevel']
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
    
    def setState(on, mode, fanLevel, targetTemp)
      podUpdateURL = @urlBase + 'pods/' + @id + '/acStates' + @urlEnd

      response = HTTParty.post(
        podUpdateURL,
        { 
          :body => { 'acState' => {"on" => on, "mode" => mode, "fanLevel" => fanLevel, "targetTemperature" => targetTemp } }.to_json,
          :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
        }
      )
      getState
    end
  end
end