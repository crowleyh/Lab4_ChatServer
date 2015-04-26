# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

class Chatroom
  #initialise it when needed for use
  attr_accessor :name, :clientList
  def initialize (name, client)
    @@name = name

    #each chatroom contains array of clients
    @@clientList = Array.new
    @@clientList<<client 
    
    puts "client added to new chatroom"
    puts client
    #@@clientList.each do |client1|
    #puts client1
    #end    
  end 
  
  def add_client(client)
    @@clientList<<client 
    puts "client added to existing chatroom"
    puts client
  end
  
  def remove_client(client)
    @@clientList.delete(client)
    puts "client removed: "
    puts client
  end
  
  def self.client_list
    @@clientList
  end
  
  def post_message (room_ref, client_name, message)
    @@clientList.compact.each do |clients| 
      clients.puts( "CHAT: #{room_ref}\nCLIENT_NAME:#{client_name}\nMESSAGE:#{message}")
    end
  end
  

end

