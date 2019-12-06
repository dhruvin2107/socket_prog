# require 'em-websocket'


require 'json'
require 'serialport'
# require 'em-websocket'


serial_process = true
websocket_process = false

# EventMachine.run do
#   @channel = EM::Channel.new
  
  if serial_process
    # ESTABLISH CONNECTION TO SERIALPORT
    @baud = 9600
    @usb = "\\\\.\\COM10"

    serial = Win32SerialPort::SerialPort.new
    @sp = serial.open(
      @usb,                        # port name
      @baud,                        # baudrate
      Win32SerialPort::FLOW_NONE,    # no flow control
      8,                             # 8 data bits
      Win32SerialPort::NOPARITY,     # no parity bits
      Win32SerialPort::ONESTOPBIT)   # one stop bit
    
    # # ERROR HANDLING
    # return 0 if false == @sp


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
# end