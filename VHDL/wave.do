onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider Inputs_Control
add wave -noupdate -label RS -color "goldenrod" 	/LCD2X16_tb/RS
add wave -noupdate -label E -color "goldenrod" 		/LCD2X16_tb/E

add wave -noupdate -divider Input_Data_Hexadecimal
add wave -noupdate -label DATA -color "steel blue" -radix hexadecimal	/LCD2X16_tb/DATA

add wave -noupdate -divider LCD_Display_ASCII
add wave -noupdate -label screen(0) -color "cyan" -radix ASCII		/LCD2X16_tb/screen(0)
add wave -noupdate -label screen(1) -color "cyan" -radix ASCII		/LCD2X16_tb/screen(1)

add wave -noupdate -divider State_LCD
add wave -noupdate -label s_mode -color "pink" 				/LCD2X16_tb/s_mode