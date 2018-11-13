.global _start
.equ video_control_buffer_base, 0xFF203020
.equ video_in_controller_base, 0xFF20306C
_start:
  movia r8, video_in_controller_base
  movi  r9, 0b100		# When bit 2 of 0xFF20306C is set the video from the video in source is stored into the pixel buffer
  stwio r9, 0(r8)   # Write the value

  movia r8, video_control_buffer_base
  movi  r9, 0b1		  # When 1 is written to this register then every 1/60 the data from the back 
  						      # register is swapped into this register.
  stwio r9, 0(r8)   # Write the value
