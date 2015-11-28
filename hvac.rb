#!/usr/bin/env ruby

require 'ap'
require 'nest_thermostat'
require './sensibo.rb'

nest = NestThermostat::Nest.new(email: 'user@email.com', password: 'mypassword', temperature_scale: :celsius)
sensibo = Sensibo::System.new('myapikey')

sensiboOn = sensibo.pods[0].on
sensiboMode = sensibo.pods[0].mode
sensiboFan = 'auto'
sensiboTemp = sensibo.pods[0].targetTemp

nestMode = nest.status["shared"][nest.device_id]["target_temperature_type"]
nestTemp = nest.temp.round(0)

boilerCall = nest.status["shared"][nest.device_id]["hvac_alt_heat_state"]
heatPumpCall = (nest.status['shared'][nest.device_id]['hvac_heater_state'] or nest.status['shared'][nest.device_id]['hvac_ac_state'])

if (heatPumpCall and !sensiboOn)
  sensiboUpdate(true)
end

if (sensiboOn and (sensiboTemp != nestTemp) or (sensiboMode != nestMode))
  sensiboUpdate(true)
end

if (boilerCall and sensiboOn)
  sensiboUpdate(false)
end

def sensiboUpdate (on)
  case nestMode
    when 'heat' podTemp = nestTemp + 2
    when 'cool' podTemp = nestTemp
  end
  
  sensibo.pods.each do |pod|
    pod.setState(on, nestMode, sensiboFan, podTemp)
  end
end