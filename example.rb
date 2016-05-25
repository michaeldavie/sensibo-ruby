#!/usr/bin/env ruby

# This script is designed to control both heating and cooling with a dual-fuel
# heating system (heat pump as main and boiler as alternate), and a heat punmp
# for cooling. The Nest controls the boiler directly, and the script passes 
# commands for the heat pump from the Nest to the Sensibo pods.

require './nest.rb'
require './sensibo.rb'

#***** Initialization

@nest = NestThermostat::Nest.new(email: '******', password: '******', temperature_scale: :celsius)
@sensibo = Sensibo::System.new(apiKey: '******')

if @nest.target_temp_type == 'range'
  @target = {'heat' => @nest.temp_low.round(0), 'cool' => @nest.temp_high.round(0)}
else
  @target = {'heat' => @nest.temp.round(0), 'cool' => (@nest.temp.round(0)}
end  

#***** Update pod states

def nestToSensibo

  if @nest.alt_heat_state or (@nest.target_temp_type == 'off') or (@nest.dual_fuel_breakpoint_override == 'always-alt')
    @sensibo.pods.each {|pod| pod.on = false}
    return 'off'
  elsif @nest.main_heat_state
    @sensibo.pods.each {|pod| pod.update(on: true, mode: 'heat', fan: 'auto', targetTemp: @target['heat'])}
    return 'heat'
  elsif @nest.main_ac_state
    @sensibo.pods.each {|pod| pod.update(on: true, mode: 'cool', fan: 'auto', targetTemp: @target['cool'])}
    return 'cool'
  else
    @sensibo.pods.each {|pod| pod.targetTemp = @target[pod.mode]}
    return 'update'
  end

end

#***** Main

@result = nestToSensibo
@sensibo.pods.each {|pod| pod.setState}