.section	.data 				# global variables
	N: 							.long 10
	M: 							.long 5

.section	.rodata				# global constants
	init_msg: 					.asciz "Enter configuration seed:\n"
	ez_msg: 					.asciz "Would you like to play in easy mode? (y/n)"
	guess_msg: 					.asciz "What is your guess?"
	try_again_msg: 				.asciz "Incorrect. "
	game_over:					.asciz "Game over, you lost :(. The correct answer was "
	double_msg: 				.asciz "Double or nothing! Would you like to continue to another round?"
	win_msg:					.asciz "Congratz! You won "
	win2_msg: 					.asciz " rounds!"
	yes:	 					.asciz "y"
	no:							.asciz "n"


.section	.bss				# IO variables
	seed_val:					.space 4
	num_guess:					.space 4
	continue_answer:			.space 1
	ez_mode_answer:				.space 1
	correct_num:				.space 4

.section	.text
.globl		main
.type		main, @function
	main:
		#initialising
		pushq	%rbp
		movq	%rsp,	%rbp
		
		#Prints
		movq $init_msg, %rdi
    	xorq %rax, %rax
    	call printf


		# Return to OS with status 0
		mov $0, %rax
		popq	%rbp
		ret
