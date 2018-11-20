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
    movi  r8, 0b1
    stwio r8, 0(r17)

    # Enable IRQ 7 for PS2 controller 1
    # PS2 controller 1 use IRQ 7 to request interrupt.
    movi  r8, 0b10000000
    wrctl ienable, r8

    # Enable interrupt on CPU
    movi  r8, 0b1
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
    andi  et, et, 0b10000000             # Mask reading
    beq   et, r0, exit_interrupt_handler  # If not cause by PS2, exit

read_data:
    # handle interrupt
    # read out the whole data reg for the PS2 Controller
    movia r8, PS2_DATA_1
    ldwio r8, 0(r8)                     # Data now in r8


    # Check if data vaild
    andi et, r8, 0b1000000000000000
    beq  et, r0, read_data

    # If vaild, mask it and save it to r9
    andi r9, r8, 0b11111111             # Real Data now in r9

key_press_or_release:
    movi et, 0xF0                       # 0xF0 indicate key release
    bne r9, et, key_press

key_release:
    # read the second data which show which key has been released
    movia r8, PS2_DATA_1
    ldwio r8, 0(r8)                     # Data now in r8

    # Check if data vaild
    andi et, r8, 0b1000000000000000
    beq et, r0, key_release

    # If vaild, mask it and save it to r9
    andi r9, r8, 0b11111111             # Real Data now in r9

    # Here just clear LED, do nothing with data in r9 in this test case.
	movia et, ADDR_REDLEDS
    stwio r0, 0(et)

    # Exit
    br exit_interrupt_handler

key_press:
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
