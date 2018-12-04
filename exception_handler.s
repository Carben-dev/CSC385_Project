.include "address_map_nios2.s"
/*******************************************************************************
 * RESET SECTION
 * Note: "ax" is REQUIRED to designate the section as allocatable and executable.
 * Also, the Debug Client automatically places the ".reset" section at the reset
 * location specified in the CPU settings in SOPC Builder.
 ******************************************************************************/
.section    .reset, "ax"            

        movia   r2, _start              
        jmp     r2                      # branch to main program


.section    .exceptions, "ax"
.global     EXCEPTION_HANDLER

EXCEPTION_HANDLER:                      
        subi    sp, sp, 20              # make room on the stack
        stw     et, 0(sp)               

        rdctl   et, ctl4                
        beq     et, r0, SKIP_EA_DEC     # interrupt is not external

        subi    ea, ea, 4               # must decrement ea by one instruction
                                        # for external interrupts, so that the
                                        # interrupted instruction will be run
SKIP_EA_DEC:                            
        stw     ea, 4(sp)               # save all used registers on the Stack
        stw     ra, 8(sp)               # needed if call inst is used
        stw     r8, 12(sp)             
        stw     r9, 16(sp)
        
        # Check if interrupt caused by timer
        rdctl   et, ctl4
        movi    r8, 0b1
        andi    r9, et, 0b1
        beq     r8, r9, TIMER_HANDLER
        
        # Check if interrupt caused by keyboard
        movi    r8, 0b10000000
       	andi    r9, et, 0b10000000                
        beq     r8, r9, CHECK_KEYBOARD   # interrupt is an external interrupt

NOT_EI:                                 # exception must be unimplemented
                                        # instruction or TRAP instruction. This
                                        # code does not handle those cases
        br      END_ISR
        
TIMER_HANDLER:
		# Once here, timeout, stop the front motor
        call    stop_front_motor
        
        # Clear timeout bit
        movia   et, TIMER_BASE
        sthio   r0, 0(et)
                 
		br      END_ISR
        
CHECK_KEYBOARD:
        andi    r8, et, 0x80
        beq     r8, r0, END_ISR
        
        
        # Check that the keyboard data is valid
        movia   r8, PS2_BASE
        ldwio   r8, 0(r8)
        
        andi    et, r8, 0x8000
        beq     et, r0, END_ISR
        
        andi    r9, r8, 0xFF          # Keyboard input now in r23

        # Is the key pressed or released?
        movi    et, 0xF0
        bne     r9, et, KEY_PRESS_DOWN

KEY_RELEASE:
        # Read out data
        movia   r8, PS2_BASE
        ldwio   r8, 0(r8)
 
        andi    et, r8, 0x8000
        beq     et, r0, KEY_RELEASE

        # Data is valid; mask out everything other than the data
        andi    r8, r8, 0xFF
        
check_w_up:
        # Check if the key released was the W key (code: 1D)
        movi    r9, 0x1D
        bne     r8, r9, check_s_up
        call    stop_back_motor
        br      END_ISR
        
check_s_up: # S (code: 1B)
        movi    r9, 0x1B
        bne     r8, r9, check_a_up
        call    stop_back_motor
        br      END_ISR
        
check_a_up: # A (code: 1C)
        movi    r9, 0x1C
        bne     r8, r9, check_d_up
        call    stop_front_motor
        call    clear_is_turning
        br      END_ISR
        
check_d_up: # D (code: 23)
        movi    r9, 0x23
        bne     r8, r9, END_ISR
        call    stop_front_motor
        call    clear_is_turning
        br      END_ISR

KEY_PRESS_DOWN: # The data from the keyboard is in r9
check_w_down:
        # Check if the key pressed was the W key (code: 1D)
        movi    r8, 0x1D
        bne     r9, r8, check_s_down
        call    go_forward
        br      END_ISR

check_s_down: # S (code: 1B)
        movi    r8, 0x1B
        bne     r9, r8, check_a_down
        call    go_backward
        br      END_ISR

check_a_down: # A (code: 1C)
        movi    r8, 0x1C
        bne     r9, r8, check_d_down
        call    turn_left
        br      END_ISR

check_d_down: # D (code: 23)
        movi    r8, 0x23
        bne     r9, r8, END_ISR
        call    turn_right
        br      END_ISR

END_ISR:                                
        ldw     et, 0(sp)               # restore all used register to previous
                                        # values
        ldw     ea, 4(sp)               
        ldw     ra, 8(sp)               # needed if call inst is used
        ldw     r8, 12(sp)             
        ldw     r9, 16(sp)
        addi    sp, sp, 20

.end                                
