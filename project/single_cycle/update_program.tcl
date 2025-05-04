# The script only supports RAMB36E1 (data width 32 bits, RAM size > 2KB)
# Tested on Vivado 2024.2 with ram_style / rom_style defined BRAM

# .mem file relative to the project root, or its absolute path
set memfile "../../program/sort_display.mem"

# Cell name of the BRAM
set cellname "Instruction"

proc process_memfile {mem_file} {
    set filein [open $mem_file "r"]
    set fileout [open "program.mem" "w"]
    # Add an initial address to the .mem file
    puts $fileout "@00000000"
    while {[eof $filein] == 0} {
        gets $filein line
        set len [string length $line]
        if {$len == 0} {continue}
        # Check if all characters are hexadecimal
        for {set i 0} {$i < $len} {incr i} {
            set char [string index $line $i]
            if {![string is xdigit $char]} {
                close $filein
                close $fileout
                file delete program.mem
                error "Error: Non-hexadecimal character '${char}' found in line: ${line}"
            }
        }
        # Reverse the byte order
        set new_line ""
        for {set i 0} {$i < $len} {incr i 2} {
            set byte [string range $line $i [expr {$i + 1}]]
            set new_line "${byte}${new_line}"
        }
        puts $fileout $new_line
    }
    close $filein
    close $fileout
    puts "Memory file processed successfully."
}

proc write_mmi {cell_name} {
    set filename "${cell_name}.mmi"
    set fileout [open $filename "w"]

    puts "Found BRAM cells:"
    set brams [get_cells -hier -filter [list PRIMITIVE_TYPE =~ BMEM.bram.* && NAME =~ "*${cell_name}*"]]
    foreach cell $brams {
        puts $cell
        set refname [get_property REF_NAME $cell]
        if {$refname != "RAMB36E1"} {
            close $fileout
            file delete program.mem
            file delete $filename
            error "Error: Unknown BRAM cell type: $refname"
        }
    }
    set bram_num [llength $brams]
    # Check if the number of BRAM cells is a power of 2
    if {[expr {$bram_num & ($bram_num - 1)}] != 0} {
        close $fileout
        file delete program.mem
        file delete $filename
        error "Error: Number of BRAM cells is not a power of 2."
    }
	if {$bram_num >= 32} {
        set block_num [expr {$bram_num / 32}]
		set sequence "7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,23,22,21,20,19,18,17,16,31,30,29,28,27,26,25,24"
	} else {
        set block_num 1
        if {$bram_num == 16} {
            set sequence "7,5,3,1,15,13,11,9,23,21,19,17,31,29,27,25"
        } elseif {$bram_num == 8} {
            set sequence "7,3,15,11,23,19,31,27"
        } elseif {$bram_num == 4} {
            set sequence "7,15,23,31"
        } elseif {$bram_num == 2} {
            set sequence "15,31"
        } else {
            set sequence "31"
        }
	}
	set sequence [split $sequence ","]

    puts $fileout "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    puts $fileout "<MemInfo Version=\"1\" Minor=\"0\">"
    puts $fileout "  <Processor Endianness=\"Little\" InstPath=\"dummy\">"
    puts $fileout "    <AddressSpace Name=\"${cell_name}_BRAM\" Begin=\"0\" End=\"[expr {$bram_num * 4096 - 1}]\">"

    for {set b 0} {$b < $block_num} {incr b} {
        set block_start [expr {$b * 32768}]
        puts $fileout "      <BusBlock>"

        foreach msb_seq $sequence {
            foreach cell $brams {
                set placement [get_property LOC $cell]
                set placement [lindex [split $placement "_"] 1]
                set msb [get_property ram_slice_end $cell]
                set lsb [get_property ram_slice_begin $cell]
                set begin [expr {4 * [get_property ram_addr_begin $cell]}]
                set end [expr {4 * [get_property ram_addr_end $cell] + 3}]
                if {$msb_seq == $msb && $block_start == $begin} {
                    puts $fileout "        <BitLane MemType=\"RAMB32\" Placement=\"${placement}\">"
                    puts $fileout "          <DataWidth MSB=\"${msb}\" LSB=\"${lsb}\"/>"
                    puts $fileout "          <AddressRange Begin=\"${begin}\" End=\"${end}\"/>"
                    puts $fileout "          <Parity ON=\"false\" NumBits=\"0\"/>"
                    puts $fileout "        </BitLane>"
                    puts $fileout ""
                    break
                }
            }
        }
        puts $fileout "      </BusBlock>"
        puts $fileout ""
    }
    puts $fileout "    </AddressSpace>"
    puts $fileout "  </Processor>"

    puts $fileout "  <Config>"
    puts $fileout "    <Option Name=\"Part\" Val=\"[get_property PART [current_project]]\"/>"
    puts $fileout "  </Config>"
    puts $fileout "</MemInfo>"

    close $fileout
    puts "MMI file created successfully."
}

cd [get_property DIRECTORY [current_project]]

process_memfile $memfile

write_mmi $cellname

set project [get_property NAME [current_project]]

if {![file exists ./${project}.runs/impl_1/top.bit]} {
    file delete program.mem
    file delete ${cellname}.mmi
    error "Error: Bitstream not found."
}

exec updatemem \
-meminfo ${cellname}.mmi \
-data program.mem \
-bit ./${project}.runs/impl_1/top.bit \
-proc dummy \
-out ./${project}.runs/impl_1/new.bit \
-force
puts "Bitstream generated successfully."

file delete program.mem
file delete ${cellname}.mmi
file delete {*}[glob updatemem*]
puts "Cleaned up temporary files."

return -code ok "Done."
