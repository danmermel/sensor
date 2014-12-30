#! /usr/bin/ruby

require 'wiringpi'

# this is just to write the debug somewhere
$stdout.reopen("moto_out.txt", "w")  
$stderr.reopen("moto_err.txt", "w")

io = WiringPi::GPIO.new

direction =  ARGV[0] # gets the direction from the command line argument
puts direction

# 0 = right fwd
# 3 = right back
# 4 = left fwd
# 1 = left back

puts "turning on"

begin
   io.mode(0,OUTPUT)  # motor
   io.mode(1,OUTPUT)
   io.mode(3,OUTPUT)
   io.mode(4,OUTPUT)

   io.mode(11,INPUT)  # sensor
   io.mode(10,OUTPUT)

rescue
   puts "failed to set pins"
   puts $!, $@
end


def stop_all(var)  #stops everything before next manouvre
   var.write(0,LOW)
   var.write(1,LOW)
   var.write(3,LOW)
   var.write(4,LOW)
end

def move_and_check(var)    #goes forward until it decides obstacle is close

   stop_all(var)
   var.write(3,HIGH)
   var.write(1,HIGH)
   puts "going forward"
   puts "Distance measurement in progress..."
   distance = 100   # a random big number to initialise
   while distance > 40 do    #  40cm, depends how close you want to get
      pulse_duration = 0  # reset it
      sleep(0.1)  # wait a bit..

      var.write(10, HIGH)   # send pulse
      sleep(0.000001)
      var.write(10, LOW)

      pulse_start= Time.now
      while var.read(11) == 0 do    #echo not started
         pulse_start = Time.now
      end

      while var.read(11) == 1 do   #echo started.. waiting for return sound
         pulse_end = Time.now
      end

      pulse_duration = pulse_end - pulse_start
      puts "pulse duration is " + pulse_duration.to_s

      distance = pulse_duration * 17150  #in cm. using speed = distance /time
      puts "Distance is " + distance.to_s
   end  #while
   return  # will exit loop when distance is too short
end  # def move_and_check

def find_new_dir(var)  
# find a new position to go forward by rotating slowly and checking again

   stop_all(var)
   var.write(3,HIGH)  # only use one wheel, hence turn
   sleep(0.5)  # wait for some time, keep turning
   return  # goes back and starts to move forward again

end

# This is where the actual script starts

if direction == "[fwd]" then  #forward
   io.write(10, LOW)
   puts "waiting for sensor to settle...."
   sleep(2)
   while true do   # infinite loop of doom!
      puts "going to move"
      move_and_check(io)
      find_new_dir(io)
   end
end

stop_all(io) if direction == "[stp]"
