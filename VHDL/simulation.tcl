#!/usr/bin/tclsh
quit -sim

set DIR_ROOT "."

exec vlib work

set vhdls [list \
	"$DIR_ROOT/LCD2X16.vhd" \
	"$DIR_ROOT/LCD2X16_tb.vhd" \
	]
	
foreach src $vhdls {
	if [expr {[string first # $src] eq 0}] {puts $src} else {
		vcom -93 -work work $src
	}
}

vsim -voptargs=+acc work.LCD2X16_tb
do wave.do
run 40 ms
