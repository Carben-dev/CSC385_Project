.global _start
.equ ADDR_Front_buffer, 0xFF203020
.equ ADDR_Video_in_controller, 0xFF20306C
_start:
    # Setup Video Steam
    movia r8,ADDR_Video_in_controller
    movi  r9,0x4          # When bit 2 of 0xFF20306C is set the video from the video in source is stored into the pixel buffer
    stwio r9,0(r8)        # Write the value

    movia r8,ADDR_Front_buffer
    movi  r9,0x1          # When 1 is written to this register then every 1/60 the data from the back 
                          # register is swapped into this register.
    stwio r9,0(r8)        # Write the value
	
idle:
    br idle
