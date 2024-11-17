// Avi Ben David, 324026038
.section	.data 				# global variables
	N: 							.long 11
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
	print_num:					.asciz "%d"
	go_down:					.asciz "\n"


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
		
		call enter_seed				# Gets seed from user input
		call random_num				# Generates a random number between 0 - N
		call line_down				# Goes down a line
		

		movq $print_num, %rdi		# Load %d into rdi
		movq correct_num, %rsi		# Load the actual number we want to print
		xorq %rax, %rax				# Cleaning rax
		call printf					# function printf

		movq $go_down, %rdi		
		xorq %rax, %rax
		call printf

		# Return to OS with status 0
		mov $0, %rax
		popq	%rbp
		ret

	random_num:
		pushq %rbp					# Entering a function, pushing stack
        movq %rsp, %rbp				
		movq seed_val, %rdi			# Moves the seed into the rdi register
		call srand					# Random number generator pt 1, inputting seed
		xorq %rax, %rax				# Cleaning rax
		call rand					# Random number generator pt 2
		movl N, %edi				# Moves N into edi
		divl %edi					# Divides EDX:EAX by edi, saves the reminder in EDX
		mov  %edx, correct_num		# We move the reminder and make it the random number
		popq %rbp					# We pop the stack and return to main
        ret

	enter_seed:
		pushq %rbp					# Entering a function, pushing stack
        movq %rsp, %rbp	

		lea init_msg, %rdi			# Loads the seeds string into rdi
		xor %rax, %rax				# Cleans rax
		call printf					# Calling printf function

		lea print_num(%rip), %rdi	# We add the prefix to scan the input correctly
    	lea seed_val(%rip), %rsi	# We put the seed number in rsi to be accepted by the scan
    	xor %rax, %rax				# We clean rax
    	call scanf					# Calling scanf function

#		lea print_num(%rip), %rdi	# Loads the seeds string into rdi
#		mov $seed_val, %rsi
#		xor %rax, %rax				# Cleans rax
#		call printf					# Calling printf function

		popq %rbp					# We pop the stack and return to main
        ret

	line_down:
	# Going down a line
		pushq %rbp					# Entering a function, pushing stack
        movq %rsp, %rbp	

		lea go_down, %rdi			# Loads \n into rdi
		xor %rax, %rax				# Cleans rax
		call printf					# Calling printf function

		popq %rbp					# We pop the stack and return to main
        ret
