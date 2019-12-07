require 'serialport'

# ESTABLISH CONNECTION TO SERIALPORT

@sp = SerialPort.new("/dev/rfcomm0", 9600)
while true do
  printf("%c", @sp.getc)
end

@sp.close  
