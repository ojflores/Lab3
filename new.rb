#Oscar Flores
#CPTR 131
#Spring 2015
#Lab 3

#Some of this is from a walkthrough from www.sitepoint.com
require "socket"
class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    run
  end
 
  def run
    loop {
      Thread.start(@server.accept) do | client |
		client.puts "type in password"
		password = "password"
		password_guess = client.gets.chomp
		if password == password_guess
			client.puts "enter username"
			name = client.gets.chomp.to_sym
			@connections[:clients].each do |other_name, other_client|
				if name == other_name || client == other_client				#did this because if both clients are named the same thing
					client.puts "This username already exist"				#the command broadcast wouldn't work
					client.close 											#kill wouldn't close the client and it would just hang there
				end
			end
			puts "#{name} #{client}"
			@connections[:clients][name] = client
			client.puts "CONNECTED"
			listen_user_messages( name, client )
		else 
			client.puts "CONNECTION FAILED"
			client.puts "wrong password, goodbye"
			client.close
		end
			
      end
    }.join
  end
 
  def listen_user_messages( username, client )
    loop {
		client.puts "enter command"
		command = client.gets.chomp
		if command == "BROADCAST"										#I realize that the ifs here could've been case statements
			msg = client.gets.chomp										#felt simpler this way
			@connections[:clients].each do |other_name, other_client|
				unless other_name == username
				other_client.puts "#{username.to_s}: #{msg}"
				end
			end
		end
		if command == "USERLIST"
			client.puts @connections[:clients]
		end
		if command == "DISCONNECT"
			client.close
		end
    }
  end
end
 
Server.new( 3000, "localhost" )