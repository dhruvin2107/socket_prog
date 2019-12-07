require 'json'
require 'serialport'
require 'em-websocket'

serial_process = true

EventMachine.run do
  @channel = EM::Channel.new
  
    # ESTABLISH CONNECTION TO SERIALPORT
    @baud = 9600
    @usb = ARGV[1]
    @sp = SerialPort.new(@usb, @baud, 8, 1, SerialPort::NONE)
    print "SERIAL OPEN:" + @usb
    @sp.write "1"
    @sid = nil
    
    EM::defer do
      loop do
        data = @sp.readline("\n") 
        puts "IN: "+ data
        next if !data or data.to_s.size < 1
        @channel.push data
      end
    end
    end
    