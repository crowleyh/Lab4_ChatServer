# To change this license header, choose License Headers in Project Properties.

require 'socket'                 
require 'thread'
load 'chatroom.rb'

PortNumber = 8000;

numClients = 0; #first client is given ID 0, this is incremented every time a new client is added
numChatrooms = 0;
listOfChatrooms = Hash.new #maps chatroom names to array numbers in arrayOfChatrooms
arrayOfChatrooms = Array.new
#use chatroom name as a key mapping names to chatrooms

class ChatServer                                                
  attr_accessor :socket, :IsOpen                           
  def initialize()                  
    @socket = TCPServer.open(PortNumber)
    @IsOpen = true
  end
end

def sendJoinReply(client,chatroom_name, server_ip, room_ref, join_id)
  client.puts ("JOINED_CHATROOM: #{chatroom_name}\nSERVER_IP: #{server_ip}\nPORT: 0\nROOM_REF: #{room_ref}\nJOIN_ID: #{join_id}")
  return 0
end

def sendLeaveReply(client, room_ref, join_id)
  client.puts ("LEFT_CHATROOM: #{room_ref}JOIN_ID: #{join_id}")
  return 0
  #works to here
end


#create chatroom if one by that name doesnt already exist
#add client

def addClientToChatroom(client, chatroom_name, client_name, listOfChatrooms, arrayOfChatrooms, numChatrooms)
  if (listOfChatrooms.key?(chatroom_name))
    index = listOfChatrooms.fetch(chatroom_name)
    #add client to existing chatroom at specified index
    (arrayOfChatrooms.at(index)).add_client(client)  
  
  else
    newChatroom = Chatroom.new(chatroom_name, client) #problem here
    arrayOfChatrooms << newChatroom
    listOfChatrooms.store(chatroom_name, numChatrooms)
    #puts "key: #{chatroom_name} value : #{numChatrooms} stored in listOfChatrooms"
    numChatrooms = numChatrooms +1
  end 
  return 0
 
end

def removeClientFromChatroom(client, room_ref, arrayOfChatrooms)
  #room ref to integer
  (arrayOfChatrooms.at(room_ref.to_i)).remove_client(client)
  return 0
end



#create work queue and server
IPAddress = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]
#PortNumber= ARGV[0]           take port number as argument from command line
server = ChatServer.new()
work_q = Queue.new


# 5 threads serve the clients
workers = (0...5).map do
  Thread.new do
    begin   
      while server.IsOpen
        if work_q.length > 0
          client = work_q.pop               
          
          # SERVE CLIENT
          while(true)
            line = client.gets
            #1 HELO Message
            if line.include?("HELO")
              client.puts "HELO text\nIP:[#{IPAddress}]\nPort:[#{portnum}]\nStudentID:[10303365]"
            
            #2 Kill service
            elsif (line == "KILL_SERVICE\n")
              puts "Kill servive received"
              server.socket.close              #this needs to be fixed- atm it just crashes
              server.IsOpen = false
            
            #3 join chatroom
            elsif (line.match(/^JOIN_CHATROOM:/))
              chatroom_name = line.split(": ").last
              line2 = client.gets
              if line2.match(/^CLIENT_IP:/)
                client_ip = line2.split(": ").last
                line3 = client.gets
                if line3.match(/^PORT:/)
                  client_port = line3.split(": ").last
                  line4 = client.gets
                  if line4.match(/^CLIENT_NAME:/)
                    client_name = line4.split(": ").last
                    numClients = numClients +1
                    sendJoinReply(client,chatroom_name, IPAddress,numChatrooms, numClients)
                    addClientToChatroom(client, chatroom_name, client_name, listOfChatrooms, arrayOfChatrooms, numChatrooms)
                  end
                end
              end
  
            #4 leave chatroom
            elsif (line.match(/^LEAVE_CHATROOM:/))
              room_ref = line.split(": ").last
              line2 = client.gets
              if line2.match(/^JOIN_ID:/)
                join_id = line2.split(": ").last
                line3 = client.gets
                if line3.match(/^CLIENT_NAME:/)
                  client_name = line3.split(": ").last
                  sendLeaveReply(client, room_ref, join_id)
                  removeClientFromChatroom(client, room_ref, arrayOfChatrooms)
                end
              
              end 
             
            #5 Chat
            elsif (line.match(/^CHAT:/))
              room_ref = line.split(": ").last
              line2 = client.gets
              if(line2.match(/^JOIN_ID:/))
                join_id = line.split(": ").last
                line3 = client.gets
                if(line3.match(/CLIENT_NAME:/))
                  client_name = line3.split(": ").last
                  message = client.gets.split(": ").last
                  index = listOfChatrooms.fetch(chatroom_name)
                  # post the message to the appropriate chatroom
                  arrayOfChatrooms.at(index).post_message(index, client_name, message)
                end
              end
            
            #6 Close client
            elsif (line.match(/^DISCONNECT:/))
              client.close           
            end 
          end        
        end                                                
      end
    
    rescue ThreadError
    end
  end
end; 


#main loop accepts clients and pushes them onto the queue
while server.IsOpen                                                                          
  work_q.push(server.socket.accept)  
end
workers.map(&:join);               
