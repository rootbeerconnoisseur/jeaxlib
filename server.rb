require 'eventmachine'
require 'thread'
require 'fiber'
require 'socket'
require 'yaml'

load "network/socketmanager.rb"
load "network/telnet.rb"
load "network/login.rb"
load "config.rb"
load "library/account.rb"
load "library/body.rb"

$server = true
$reboot = false
$shutdown = false
$mud_lock = false
$wiz_lock = false

$socks = [] #active sockets

class Server
	def self.shutdown
		puts "[SHUTDOWN] Shutting JeaxLib down..."
		announce("Server is shutting down...")
		EventMachine::next_tick do
			EventMachine::stop_server($server)
			EventMachine::stop_event_loop
			$server = nil
		end
	end
	
	def self.reboot
		puts "[REBOOT] Rebooting JeaxLib..."
		announce("Server is rebooting...")
		EventMachine::next_tick do
			EventMachine::stop_server($server)
			EventMachine::stop_event_loop
			$server = true
		end
	end
	
	def self.announce(*announcement)
		$socks.each do |sock|
			sock.send_data(WHITE + "[ANNOUNCEMENT] " + RESET + announcement.join(" ") + "\n")
		end
	end
	
	def self.heartbeat
		puts "[HEARTBEAT]"
	end
end

if __FILE__ == $0
	$serverlock = Mutex.new

	server_thread = Thread.new do
		loop do
			server_input = gets
			server_input.strip!
			next if server_input.empty?
			args = server_input.split(' ')
			cmd = args.shift
	
			if Server.respond_to?(cmd.to_sym) then
				Server.send(cmd.to_sym, *args)
			else
				puts "[ERROR] Command not found: #{server_input}"
			end
		end
	end

	while $server
		EventMachine::run do	
			puts "[BOOT] Starting JeaxLib..."
			EventMachine::add_timer(1) do
				begin
					$server = EventMachine::start_server("0.0.0.0", MUDPORT, SocketManager)
					puts "[SUCCESS] JeaxLib is now running on port #{MUDPORT}"
					puts "[READY] Server ready for commands"
				rescue Exception
					puts "[ERROR] JeaxLib boot failed."
					puts $!
				end
			end
			
			EventMachine::add_periodic_timer(15) do
				Server.heartbeat
			end
			
			EventMachine::add_periodic_timer(0.05) do
				if $shutdown
					Server.shutdown
				elsif $reboot
					Server.reboot
				end
			end
		end
	end
end
