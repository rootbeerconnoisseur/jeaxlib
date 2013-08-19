#Telnet protocol definitions

#Commands
IAC 	= 255 		#interpret as command
DONT 	= 254		#dont do instruction
DO 		= 253		#do instruction
WONT 	= 252		#wont do instruction
WILL 	= 251		#will do instruction
SB 		= 250		#segmentation begin
GA 		= 249		#go ahead
EL 		= 248		#erase line
EC 		= 247		#erase character
AYT 	= 246		#are you there
AO 		= 245		#abort output
IP 		= 244		#interrupt
BRK 	= 243		#break
DM 		= 242		#data mark
NOP 	= 241		#no-op
SE 		= 240		#segmentation end
EOR 	= 239		#end of record
ABORT 	= 238		#abort
SUSP 	= 237		#suspend
EOF 	= 236		#end of file

TELOPT_ECHO = 1 	#echo

#Options
BINARY         =   0 # Transmit Binary - RFC 856
ECHO           =   1 # Echo - RFC 857
RCP            =   2 # Reconnection
SGA            =   3 # Suppress Go Ahead - RFC 858
NAMS           =   4 # Approx Message Size Negotiation
STATUS         =   5 # Status - RFC 859
TM             =   6 # Timing Mark - RFC 860
RCTE           =   7 # Remote Controlled Trans and Echo - RFC 563, 726
NAOL           =   8 # Output Line Width
NAOP           =   9 # Output Page Size
NAOCRD         =  10 # Output Carriage-Return Disposition - RFC 652
NAOHTS         =  11 # Output Horizontal Tab Stops - RFC 653
NAOHTD         =  12 # Output Horizontal Tab Disposition - RFC 654
NAOFFD         =  13 # Output Formfeed Disposition - RFC 655
NAOVTS         =  14 # Output Vertical Tabstops - RFC 656
NAOVTD         =  15 # Output Vertical Tab Disposition - RFC 657
NAOLFD         =  16 # Output Linefeed Disposition - RFC 658
XASCII         =  17 # Extended ASCII - RFC 698
LOGOUT         =  18 # Logout - RFC 727
BM             =  19 # Byte Macro - RFC 735
DET            =  20 # Data Entry Terminal - RFC 732, 1043
SUPDUP         =  21 # SUPDUP - RFC 734, 736
SUPDUPOUTPUT   =  22 # SUPDUP Output - RFC 749
SNDLOC         =  23 # Send Location - RFC 779
TTYPE          =  24 # Terminal Type - RFC 1091
EOREC          =  25 # End of Record - RFC 885
TUID           =  26 # TACACS User Identification - RFC 927
OUTMRK         =  27 # Output Marking - RFC 933
TTYLOC         =  28 # Terminal Location Number - RFC 946
REGIME3270     =  29 # Telnet 3270 Regime - RFC 1041
X3PAD          =  30 # X.3 PAD - RFC 1053
NAWS           =  31 # Negotiate About Window Size - RFC 1073
TSPEED         =  32 # Terminal Speed - RFC 1079
LFLOW          =  33 # Remote Flow Control - RFC 1372
LINEMODE       =  34 # Linemode - RFC 1184
XDISPLOC       =  35 # X Display Location - RFC 1096
ENVIRON        =  36 # Environment Option - RFC 1408
AUTHENTICATION =  37 # Authentication Option - RFC 1416, 2941, 2942, 2943, 2951
ENCRYPT        =  38 # Encryption Option - RFC 2946
NEW_ENVIRON    =  39 # New Environment Option - RFC 1572
TN3270         =  40 # TN3270 Terminal Entry - RFC 2355
XAUTH          =  41 # XAUTH
CHARSET        =  42 # Charset option - RFC 2066
RSP            =  43 # Remote Serial Port
CPCO           =  44 # COM port Control Option - RFC 2217
SUPLECHO       =  45 # Suppress Local Echo
TLS            =  46 # Telnet Start TLS
KERMIT         =  47 # Kermit tranfer Option - RFC 2840
SENDURL        =  48 # Send URL
FORWARDX       =  49 # Forward X
PLOGON         = 138 # Telnet Pragma Logon
SSPI           = 139 # Telnet SSPI Logon
PHEARTBEAT     = 140 # Telnat Pragma Heartbeat
EXOPL          = 255 # Extended-Options-List - RFC 861

#Supports
TELOPT_MXP  = 91 	#mxp
#Missing MCCP and COMPRESS

TEL_END 	= "\0"

#Instruction combinations
DO_ECHO		= IAC.chr + WONT.chr + TELOPT_ECHO.chr + TEL_END
DONT_ECHO	= IAC.chr + WILL.chr + TELOPT_ECHO.chr + TEL_END

#Color chart
RESET 	= "\e[0m"
BLACK 	= "\e[0;30m"
RED		= "\e[0;31m"
GREEN	= "\e[0;32m"
YELLOW	= "\e[0;33m"
BLUE	= "\e[0;34m"
PINK	= "\e[0;35m"
CYAN	= "\e[0;36m"
WHITE	= "\e[0;37m"
DBLACK	= "\e[1;30m"
DRED	= "\e[1;31m"
DGREEN	= "\e[1;32m"
DYELLOW	= "\e[1;33m"
DBLUE	= "\e[1;34m"
DPINK	= "\e[1;35m"
DCYAN	= "\e[1;36m"
DWHITE	= "\e[1;37m"
BBLACK	= "\e[40m"
BRED	= "\e[41m"
BGREEN	= "\e[42m"
BYELLOW	= "\e[43m"
BBLUE	= "\e[44m"
BPINK	= "\e[45m"
BCYAN	= "\e[46m"
BWHITE	= "\e[47m"
