// Avi Ben David, 324026038
.section	.data 				# global variables
	N: 							.long 11
	M: 							.long 5

.section	.rodata				# global constants
	init_msg: 					.asciz "Enter configuration seed:\n"
	ez_msg: 					.asciz "Would you like to play in easy mode? (y/n)"
	guess_msg: 					.asciz "What is your guess? "
	try_again_msg: 				.asciz "Incorrect. "
	game_over:					.asciz "Game over, you lost :(. The correct answer was "
	double_msg: 				.asciz "Double or nothing! Would you like to continue to another round?"
	win_msg:					.asciz "Congratz! You won "
	win_msg2: 					.asciz " rounds!"
	yes:	 					.asciz "y"
	no:							.asciz "n"
	num_prompt:					.asciz "%d"
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
		call random_num_gen			# Generates a random number between 0 - N
		call guess_num				# Prompts the user to take a guess
		call compare_num			# Compares the guess to the correct answer
		call line_down				# Goes down a line to keep things tidy
		

		movq $num_prompt, %rdi		# Load %d into rdi
		movq correct_num(%rip), %rsi		# Load the actual number we want to print
		xorq %rax, %rax				# Cleaning rax
		call printf					# function printf
		call line_down

		movq $num_prompt, %rdi		# Load %d into rdi
		movq num_guess(%rip), %rsi		# Load the actual number we want to print
		xorq %rax, %rax				# Cleaning rax
		call printf					# function printf
		call line_down

		# Return to OS with status 0
		mov $0, %rax
		popq	%rbp
		ret

	random_num_gen:
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

		lea num_prompt(%rip), %rdi	# We add the prefix to scan the input correctly
    	lea seed_val(%rip), %rsi	# We put the seed number in rsi to be accepted by the scan
    	xor %rax, %rax				# We clean rax
    	call scanf					# Calling scanf function

#		lea num_prompt(%rip), %rdi	# Loads the seeds string into rdi
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

	guess_num:
		pushq %rbp					# Entering a function, pushing stack
        movq %rsp, %rbp	

		lea guess_msg, %rdi			# Loads the message prompt into rdi
		xor	%rax, %rax				# Cleans rax
		call printf					# Prints the message prompt with function

		lea num_prompt(%rip), %rdi	# We add the prefix to scan the input correctly
    	lea num_guess(%rip), %rsi	# We put the seed number in rsi to be accepted by the scan
    	xor %rax, %rax				# We clean rax
    	call scanf					# Calling scanf function

		popq %rbp					# We pop the stack and return to main
        ret

	print_int:
		lea num_prompt(%rip), %rdi	# Loads the seeds string into rdi
		mov num_guess, %rsi
		xor %rax, %rax				# Cleans rax
		call printf					# Calling printf function

	compare_num:
		pushq %rbp					# Entering a function, pushing stack
        movq %rsp, %rbp	
		
 		movl num_guess(%rip), %eax      # Load the value of num_guess into %eax (32-bit)
    	movl correct_num(%rip), %ebx    # Load the value of correct_num into %ebx (32-bit)

		cmpl %ebx, %eax             # Compare the values in %eax and %ebx
		je win						# Jumps to win message if the two are equal

		lea try_again_msg, %rdi		# Loads the message prompt into rdi
		xor	%rax, %rax				# Cleans rax
		call printf					# Prints the message prompt with function

		popq %rbp					# We pop the stack and return to main
        ret

	win:
		pushq %rbp					# Entering a function, pushing stack
        movq %rsp, %rbp	

		lea win_msg, %rdi			# Loads the message prompt into rdi
		xor	%rax, %rax				# Cleans rax
		call printf					# Prints the message prompt with function

		popq %rbp					# We pop the stack and return to main
        ret
