.include    "address_map_nios2.s"
.include    "globals.s"
.extern     PATTERN                         # externally defined variables
.extern     SHIFT_DIR
/*******************************************************************************
 * Pushbutton - Interrupt Service Routine
 *
 * This routine checks which KEY has been pressed and updates the global
 * variables as required.
 ******************************************************************************/
.global     stop_back_motor, stop_front_motor, go_backward, go_forward, turn_right, turn_left
PUSHBUTTON_ISR:
        subi    sp, sp, 28                      # reserve space on the stack
        stw     ra, 0(sp)
        stw     r10, 4(sp)
        stw     r11, 8(sp)
        stw     r12, 12(sp)
        stw     r13, 16(sp)
		stw     r14, 20(sp)
        stw     r15, 24(sp)

        movia   r10, KEY_BASE                   # base address of pushbutton KEY
                                                # parallel port
        ldwio   r11, 0xC(r10)                   # read edge capture register
        stwio   r11, 0xC(r10)                   # clear the interrupt
        movia   r10, JP2_BASE

CHECK_KEY0:
        andi    r13, r11, 0b0001                # check KEY0
        beq     r13, zero, CHECK_KEY1

        movia   r12, 0xfffffffc       # motor0 enabled (bit0=0), direction set to forward (bit1=0)
		stwio   r12, 0(r10)

CHECK_KEY1:
        andi    r13, r11, 0b0010                # check KEY1
        beq     r13, zero, CHECK_KEY2

        movia   r12, 0xfffffffe
        stwio   r12, 0(r10)

CHECK_KEY2:
		andi    r13, r11, 0b0100
        beq     r13, zero, CHECK_KEY3

        movia   r12, 0xfffffffb
        stwio   r12, 0(r10)

CHECK_KEY3:
		andi    r13, r11, 0b1000
        beq     r13, zero, END_PUSHBUTTON_ISR

		#movia   r14, TOGGLE
        #ldb     r15, 0(r14)
		#bne     r15, zero, STEERING_OFF

		# Turn the motor on
        movia   r12, 0xfffffff3
        stwio   r12, 0(r10)
        # Update the state of the Toggle variable
        #movi    r15, 1
        #stb     r15, 0(r14)
        #br END_PUSHBUTTON_ISR

STEERING_OFF:
		# Turn all motors off
        #movia  r12, 0xffffffff
        #stwio  r12, 0(r10)
        #stb    zero, 0(r14)

END_PUSHBUTTON_ISR:
        ldw     ra, 0(sp)                       # Restore all used register to
                                                # previous
        ldw     r10, 4(sp)
        ldw     r11, 8(sp)
        ldw     r12, 12(sp)
        ldw     r13, 16(sp)
        ldw     r14, 20(sp)
        ldw     r15, 24(sp)
        addi    sp, sp, 28

stop_back_motor:
        subi sp, sp, 4
        stw  r8, 0(sp)

        # For reference: set the LEDs
        movia et, LED_BASE
        movi r8, 0xF
        stwio r8, 0(et)

        # Stop the back motor
        movia et, JP2_BASE
        ldwio r8, 0(et)
        ori   r8, r8, 0b11
        stwio r8, 0(et)

        ldw r8, 0(sp)
        addi sp, sp, 4
        ret

stop_front_motor:
        subi    sp, sp, 4
        stw     r8, 0(sp)

        # For reference: set the LEDs
        #movia   et, LED_BASE
        #movi    r8, 0xF0
        #stwio   r8, 0(et)

        # Stop the front motor
        movia et, JP2_BASE
        ldwio r8, 0(et)
        ori   r8, r8, 0b1100
        stwio r8, 0(et)

        ldw     r8, 0(sp)
        addi    sp, sp, 4
        ret

go_forward:
        subi    sp, sp, 12       # Save reg we are going to use
        stw     et, 0(sp)
        stw     r8, 4(sp)
        stw     r9, 8(sp)

        # LED for debug purpose
        movia   et, LED_BASE
        movi    r8, 1
        stwio   r8, 0(et)

        movia   et, JP2_BASE
        ldwio   r8, 0(et)
        movia   r9, 0xfffffffc
        and     r8, r8, r9
        stwio   r8, 0(et)

        ldw     et, 0(sp)
        ldw     r8, 4(sp)
        ldw     r9, 8(sp)
        addi    sp, sp, 12
        ret

go_backward:
        subi    sp, sp, 12       # Save reg we are going to use
        stw     et, 0(sp)
        stw     r8, 4(sp)
        stw     r9, 8(sp)

        # LED for debug purpose
        movia   et, LED_BASE
        movi    r16, 2
        stwio   r16, 0(et)

        movia   et, JP2_BASE
        ldwio   r8, 0(et)
        movia   r9, 0xfffffffe
        and     r8, r8, r9
        stwio   r8, 0(et)

        ldw     et, 0(sp)
        ldw     r8, 4(sp)
        ldw     r9, 8(sp)
        addi    sp, sp, 12
        ret

turn_right:
        subi    sp, sp, 12       # Save reg we are going to use
        stw     et, 0(sp)
        stw     r8, 4(sp)
        stw     r9, 8(sp)

        # LED for debug purpose

        movia   et, LED_BASE
        movi    r16, 4
        stwio   r16, 0(et)

        movia   et, JP2_BASE
        ldwio   r8, 0(et)
        movia   r9, 0xfffffffb
        and     r8, r8, r9
        stwio   r8, 0(et)

        ldw     et, 0(sp)
        ldw     r8, 4(sp)
        ldw     r9, 8(sp)
        addi    sp, sp, 12
        ret

turn_left:
        subi    sp, sp, 12       # Save reg we are going to use
        stw     et, 0(sp)
        stw     r8, 4(sp)
        stw     r9, 8(sp)

        # LED for debug purpose

        movia   et, LED_BASE
        movi    r16, 8
        stwio   r16, 0(et)

        movia   et, JP2_BASE
        ldwio   r8, 0(et)
        movia   r9, 0xfffffff3
        and     r8, r8, r9
        stwio   r8, 0(et)

        ldw     et, 0(sp)
        ldw     r8, 4(sp)
        ldw     r9, 8(sp)
        addi    sp, sp, 12
        ret

.end
