#!/usr/bin/env ruby

require './sensibo.rb'

#***** Initialization

@sensibo = Sensibo::System.new(apiKey: '******')

#***** Print pod measurements

@sensibo.pods.each {|pod| puts pod.id + ' - ' + pod.currentTemp}

#***** Update pod settings locally

@sensibo.pods.each {|pod| pod.on = false}
@sensibo.pods.each {|pod| pod.targetTemp = 23}
@sensibo.pods.each {|pod| pod.update(on: true, mode: 'cool', fan: 'auto', targetTemp: 23)}

#***** Push values to pods

@sensibo.pods.each {|pod| pod.setState}