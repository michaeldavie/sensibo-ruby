#!/usr/bin/env ruby

# This script is designed to control both heating and cooling with a dual-fuel
# heating system (heat pump and boiler) and a heat punmp for cooling. The Nest
# controls the boiler directly, and the script passes commands for the heat
# pump from the Nest to the Sensibo

require 'nest_thermostat'
require 'sensibo'

#***** Initialization

@nest = NestThermostat::Nest.new(email: 'user@email.com', password: 'mypassword', temperature_scale: :celsius)
@sensibo = Sensibo::System.new('myapikey')
@pods  = @sensibo.pods

#***** Get current state

@nestMode = nest.status["shared"][nest.device_id]["target_temperature_type"]
@nestTemp = nest.temp.round(0)
@boilerCall = nest.status["shared"][nest.device_id]["hvac_alt_heat_state"]
@heatPumpCall = (nest.status['shared'][nest.device_id]['hvac_heater_state'] or nest.status['shared'][nest.device_id]['hvac_ac_state'])

@sensiboOn = @pods[0].on
@sensiboMode = @pods[0].mode
@sensiboTemp = @pods[0].targetTemp

#***** Decide if an update is needed and request it

def updateIfNeeded

  case @sensiboOn

  when false
    if @heatPumpCall
      sensiboUpdate(true)
      return 'swtich on'
    else return 'still off'
    end

  when true
    if @boilerCall
      sensiboUpdate(false)
      return 'swtich off'
    end

    if (@sensiboMode != @nestMode)
      sensiboUpdate(true)
      return 'mode change'
    end

    if (@sensiboTemp != @nestTemp)
      sensiboUpdate(true)
      return 'temp change'
    else return 'still on, no change'
    end
  end
end

#***** Send update

def sensiboUpdate (podOn)
  sensiboFan = 'auto'

  @pods.each do |pod|
    pod.setState(podOn, @nestMode, sensiboFan, @nestTemp)
  end
end

#***** Main

puts updateIfNeeded