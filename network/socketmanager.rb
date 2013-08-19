module SocketManager
	#include JeaxLib::Security
	attr_reader :ip
	attr_accessor :status, :player, :body
	
	def post_init
		if $mud_lock then
			mudnote(:security, "The server is currently locked.")
			close_connection
		elsif $wiz_lock then
			mudnote(:security, MUDNAME + " is under active development.")
			close_connection
		else
			$socks << self
			send_data(MOTD + "\n")
			@status = :login
			@body = nil
			@handler = nil
			@data_parser = nil
			@cmd_queue = []
			@ip = Socket.unpack_sockaddr_in(get_peername)[1]
			#Security.is_banned?
			handle_connection
			handle_input
		end
	end
	
	def handle_input
		@data_parser = Fiber.new do
			
			data_arr = [] # data array
			buffer = ""
			loop do # loop forever
				data = Fiber.yield(data_arr)
				data_arr = [] # clear data_arr
				
				while !data.empty?
					input = data.slice!(0) #take first character of input
					
					if input.ord == IAC then #if numeric value of character == 255
						seq = "" + input
						input = data.slice!(0) #get next command, it's telnet
						
						if input.ord == DO || input.ord == DONT then
							seq = seq + input
							input = data.slice!(0) #get next, telnet option
							seq = seq + input + TEL_END #seq = full telnet command
						end
						
						data_arr << seq
						next
					elsif input.ord == "\n"[0].ord #else
						buffer.strip!
						if !buffer.empty?
							data_arr << buffer
						end
						buffer = ""
						next
					end
					
					buffer << input
				end
			end
		end
		@data_parser.resume
	end
	
	def receive_data(data)
		data = "\n" if data == nil
		data.gsub!(/\r\n|\n\r|\r|\n/,"\n")
		data = "\n" if data.empty? #if blank, give a blank line
		
		pdata = @data_parser.resume(data) #put data through data parser
		
		pdata.each do |d| #if blank line, discard
			data.gsub!(/\n/,"")
			if d.length == 0 then
				pdata.delete d
			end
		end
		
		pdata << "" if pdata.empty? #don't add if blank
		
		pdata.each do |d| #add command to command queue
			@cmd_queue.push(d)
		end
		
		#process cmd_queue
		while !@cmd_queue.empty?
			command = @cmd_queue.shift #grab command from stack

			return if command == nil

			if command.length != 0
				case @status
					when :login
						if @handler.alive?
							if (@handler.resume(command.downcase)) == true
								send_data("Disconnecting...\n")
								close_connection
								return
							end
						end
					when :playing
						handle_command(command)
					else
						puts "#{self} in bad state."
				end
			end
		end #end processing
	end
	
	def handle_command(command)
		send_data("Received: #{command}")
	end
	
	def mudnote(category, message)
		if category == :security then
			send_data(DWHITE + "[" + DRED + "MUDSEC" + DWHITE + "] #{message}\n" + RESET)
		end
	end
	
	def unbind
		$socks.delete(self)
	end
end
