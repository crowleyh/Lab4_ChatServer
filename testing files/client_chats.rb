# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

class Client 
  def initialize
    #might invlude port number
  end
end


require 'socket'      # Sockets are in standard library

hostname = 'localhost'
port = 8000

s = TCPSocket.open(hostname, port)

def post_message(s)
  #s.puts ("LEAVE_CHATROOM: 0 \nJOIN_ID: 0\nCLIENT_NAME: Heather\nMESSAGE: Hi there")
  s.puts("CHAT: 0 \nJOIN_ID: 1\nCLIENT_NAME: Heather\nMESSAGE: ahafsdfd )")

end

s.puts("JOIN_CHATROOM: [chatroom name]\nCLIENT_IP: [IP Address of client if UDP | 0 if TCP] \nPORT: [port number of client if UDP | 0 if TCP] \nCLIENT_NAME: [string Handle to identifier client user] )")
#s.puts("LEAVE_CHATROOM: name \nJOIN_ID: 7 \nCLIENT_NAME: Heather")

puts "going to sleep"
sleep(2);
puts "awake"
post_message(s)

puts "message sent"

while line = s.gets
  puts line.chop
end



s.close               # Close the socket when done
