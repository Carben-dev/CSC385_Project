.include    "address_map_nios2.s"
.include    "globals.s"

/*******************************************************************************
 * This program demonstrates use of interrupts. It
 * first starts an interval timer with 50 msec timeouts, and then enables
 * Nios II interrupts from the interval timer and pushbutton KEYs
 *
 * The interrupt service routine for the interval timer displays a pattern
 * on the LEDs, and shifts this pattern either left or right:
 *      KEY[0]: loads a new pattern from the SW switches
 *      KEY[1]: toggles the shift direction the displayed pattern
 ******************************************************************************/

.text        # executable code follows
.global     _start
_start:
/* set up the stack */
        movia   sp, SDRAM_END - 3   # stack starts from largest memory
                                    # address
/*  enable video streaming */
        /*movia r8, 0xFF20306C
        movi  r9, 0b100

        stwio r9, 0(r8)

        movia r8, PIXEL_BUF_CTRL_BASE
        movi  r9, 0b1
        stwio r9, 0(r8)
        */

        /* set up the lego controller */
        movia   r15, JP2_BASE
        movia   r7, 0x07f557ff       # set direction for motors to all output
        stwio   r7, 4(r15)

        # Stop everything
        movia   r7, 0xffffffff
        stwio   r7, 0(r15)

        # Put PS2 Data and Control addr in reg
        movia  r16, PS2_BASE
        addi   r17, r16, 0x4

        # Setup PS2 control interrupt
        # Setup the first bit of PS2 CTL to 1 to enable PS2 Read interrupt,
        # PS2 Controller will trigger interrupt on data received.
        movi  r9, 0b1
        stwio r9, 0(r17)

        # Setup timer
        movia r8, TIMER_BASE
        movia r9, 0x989680

        # Load PERIODL of timer
        stwio r9, 8(r8)

/* enable Nios II processor interrupts */
        movi    r7, 0x81            # get interrupt mask bits for the PS2 keyboard and interval timer
        wrctl   ienable, r7         # enable interrupts for the given mask
                                    # bits
        movi    r7, 1
        wrctl   status, r7          # turn on Nios II interrupt processing


IDLE:
        br      IDLE                # main program simply idles

.data
/*******************************************************************************
 * The global variables used by the interrupt service routines for the interval
 * timer and the pushbutton keys are declared below
 ******************************************************************************/
.global     IS_TURNING
IS_TURNING:
.byte       0 # 1 iff the car is currently turning

.end
