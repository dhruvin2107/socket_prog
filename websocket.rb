require 'em-websocket'
require 'json'
require 'serialport'


serial_process = true
websocket_process = true

EventMachine.run do
  @channel = EM::Channel.new
  
  if serial_process
    # ESTABLISH CONNECTION TO SERIALPORT
    @baud = 9600
    @usb = ARGV[3]
    @sp = SerialPort.new(@usb, @baud, 8, 1, SerialPort::NONE)
    print "SERIAL OPEN:" + @usb
    @sp.write "1"
    # @sp = Win32SerialPort::SerialPort.new(@usb, @baud, 8, 1, SerialPort::NONE)
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
  
  # CONNECT TO WEBSOCKET
  # ruby websocket.rb -p 3011
  if websocket_process
    ip="localhost"
    @port = ARGV[1]
    print ARGV[1] 

    print "M: BINDING TO: #{ip} PORT #{@port}\n"
    
    EM::WebSocket.start(:host => ip, :port => @port) do |ws|
      ws.onopen{
        print "M: OPENED!\n"
        @sid = @channel.subscribe { |msg| ws.send msg }
        @channel.push "#{@sid} connected!"
      }
      ws.onclose{
        print "CLOSING\n"
        if @sid
          @channel.unsubscribe(@sid)
        end
      }
      # WHENEVER WEBSOCKET DETECTS MESSAGE, SEND CALL
      ws.onmessage do |msg|
          print "OUT:" + msg +"\n"
          if serial_process
            @sp.write(msg)
          end
      end
    end

    puts "M: SERVER STARTED"
  end
end