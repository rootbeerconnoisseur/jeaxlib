# Clean up:
# Create to_marshal and load_marshal functions for saving and loading accounts
# Make character creation process begin a new thread
# Create a FIleIO so file writes and loads can be done in a separate thread

module SocketManager
	def handle_connection
		mudnote(:security, "Checking #{@ip}...\t" + RESET + "[" + DGREEN + "ACCESS GRANTED" + RESET + "]\n")
		@handler = Fiber.new do
			send_data(DGREEN + "Welcome" + RESET + " to " + DCYAN + MUDNAME + RESET + " on " + DCYAN + MUDLIB + RESET + "\n\n")
			send_data(DYELLOW + "\nDEBUG: OBJECT IS #{self}\n" + RESET)
			send_data(DWHITE + "\tLOGIN MENU\n")
			send_data("\t\t1. Log in\n")
			send_data("\t\t2. Create new account\n\n")
			send_data("Option (1 or 2): " + RESET)
			choice1 = Fiber.yield false
			choice1 = choice1.to_i
			if choice1 == 1 then
				send_data(DWHITE + "Account name: " + RESET)
				while !valid_login((account_name = Fiber.yield false).downcase)
					send_data(DWHITE + "Invalid name.\n")
					send_data("Account name: " + RESET)
				end
				send_data(DWHITE + "Welcome, #{account_name.capitalize}!\n")
				send_data("Loading '#{account_name.capitalize}'...")
				if @account_data = YAML::load(File.open("data/#{account_name.downcase}/#{account_name.downcase}.acc", "r")) then
					send_data(DYELLOW + "\nDEBUG: SERVER DIRECTORY IS #{Dir.pwd}\n" + RESET)
					send_data(DYELLOW + "\nDEBUG: OBJECT IS #{self}\n" + RESET)
					send_data("[" + DGREEN + "OK" + DWHITE + "]\n" + RESET)
					send_data(DWHITE + "Password: " + RESET)
					pass_count = 0
					while !valid_password((passwd = Fiber.yield false)) && pass_count < 3
						pass_count += 1
						mudnote(:security, "Access denied.")
						if pass_count == 3 then
							mudnote(:security, "Three failed attempts have been logged from #{@ip}!")
							EventMachine::add_timer(0.01) do
								close_connection
							end
						else
							send_data(DWHITE + "Password: " + RESET)
						end
					end
					select_character
				else
					send_data("[" + DRED + "ERROR" + DWHITE + "] Account data not found, contact administration.\n" + RESET)
					EventMachine::add_timer(0.01) do
						close_connection
					end
				end
			elsif choice1 == 2 then
				create_account
			else
				close_connection
			end
		end
		@handler.resume
	end

	def valid_login(account_name)
		if account_name.length > 12 then
			return false
		elsif !File.exists?("data/#{account_name.downcase}/#{account_name.downcase}.acc") then
			return false
		else
			return true
		end
	end
	
	def valid_password(passwd)
		if passwd == @account_data.password then
			return true
		else
			return false
		end
	end
	
	def select_character
		send_data(DYELLOW + "\nDEBUG: OBJECT IS #{self}\n" + RESET)
		send_data(DWHITE + "\n\tA.A.I. - ACCOUNT ADMINISTRATION INTERFACE\n")
		send_data("\n\t\tCharacters:\n")
		if @account_data.characters then
			@account_data.characters.each do |char|
				send_data("\t\t\t#{char.capitalize}\n")
			end
		else
			send_data("\t\t\tNone\n")
		end
		send_data("\n\t\t1. Create a character\n")
		send_data("\t\t2. Delete a character\n\n")
		send_data("Option (1 or 2): " + RESET)
		option = (Fiber.yield false).to_i
		if option == 1 then
			create_character
		else
			send_data("I didn't get any input")
		end
	end
	
	def create_character
		@character_data = Body.new
		@character_data.owner = self #set body's socket
		@character_data.account = @account_data
		send_data(DYELLOW + "\nDEBUG: ACCOUNT FOR BODY: #{@account_data} (#{@account_data.name})")
		
		send_data(DWHITE + "\n\tC.C.I. - CHARACTER CREATION INTERFACE\n")
		send_data("\n\tLet's begin designing your new body...")
		send_data("\n\nDesired character name: " + RESET)
		#put a regex here later to make sure its only letters
		@character_data.name = (Fiber.yield false).downcase
		send_data(DWHITE + "#{@character_data.name.capitalize}...that's a good name.")
		
		send_data(DGREEN + "\n\nA new body fades into existence in front of you.")
		send_data(DWHITE + "\nEntering body...")
		@body = @character_data #set socket's body
		send_data(DYELLOW + "\nDEBUG: BODY IS #{@body}" + RESET)
		
		#send_data(DYELLOW + "DEBUG: ACCOUNT NAME FOR BODY: #{@character_data.owner}")
	end

	def create_account
		@account_data = Account.new
		send_data(DYELLOW + "\nDEBUG: ACCOUNT OBJECT: #{@account_data}")
		send_data(DYELLOW + "\nDEBUG: OBJECT IS #{self}\n" + RESET)
		send_data(DWHITE + "\n\tA.C.I. - ACCOUNT CREATION INTERFACE\n")
		send_data("\n\tPlease take a moment to fill out some information.")
		send_data("\n\nDesired account name: " + RESET)
		while valid_login((account_name = Fiber.yield false).downcase)
			send_data(DWHITE + "Apologies, that name is already taken.")
			send_data("\n\nDesired account name: " + RESET)
		end
		send_data(DWHITE + "#{account_name}...are you sure about that? (y/n): " + RESET)
		yn = (Fiber.yield false).downcase
		while yn == "n"
			send_data(DWHITE + "Make up your mind.")
			send_data("\nDesired account name: " + RESET)
			while valid_login((account_name = Fiber.yield false).downcase)
				send_data(DWHITE + "\nThat name is already taken.")
				send_data("\n\nDesired account name: " + RESET)
			end
			send_data(DWHITE + "#{account_name}...are you sure about that? (y/n): " + RESET)
			yn = (Fiber.yield false).downcase
		end
		@account_data.name = account_name
		send_data(DWHITE + "Password: " + RESET)
		@account_data.password = Fiber.yield false
		
		send_data(DWHITE + "\n\nCreating account...")
		@account_data.date_created = Time.now
		if (Dir.mkdir("data/#{account_name.downcase}")) then
			send_data(DGREEN + "\nAccount directory created.")
		end
		newAccFile = File.open("data/#{account_name.downcase}/#{account_name.downcase}.acc", "w")
		send_data(DGREEN + "\nAccount database created.")
		newAccFile.puts(@account_data.to_yaml)
		send_data(DGREEN + "\nAccount saved.")
		newAccFile.close
		
		send_data(DWHITE + "\nAccount created! Log in!\n\n")
		send_data(RED + "---------------------------------------\n\n" + RESET)
		handle_connection
	end
end
