.include    "address_map_nios2.s"
.include    "globals.s"
.extern     IS_TURNING                         # externally defined variables

/*******************************************************************************
 * Pushbutton - Interrupt Service Routine
 *
 * This routine checks which KEY has been pressed and updates the global
 * variables as required.
 ******************************************************************************/
.global     stop_back_motor, stop_front_motor, go_backward, go_forward, turn_right, turn_left, clear_is_turning
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

clear_is_turning:
        movia   et, IS_TURNING
        stb     r0, 0(et)
        ret

stop_front_motor:
        subi    sp, sp, 4
        stw     r8, 0(sp)

        # For reference: set the LEDs
        movia   et, LED_BASE
        movi    r8, 0xF0
        stwio   r8, 0(et)

        # Stop the front motor
        movia et, JP2_BASE
        ldwio r8, 0(et)
        ori   r8, r8, 0b1100
        stwio r8, 0(et)

        ldw     r8, 0(sp)
        addi    sp, sp, 4
        ret

go_forward:
        subi    sp, sp, 8
        stw     r8, 0(sp)
        stw     r9, 4(sp)

        movia   et, LED_BASE
        movi    r8, 1
        stwio   r8, 0(et)

        # Set the 2 least significant bits to zero
        movia   et, JP2_BASE
        ldwio   r8, 0(et)
        movia   r9, 0xfffffffe
        and     r8, r8, r9
        stwio   r8, 0(et)

        ldw     r8, 0(sp)
        ldw     r9, 4(sp)
        addi    sp, sp, 8
        ret

go_backward:
        subi    sp, sp, 8
        stw     r8, 0(sp)
        stw     r9, 4(sp)

        movia   et, LED_BASE
        movi    r8, 2
        stwio   r8, 0(et)

        # Set the least significant bit to zero
        movia   et, JP2_BASE
        ldwio   r8, 0(et)
        movia   r9, 0xfffffffc
        and     r8, r8, r9
        stwio   r8, 0(et)

        ldw     r8, 0(sp)
        ldw     r9, 4(sp)
        addi    sp, sp, 8
        ret

turn_right:
        # If the car is already turning, do nothing
        movia   et, IS_TURNING
        ldb     et, 0(et)
        beq     r0, et, turn_right_prologue
        ret

turn_right_prologue:
        subi    sp, sp, 8
        stw     r8, 0(sp)
        stw     r9, 4(sp)

        movia   et, LED_BASE
        movi    r8, 4
        stwio   r8, 0(et)

        movia   et, JP2_BASE
        ldwio   r8, 0(et)
        movia   r9, 0xfffffff3
        and     r8, r8, r9
        stwio   r8, 0(et)

        # start timer
        movia   et, TIMER_BASE
        movi    r8, 0b101
        sthio   r8, 4(et)

        # set the global IS_TURNING variable
        movi    r9, 1
        movia   et, IS_TURNING
        stb     r9, 0(et)

        ldw     r8, 0(sp)
        ldw     r9, 4(sp)
        addi    sp, sp, 8
        ret

turn_left:
        # If the car is already turning, do nothing
        movia   et, IS_TURNING
        ldb     et, 0(et)
        beq     r0, et, turn_left_prologue
        ret

turn_left_prologue:
        subi    sp, sp, 8
        stw     r8, 0(sp)
        stw     r9, 4(sp)

        movia   et, LED_BASE
        movi    r8, 8
        stwio   r8, 0(et)

        movia   et, JP2_BASE
        ldwio   r8, 0(et)
        movia   r9, 0xfffffffb
        and     r8, r8, r9
        stwio   r8, 0(et)

        # start timer
        movia   et, TIMER_BASE
        movi    r8, 0b101
        sthio   r8, 4(et)

        # set the global IS_TURNING variable
        movi    r9, 1
        movia   et, IS_TURNING
        stb     r9, 0(et)

        ldw     r8, 0(sp)
        ldw     r9, 4(sp)
        addi    sp, sp, 8
        ret

.end
