.equ PS2_DATA_1, 0xFF200100
.equ PS2_CTL_1, 0xFF200104
.equ PS2_DATA_2, 0xFF200108
.equ PS2_CTL_2, 0xFF20010C

.equ ADDR_REDLEDS, 0xFF200000

.global _start
_start:
	# Setup SP
    movia sp, 0x0000FFF0
    
	# Put PS2 Data and Control addr in reg
    movia r16, PS2_DATA_1
    movia r17, PS2_CTL_1
    
	# Setup PS2 control interrupt
    # Setup the first bit of PS2 CTL to 1 to enable PS2 Read interrupt,
    # PS2 Controller will trigger interrupt on data received.
    movi r8, 0b1
    stwio r8, 0(r17)
    
    # Enable IRQ 7 for PS2 controller 1
    # PS2 controller 1 use IRQ 7 to request interrupt.
    movi r8, 0b10000000
    wrctl ienable, r8
    
    # Enable interrupt on CPU
    movi r8, 0b1
    wrctl status, r8
    
    # Loop wait for interrupt
loop:
	br loop
    
# Interrupt handler
.section .exceptions, "ax"
interrupt_handler:
	# PL
    addi sp, sp, -8
    stw r8, 0(sp)
    stw r9, 4(sp)
    
	# which device caused the interrupt?
   	rdctl et, ctl4                      # read out iPending
    andi et, et, 0b10000000             # Mask reading
    beq et, r0, exit_interrupt_handler  # If not cause by PS2, exit
    
    
    # handle interrupt
    # read out the whole data reg for the PS2 Controller
    movia r8, PS2_DATA_1
    ldwio r8, 0(r8)                     # Data now in r8
    
    
    # Check if data vaild
    andi et, r8, 0b1000000000000000
    beq et, r0, exit_interrupt_handler
    
    # If vaild, mask it and save it to reg
    andi r9, r8, 0b11111111             # Real Data now in r9
    
    # If Key release detect, clear the LED
    movi et, 0xF0
    bne r9, et, Key_press_down
Key_release:
	# read out the second part data for key release
key_release_loop:
    # read out data
    movia r8, PS2_DATA_1
    ldwio r8, 0(r8)                     # Data now in r8
    
    # Check if data vaild
    andi et, r8, 0b1000000000000000
    beq et, r0, key_release_loop
    
    # Clear LED
	movia et, ADDR_REDLEDS
    stwio r0, 0(et)
    br exit_interrupt_handler
    
Key_press_down:
    # Depend on the reading, display result on LED
    movia et, ADDR_REDLEDS
    stwio r9, 0(et)
    
    # Acknowledge interrupt is handled
    # Once data been read, PS2 automatically ack interrupt in handled
    
exit_interrupt_handler:
	# EPL
	ldw r9, 4(sp)
    ldw r8, 0(sp)
    addi sp, sp, 8

	subi ea, ea, 4
    eret