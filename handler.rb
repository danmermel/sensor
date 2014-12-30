#! /usr/bin/ruby
require 'cgi'

#$stdout.reopen("handler_out.txt", "w")
#$stderr.reopen("handler_err.txt", "w")

puts "here i am"
cgi = CGI.new

input = cgi.params 
command = "sudo ruby sensor.rb #{input['direction']}"
puts command
exec(command)

