.global _start

.data
GoLBoard:
	//  x 0 1 2 3 4 5 6 7 8 9 a b c d e f    y
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // 0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // 1
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 2
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 3
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 4
	.word 0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0 // 5
	.word 0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0 // 6
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 7
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 8
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 9
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // a
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // b
GoLNeighbours: // BAD DATA, use GoL_initialize_neighbours
	//  x 0 1 2 3 4 5 6 7 8 9 a b c d e f    y
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // 0
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // 1
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 2
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 3
	.word 0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0 // 4
	.word 0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0 // 5
	.word 0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0 // 6
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 7
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 8
	.word 0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 // 9
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // a
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // b
latest_key: .space 4
.text
@ TODO: copy VGA driver here.
// Draws point on screen at specified (x,y) coordinates
// pre-- R0: int	x [0,319]
// pre-- R1: int	y [0,239]
// pre-- R2: short	c [16-bit color]
.equ VGA_PIXEL, 0xc8000000
VGA_draw_point_ASM:
	// Input validation
	CMP		R0, #0			// x ? 0
	BLT		draw_point_end	// x < 0 invalid
	CMP		R0, #320		// x ? 320
	BGE		draw_point_end	// x >= 320 invalid
	CMP		R1, #0			// y ? 0
	BLT		draw_point_end	// y < 0 invalid
	CMP		R1, #240		// y ? 239
	BGE		draw_point_end	// y >= 239 invalid
	
	// Compute pixel address with coordinates
	LDR		R3, =VGA_PIXEL 	// load base VGA address
	ADD		R3, R0, LSL #1	// add x offset
	ADD 	R3, R1, LSL #10	// add y offset
	STRH	R2, [R3]		// store color at pixel address
	draw_point_end:
	BX		LR				// return to caller
	
// Clears all valid memory locations in pixel buffer
VGA_clear_pixelbuff_ASM:
	PUSH	{R4, R5}		// save used registers
	LDR		R0, =VGA_PIXEL		// R0: load base VGA address
	MOV		R1, #0				// R1: constant 0 for clear
	LDR		R3, =239			// R3: starting y index
	LDR		R5, =319			// R5: copy of max x

	loop_pixelbuff_y:
	ADD		R4, R0, R3, LSL #10	// R4: pointer to pixel
	setup_pixelbuff_loop_x:
	MOV		R2, R5				// R2: max x to set pointer to last column
	ADD		R4, R2, LSL #1		// move to end of row
	ADD		R2, #1				// R2: now used as x iteration counter
	loop_pixelbuff_x:
	STRH	R1, [R4], #-2		// store 0 at cur pixel (x,y)
	SUBS	R2, #1				// move cur to x-1, cleared leftmost yet?
	BGT		loop_pixelbuff_x	// not yet, clear next left pixel
	SUB		R3, #1				// move cur to y-1
	CMP		R3, #0				// y ? 0
	BGE		loop_pixelbuff_y	// y <= 0, pointer still in buffer, clear next above row
	end_pixelbuff_clear:
	POP		{R4, R5}		// restore used registers
	BX 		LR					// return to caller
	
// Writes the ASCII code to the screen at (x,y)
// pre-- R0: int x [0, 79]
// pre-- R1: int y [0, 59]
// pre-- R2: char c (ASCII code)
.equ VGA_CHAR, 0xc9000000
VGA_write_char_ASM:
	// Input validation
	CMP		R0, #0			// x ? 0
	BLT		draw_char_end	// x < 0 invalid
	CMP		R0, #80			// x ? 80
	BGE		draw_char_end	// x >= 80 invalid
	CMP		R1, #0			// y ? 0
	BLT		draw_char_end	// y < 0 invalid
	CMP		R1, #60			// y ? 60
	BGE		draw_char_end	// y >= 60 invalid
	
	// Compute pixel address with coordinates
	LDR		R3, =VGA_CHAR 	// load base VGA address
	ADD		R3, R0			// add x offset
	ADD 	R3, R1, LSL #7	// add y offset
	STRB	R2, [R3]		// store color at pixel address
	draw_char_end:
	BX		LR				// return to caller
	
// Clears all valid memory locations in character buffer
VGA_clear_charbuff_ASM:
	PUSH	{R4, R5}		// save used registers
	LDR		R0, =VGA_CHAR		// R0: load base VGA address
	MOV		R1, #0				// R1: constant 0 for clear
	MOV		R3, #59				// R3: starting y index
	MOV		R5, #79				// R5: copy of max x

	loop_charbuff_y:
	ADD		R4, R0, R3, LSL #7	// R4: pointer to char
	setup_charbuff_loop_x:
	MOV		R2, R5				// R2: max x to set pointer to last column
	ADD		R4, R2				// move to end of row
	ADD		R2, #1				// R2: now used as x iteration counter
	loop_charbuff_x:
	STRB	R1, [R4], #-1		// store 0 at cur char (x,y)
	SUBS	R2, #1				// move cur to x-1, cleared leftmost yet?
	BGT		loop_charbuff_x		// not yet, clear next left char
	SUB		R3, #1				// move cur to y-1
	CMP		R3, #0				// y ? 0
	BGE		loop_charbuff_y		// y <= 0, pointer still in buffer, clear next above row
	end_charbuff_clear:
	POP		{R4, R5}			// restore used registers
	BX 		LR					// return to caller
	
// Draws vertical or horizontal lines from (x1, y1) to (x2, y2) in color c
// pre-- R0: (x1, y1) where x1 = [8..0] and y1 = [16..9]
// pre-- R1: (x2, y2) where x2 = [8..0] and y2 = [16..9]
// pre-- R2: color c (RGB565)
VGA_draw_line_ASM:
	PUSH 	{R0-R5}		// save used registers
	// Parse inputs
	LDR		R5, =0x1FF	// R5: mask for first 9 bits
	LSR		R3, R0, #9	// R3: y1
	LSR		R4, R1, #9	// R4: y2
	AND		R0, R5		// R0: x1 (mask first 9 bits)
	AND		R1, R5		// R1: x2 (mask first 9 bits)
	// Validate x1
	CMP		R0, #0			// x ? 0
	BLT		draw_line_end	// x < 0 invalid
	CMP		R0, #320		// x ? 320
	BGE		draw_line_end	// x >= 320 invalid
	// Validate x2
	CMP		R1, #0			// x ? 0
	BLT		draw_line_end	// x < 0 invalid
	CMP		R1, #320		// x ? 320
	BGE		draw_line_end	// x >= 320 invalid
	// Validate y1
	CMP		R3, #0			// y ? 0
	BLT		draw_line_end	// y < 0 invalid
	CMP		R3, #240		// y ? 239
	BGE		draw_line_end	// y >= 239 invalid
	// Validate y2
	CMP		R4, #0			// y ? 0
	BLT		draw_line_end	// y < 0 invalid
	CMP		R4, #240		// y ? 239
	BGE		draw_line_end	// y >= 239 invalid
	// Check horizontal or vertical
	CMP		R0, R1			// x1 ? x2
	BEQ		draw_vertical_line		// same x so vertical
	CMP		R3, R4			// y1 ? y2
	BEQ		draw_horizontal_line	// same y so horizontal
	B		draw_line_end	// invalid input, go to end
	
draw_horizontal_line:
	CMP		R0, R1			// x1 ? x2
	EORGT	R0, R1			// x1 > x2, reorder so that x1 <= x2
	EORGT	R1, R0, R1
	EORGT	R0, R1
	// y1 = y2, x1 <= x2
	LDR		R4, =VGA_PIXEL	// load VGA pixel buffer base address
	// Calculate start point address
	ADD		R0, R4, R0, LSL #1 	// add x1 offset
	ADD		R0, R3, LSL #10		// add y offset
	// Calculate end point address
	ADD		R1, R4, R1, LSL #1	// add x2 offset
	ADD		R1, R3, LSL #10		// add y offset
loop_horizontal_line:
	STRH	R2, [R0], #2			// draw and x++
	CMP		R0, R1					// start ? end
	BLE		loop_horizontal_line	// start <= end, keep drawing
	B		draw_line_end			// done drawing, go to end
	
draw_vertical_line:
	CMP		R3, R4			// y1 ? y2
	EORGT	R3, R4			// y1 > y2, reorder so that y1 <= y2
	EORGT	R4, R3, R4
	EORGT	R3, R4
	// x1 = x2, y1 <= y2
	LDR		R1, =VGA_PIXEL	// load VGA pixel buffer base address
	// Calculate start point address
	ADD		R3, R1, R3, LSL #10 // add y1 offset
	ADD		R3, R0, LSL #1		// add x offset
	// Calculate end point address
	ADD		R4, R1, R4, LSL #10 // add y2 offset
	ADD		R4, R0, LSL #1		// add x offset
	MOV		R0, #1
loop_vertical_line:
	STRH	R2, [R3]			// draw
	ADD		R3, R0, LSL #10		// y++ (y + 1<<10)
	CMP		R3, R4				// start ? end
	BLE		loop_vertical_line	// start <= end, keep drawing
draw_line_end:
	POP 	{R0-R5}	// restore usedd registers
	BX 		LR		// return to caller

// Draws a rectangle from pixel (x1, y1) to (x2, y2) in color c
// pre-- R0: (x1, y1)
// pre-- R1: (x2, y2)
// pre-- R2: color c
VGA_draw_rect_ASM:
	PUSH 	{R0-R5, LR}		// save used registers
	// Parse inputs
	LDR		R5, =0x1FF	// R5: mask for first 9 bits
	LSR		R3, R0, #9	// R3: y1
	LSR		R4, R1, #9	// R4: y2
	AND		R0, R5		// R0: x1 (mask first 9 bits)
	AND		R1, R5		// R1: x2 (mask first 9 bits)
	// Validate x1
	CMP		R0, #0			// x ? 0
	BLT		draw_rect_end	// x < 0 invalid
	CMP		R0, #320		// x ? 320
	BGE		draw_rect_end	// x >= 320 invalid
	// Validate x2
	CMP		R1, #0			// x ? 0
	BLT		draw_rect_end	// x < 0 invalid
	CMP		R1, #320		// x ? 320
	BGE		draw_rect_end	// x >= 320 invalid
	// Validate y1
	CMP		R3, #0			// y ? 0
	BLT		draw_rect_end	// y < 0 invalid
	CMP		R3, #240		// y ? 239
	BGE		draw_rect_end	// y >= 239 invalid
	// Validate y2
	CMP		R4, #0			// y ? 0
	BLT		draw_rect_end	// y < 0 invalid
	CMP		R4, #240		// y ? 239
	BGE		draw_rect_end	// y >= 239 invalid
	// Get top-left, bottom-right
	CMP		R0, R1			// x1 ? x2
	EORGT	R0, R1			// x1 > x2, reorder so that x1 <= x2
	EORGT	R1, R0, R1
	EORGT	R0, R1
	CMP		R3, R4			// y1 ? y2
	EORGT	R3, R4			// y1 > y2, reorder so that y1 <= y2
	EORGT	R4, R3, R4
	EORGT	R3, R4
	// now (x1, y1) is top-left and (x2, y2) is bot-right
	SUB		R5, R4, R3		// number of horizontal lines to draw = y2 - y1
setup_draw_rect:
	ADD		R0, R3, LSL #9		// R0: start of line
	ADD		R1, R3, LSL #9		// R1: end of line
	MOV		R3, #1				// R3: constant 1
loop_draw_rect:
	BL		VGA_draw_line_ASM	// Draw line
	ADD		R0, R3, LSL #9		// move line start down
	ADD		R1, R3, LSL #9		// move line end down
	SUBS	R5, #1				// decrement counter
	BGE		loop_draw_rect		// not done drawing box
draw_rect_end:
	POP 	{R0-R5, LR}
	BX		LR
	
@ TODO: insert PS/2 driver here.
// Checks the RVALID bit, if valid, read data and store at address `data`, then return 1, else return 0
// pre-- R0: where to store valid keystroke data
// post- R0: 1 if success, 0 if error
.equ PS2_DATA, 0xff200100
read_PS2_data_ASM:
	PUSH	{R1-R3}
	LDR		R1, =PS2_DATA		// load ps2 data reg address
	LDR		R1, [R1]			// R1: data from ps2 data reg
	// Check RVALID
	MOV		R2, #1				// constant 1
	ANDS	R3, R2, R1, LSR #15	// R3: RVALID = ((*(volatile int *)0xff200100) >> 15) & 0x1 
	STRNEB	R1, [R0]			// RVALID = 1, so EQ to 1, store at pointer/address
	MOV		R0, R3				// return RVALID
	POP		{R1-R3}
	BX 		LR					// return to caller

smart_read_PS2_data_ASM:
	PUSH	{R1-R3}
	LDR		R2, =PS2_DATA		// load ps2 data reg address
stall:
	
	LDR		R1, [R2]			// R1: data from ps2 data reg
	LDR		R1, [R2]			// R1: data from ps2 data reg
	LDR		R1, [R2]			// R1: data from ps2 data reg
	// Check RVALID
	MOV		R2, #1				// constant 1
	ANDS	R3, R2, R1, LSR #15	// R3: RVALID = ((*(volatile int *)0xff200100) >> 15) & 0x1 
	STRNEB	R1, [R0]			// RVALID = 1, so EQ to 1, store at pointer/address
	MOV		R0, R3				// return RVALID
	POP		{R1-R3}
	BX 		LR					// return to caller

@ Game of Life Drivers
// Draws a 16x12 grid on VGA display in color c
// pre-- R0: color c
GoL_draw_grid_ASM:
	PUSH	{R4, LR}
	MOV		R2, R0	// save color somewhere else
grid_horizontal:
	MOV		R0, #19		// (0, 19) start
	LSL		R0, #9		// shift y to appropriate space
	LDR		R1, =319	// (319, 0)
	ADD		R1, R0		// (319, 19) end
	MOV		R3, #20		// y increment
	MOV		R4, #12		// how many horizontal lines to draw
loop_grid_hor:
	BL		VGA_draw_line_ASM	// draw horizontal line
	SUBS	R4, #1			// decrement counter
	ADDGE	R0, R3, LSL #9	// increment y1 by 19
	ADDGE	R1, R3, LSL #9	// increment y2 by 19
	BGE		loop_grid_hor	// keep moving line down
grid_vertical:
	MOV		R0, #19			// (19,0) start
	LDR		R1, =0x1DE00	// (0, 239)
	ADD		R1, R0			// (19, 239 end
	MOV 	R3, #20		// x increment
	MOV 	R4, #16		// how many vertical lines to draw
loop_grid_ver:
	BL		VGA_draw_line_ASM	// draw horizontal line
	SUBS	R4, #1			// decrement counter
	ADDGE	R0, R3			// increment x1 by 21
	ADDGE	R1, R3			// increment x2 by 21
	BGE		loop_grid_ver	// keep moving line down
end_grid:
	POP		{R4, LR}		// restore used registers
	BX		LR
	
	
// Fills area of grid location (x, y) with color c
// pre-- R0: x [0, 16[
// pre-- R1: y [0, 12[
// pre-- R2: color c (RGB565)
GoL_fill_gridxy_ASM:
	PUSH	{R0-R3, LR}			// save used registers
	// Validate x
	CMP		R0, #0			// x ? 0
	BLT		end_fill_gridxy	// x < 0 invalid
	CMP		R0, #16			// x ? 16
	BGE		end_fill_gridxy	// x >= 16 invalid
	// Validate y
	CMP		R1, #0			// y ? 0
	BLT		end_fill_gridxy	// y < 0 invalid
	CMP		R1, #12			// y ? 12
	BGE		end_fill_gridxy	// y >= 12 invalid
	// Default box (0,0)
	LDR		R3, =0x2800		// constant 1<<9
	MUL		R1, R3			// y index times y gap
	MOV		R3, #20			// constant 20 for x gap
	MLA		R0, R0, R3, R1 	// add x times x gap
	LDR		R3, =0x2412		// bot-right corner offset
	ADD		R1, R0, R3		// top-left + offset = bot-right
	BL		VGA_draw_rect_ASM
end_fill_gridxy:
	POP		{R0-R3, LR}			// restore used registers
	BX		LR


// Flips grid location (x, y)
// pre-- R0: x
// pre-- R1: y
GoL_flip_gridxy_ASM:
	PUSH	{R2-R4, LR}
	// check if (x, y) is active
	LDR		R2, =GoLBoard	// load GoL board address
	ADD		R2, R0, LSL #2	// move to col x
	ADD		R2, R1, LSL	#6	// move to row y
	LDR		R3, [R2]		// state at (x,y)
	EORS	R3, #1			// state XOR 1? if 0 then Z=1, EQ, else Z=0, NE
	STR		R3, [R2]		// also flip state in R2
	LDR		R3, =0x300		// offset to neighbour board
	ADD		R4, R2, R3		// get to corresponding neighbour board cell
	MOVEQ	R2,	#0			// new state = 0, use black to turn off
	LDRNE	R2, =0x07ff		// new state = 1, use cyan to turn on
	BNE		increment_left
decrement_left:
	CMP		R0, #0			// x ? 0
	BLE		decrement_top	// x <= 0
	LDR		R3, [R4, #-4]	// read left
	SUB		R3, #1			// flip it
	STR		R3, [R4, #-4]	// store left
decrement_topleft:
	CMP		R1, #0			// y ? 0
	BLE		decrement_right	// y <= 0
	LDR		R3, [R4, #-68]	// read left
	SUB		R3, #1			// flip it
	STR		R3, [R4, #-68]	// store left
decrement_top:
	CMP		R1, #0			// y ? 0
	BLE		decrement_right	// y <= 0
	LDR		R3, [R4, #-64]	// read left
	SUB		R3, #1			// flip it
	STR		R3, [R4, #-64]	// store left
decrement_topright:
	CMP		R0, #15			// x ? 15
	BGE		decrement_bot	// x >= 15
	LDR		R3, [R4, #-60]	// read left
	SUB		R3, #1			// flip it
	STR		R3, [R4, #-60]	// store left
decrement_right:
	CMP		R0, #15			// x ? 15
	BGE		decrement_bot	// x >= 15	
	LDR		R3, [R4, #4]	// read left
	SUB		R3, #1			// flip it
	STR		R3, [R4, #4]	// store left
decrement_botright:
	CMP		R1, #11			// y ? 11
	BGE		end_flip		// y >= 11
	LDR		R3, [R4, #68]	// read left
	SUB		R3, #1			// flip it
	STR		R3, [R4, #68]	// store left
decrement_bot:
	CMP		R1, #11			// y ? 11
	BGE		end_flip		// y >= 11
	LDR		R3, [R4, #64]	// read left
	SUB		R3, #1			// flip it
	STR		R3, [R4, #64]	// store left
decrement_botleft:
	CMP		R0, #0			// x ? 0
	BLE		end_flip		// x <= 0
	LDR		R3, [R4, #60]	// read left
	SUB		R3, #1			// flip it
	STR		R3, [R4, #60]	// store left
	B		end_flip		// done
increment_left:
	CMP		R0, #0			// x ? 0
	BLE		increment_top	// x <= 0
	LDR		R3, [R4, #-4]	// read left
	ADD		R3, #1			// flip it
	STR		R3, [R4, #-4]	// store left
increment_topleft:
	CMP		R1, #0			// y ? 0
	BLE		increment_right	// y <= 0
	LDR		R3, [R4, #-68]	// read left
	ADD		R3, #1			// flip it
	STR		R3, [R4, #-68]	// store left
increment_top:
	CMP		R1, #0			// y ? 0
	BLE		increment_right	// y <= 0
	LDR		R3, [R4, #-64]	// read left
	ADD		R3, #1			// flip it
	STR		R3, [R4, #-64]	// store left
increment_topright:
	CMP		R0, #15			// x ? 15
	BGE		increment_bot	// x >= 15
	LDR		R3, [R4, #-60]	// read left
	ADD		R3, #1			// flip it
	STR		R3, [R4, #-60]	// store left
increment_right:
	CMP		R0, #15			// x ? 15
	BGE		increment_bot	// x >= 15	
	LDR		R3, [R4, #4]	// read left
	ADD		R3, #1			// flip it
	STR		R3, [R4, #4]	// store left
increment_botright:
	CMP		R1, #11			// y ? 11
	BGE		end_flip		// y >= 11
	LDR		R3, [R4, #68]	// read left
	ADD		R3, #1			// flip it
	STR		R3, [R4, #68]	// store left
increment_bot:
	CMP		R1, #11			// y ? 11
	BGE		end_flip		// y >= 11
	LDR		R3, [R4, #64]	// read left
	ADD		R3, #1			// flip it
	STR		R3, [R4, #64]	// store left
increment_botleft:
	CMP		R0, #0			// x ? 0
	BLE		end_flip		// x <= 0
	LDR		R3, [R4, #60]	// read left
	ADD		R3, #1			// flip it
	STR		R3, [R4, #60]	// store left
end_flip:
	BL		GoL_fill_gridxy_ASM		// flip cell
	POP		{R2-R4, LR}
	BX		LR


// Fills grid locations
// pre-- R0: color c
GoL_draw_board_ASM:
	PUSH	{R0-R4, LR}
	MOV		R2, R0			// R2: save color in R2
	LDR		R3, =GoLBoard	// R3: load address of GoL board
	MOV		R0, #0			// R0: x
	MOV		R1, #0			// R1: y
	
loop_draw_board:
	LDR		R4, [R3], #4		// read grid state, move to next word
	TST		R4, #1				// state?
	BLNE	GoL_fill_gridxy_ASM	// state = 1, fill
	ADD		R0, #1			// x++
	CMP		R0, #16			// x ? 16
	BLT		loop_draw_board	// not at end of row yet
	MOV		R0, #0			// wrap x around
	ADD		R1, #1			// y++
	CMP		R1, #12			// y ? 12
	BLT		loop_draw_board	// not past last row yet
end_draw_board:
	POP		{R0-R4, LR}
	BX		LR


// Draws cursor at (x, y)
// pre-- R0: x [0, 16[
// pre-- R1: y [0, 12[
// pre-- R2: color c
GoL_draw_cursor_ASM:
	PUSH	{R0-R3, LR}		// save used registers
	// top-left of grid slot
	LDR		R3, =0x2800		// constant 1<<9
	MUL		R1, R3			// y index times y gap
	MOV		R3, #20			// constant 20 for x gap
	MLA		R0, R0, R3, R1 	// add x times x gap
	// R0 now has top-left of (x,y)
	// let's find corners of cursor
	LDR		R3, =0xE07		// offset to cursor top-left
	ADD		R0, R3			// cursor top-left
	LDR		R3,	=0x804		// offset to cursor bot-right
	ADD		R1, R0, R3		// cursor bot-right
	BL		VGA_draw_rect_ASM	// draw cursor
	POP		{R0-R3, LR}		// restore used registers
	BX		LR				// return to caller


// Clears cursor at (x, y)
// pre-- R0: x [0, 16[
// pre-- R1: y [0, 12[
GoL_clear_cursor_ASM:
	PUSH	{R2, LR}
	// check if (x, y) is active
	LDR		R2, =GoLBoard	// load GoL board address
	ADD		R2, R0, LSL #2	// move to col x
	ADD		R2, R1, LSL	#6	// move to row y
	LDR		R2, [R2]		// state at (x,y)
	TST		R2, #1			// state & 1?
	LDRNE	R2,	=0x07ff		// state = 1, use cyan
	MOVEQ	R2, #0			// state = 0, use black
	BL		GoL_draw_cursor_ASM	// clear using clear color
	POP		{R2, LR}
	BX		LR
	
	
// Updates the mirror GoLNeighbours board
GoL_update_neighbours_ASM:
	PUSH	{R0-R6}
	LDR		R0, =GoLNeighbours	// R0: load base address of neighbour board
	LDR		R1, =GoLBoard		// R1: GoL board address
	MOV		R2, #192			// R2: counter for how many cells
	MOV		R3, #0				// R3: cur x pointer
	MOV		R4, #0				// R4: cur y pointer
	MOV		R5, #0				// R5: neighbour counter
check_left:
	CMP 	R3, #0			// x ? 0
	BLE		check_top		// x <= 0, no left
	LDR		R6, [R1, #-4]	// check left, check state
	CMP		R6, #1			// state ? 1
	ADDEQ	R5, #1			// state = 1, increment neighbour counter
check_topleft:
	CMP		R4, #0			// y ? 0
	BLE		check_right		// y <= 0, no top
	LDR		R6,	[R1, #-68]	// check topleft, check state
	CMP		R6, #1			// state ? 1
	ADDEQ	R5, #1			// state = 1, increment neighbour counter
check_top:
	CMP		R4, #0			// y ? 0
	BLE		check_right		// y <= 0, no top
	LDR		R6, [R1, #-64]	// check top, check state
	CMP		R6, #1			// state ? 1
	ADDEQ	R5, #1			// state = 1, increment neighbour counter
check_topright:
	CMP		R3, #15			// x ? 15
	BGE		check_bot		// x >= 15, no right
	LDR		R6, [R1, #-60]	// check topright, check state
	CMP		R6, #1			// state ? 1
	ADDEQ	R5, #1			// state = 1, increment neighbour counter
check_right:
	CMP		R3, #15			// x ? 15
	BGE		check_bot		// x >= 15, no right
	LDR		R6, [R1, #4]	// check right, check state
	CMP		R6, #1			// state ? 1
	ADDEQ	R5, #1			// state = 1, increment neighbour counter
check_botright:
	CMP		R4, #11			// y ? 11
	BGE		update_neighbour// y >= 11, no bot
	LDR		R6, [R1, #68]	// check topright, check state
	CMP		R6, #1			// state ? 1
	ADDEQ	R5, #1			// state = 1, increment neighbour counter
check_bot:
	CMP		R4, #11			// y ? 11
	BGE		update_neighbour// y >= 11, no bot
	LDR		R6, [R1, #64]	// check topright, check state
	CMP		R6, #1			// state ? 1
	ADDEQ	R5, #1			// state = 1, increment neighbour counter
check_botleft:
	CMP		R3, #0			// x ? 0
	BLE		update_neighbour// x <= 0, no left
	LDR		R6, [R1, #60]	// check topright, check state
	CMP		R6, #1			// state ? 1
	ADDEQ	R5, #1			// state = 1, increment neighbour counter
update_neighbour:
	STR		R5, [R0], #4	// store neighbour count, move next neighbour cell
	MOV		R5, #0			// clear neighbour counter
	ADD		R3, #1			// x++
	CMP		R3, #16			// x at end?
	MOVGE	R3, #0			// wrap x around
	ADDGE	R4, #1			// y++
	ADD		R1, #4			// move to next cell to check
	SUBS	R2, #1			// counter--, counter ? 1
	BGE		check_left		// keep counting neighbours
end_neighbours:
	POP		{R0-R6}
	BX		LR


// Update game state using neighbours, and then update new neighbours
GoL_update_game_state_ASM:
	PUSH	{R0-R4}
	LDR		R0, =GoLBoard		// load base address of GoL board
	MOV		R4, #192			// how many cells to update
update_loop:
	LDR		R1, [R0]			// check the current state
	LDR		R2, [R0, #0x300]	// check the number of neighbours of current cell
	CMP		R1, #0				// state ? 0
	BEQ		inactive			// state = 0, so inactive
active:
	CMP		R2, #2			// 2 neighbours?
	CMPNE	R2, #3			// no, maybe 3 neighbours?
	MOVNE	R1, #0			// still no? become inactive
	STRNE	R1, [R0]		// store 0 to cell
	B		end_update
inactive:
	CMP		R2, #3			// #neighbour ? 3
	MOVEQ	R1, #1			// 1 to turn active
	STREQ	R1, [R0]		// store 1 to cell
end_update:
	ADD		R0, #4		// move to next cell
	SUBS	R4, #1		// one less cell to update
	BGE		update_loop	// update next cell
	POP		{R0-R4}
	BX		LR
	

_start:
	LDR		R6, =0xfce0				// R6: permanent orange
	LDR		R7,	=0x07ff				// R7: permanent cyan
	BL 		VGA_clear_pixelbuff_ASM	// clear screen
	LDR		R0, =0xffff				// white
	BL		GoL_draw_grid_ASM		// draw grid
	MOV		R0, R7					// cyan
	BL		GoL_draw_board_ASM		// draw initial board
	BL		GoL_update_neighbours_ASM
	// start cursor at (0,0)
	MOV		R0, #0					// R0: cursor start x
	MOV		R1, #0					// R1: cursor start y
	MOV		R2, R6					// R2: orange :)
	BL		GoL_draw_cursor_ASM		// draw cursor
	LDR		R4, =latest_key			// R4: load address of latest_key
check_keystroke:
	MOV		R3, R0				// R3: temp cursor x
	MOV		R0, R4				// pass latest_key address to subroutine
	BL		read_PS2_data_ASM	// attempt to read keystroke
	TST		R0, #1				// valid read?
	MOV		R0, R3				// R0: cursor x is back
	BEQ		check_keystroke		// not valid, R0 & 1 = 0
clear_till_break:
	MOV		R3, R0				// R3: temp cursor x
	MOV		R0, R4				// pass latest_key address to subroutine
	BL		read_PS2_data_ASM	// attempt to read keystroke
	LDR		R5, [R4]			// read code
	CMP		R5, #0xF0				// past break?
	MOV		R0, R3				// R0: cursor x is back
	BNE		clear_till_break	
loop_3:
	MOV		R3, R0				// R3: temp cursor x
	MOV		R0, R4				// pass latest_key address to subroutine
	BL		read_PS2_data_ASM	// attempt to read keystroke
	TST		R0, #1				// valid read?
	MOV		R0, R3				// R0: cursor x is back
	BEQ		loop_3				// not valid, R0 & 1 = 0
	LDR		R3, [R4]			// read latest code of latest keystroke
check_W:
	CMP		R3, #0x1D	// W?
	BNE		check_A		// next check	
	CMP		R1, #0		// y ? 0
	BLE		check_keystroke			// y <= 0 can't move up, skip operations
	BL		GoL_clear_cursor_ASM	// clear cursor before moving
	SUB		R1, #1					// decrement y since not 0 yet
	BL		GoL_draw_cursor_ASM		// draw new cursor
	B		check_keystroke			// return to polling
check_A:
	CMP		R3, #0x1C	// A?
	BNE		check_S		// next check
	CMP		R0, #0		// x ? 0
	BLE		check_keystroke			// x <= 0 can't move left, skip operations
	BL		GoL_clear_cursor_ASM	// clear cursor before moving
	SUB		R0, #1					// decrement x since not 0 yet
	BL		GoL_draw_cursor_ASM		// draw new cursor
	B		check_keystroke			// return to polling
check_S:
	CMP		R3, #0x1B	// S?
	BNE		check_D		// next check	
	CMP		R1, #11		// y ? 15
	BGE		check_keystroke			// y >= 15 can't move down, skip operations
	BL		GoL_clear_cursor_ASM	// clear cursor before moving
	ADD		R1, #1					// increment y since not 0 yet
	BL		GoL_draw_cursor_ASM		// draw new cursor
	B		check_keystroke			// return to polling
check_D:
	CMP		R3, #0x23	// D?
	BNE		check_SPACE	// next check
	CMP		R0, #15		// x ? 0
	BGE		check_keystroke			// x >= 11 can't move right, skip operations
	BL		GoL_clear_cursor_ASM	// clear cursor before moving
	ADD		R0, #1					// increment x since not 0 yet
	BL		GoL_draw_cursor_ASM		// draw new cursor
	B		check_keystroke			// return to polling
check_SPACE:
	CMP		R3, #0x29			// SPACE?
	BNE		check_N				// next check
	BL		GoL_flip_gridxy_ASM	// flip current cell state
	BL		GoL_draw_cursor_ASM // restore cursor on top
	B		check_keystroke		// return to polling
check_N:
	CMP		R3, #0x31			// N?
	BNE		check_keystroke		// go back to beginning
	MOV		R3, R0				// save cursor x somewhere
	MOV		R0, #0				// black for clearing
	BL		GoL_draw_board_ASM	// clear current generation
	BL		GoL_update_game_state_ASM	// update to next generation
	MOV		R0, R7				// cyan
	BL		GoL_draw_board_ASM	// draw new generation
	BL		GoL_update_neighbours_ASM
	MOV		R0, R3				// restore cursor x
	BL		GoL_draw_cursor_ASM	// restore cursor
	B		check_keystroke		// return to polling
end:
	b       end