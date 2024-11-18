// Avi Ben David, 324026038
.section	.data 				# global variables
	N: 							.long 11
	M: 							.long 5
	win_flag:					.long 0
	double_flag:				.long 0
	win_count:					.long 0

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
		
		mov M, %rcx
		call enter_seed				# Gets seed from user input
		call random_num_gen			# Generates a random number between 0 - N
		call guessing_game
		
		# Return to OS with status 0
		mov $0, %rax
		popq	%rbp
		ret

	# Generates a random number from 0-N based on a preexisting seed using rand function
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

	# Accepts a seed from the user and saves it pernamently
	# Also includes the very first message they see
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

	# Goes down a line in the console, that's it P:
	line_down:
		pushq %rbp					# Entering a function, pushing stack
        movq %rsp, %rbp	

		lea go_down, %rdi			# Loads \n into rdi
		xor %rax, %rax				# Cleans rax
		call printf					# Calling printf function

		popq %rbp					# We pop the stack and return to main
        ret

	# Accepts user input for the number they wish to guess, does nothing with it except saving it
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

	# Just a pallate to print ints, never actually used
	print_int:
		lea num_prompt(%rip), %rdi	# Loads the seeds string into rdi
		mov num_guess, %rsi
		xor %rax, %rax				# Cleans rax
		call printf					# Calling printf function

	# Compares the number the user inputted with the number randomly chosen
	# If incorrect, lowers the guess count (M) by one
	# If correct, activates win flag
	compare_num:
		pushq %rbp					# Entering a function, pushing stack
        movq %rsp, %rbp	
		
 		movl num_guess(%rip), %eax      # Load num_guess into eax
    	movl correct_num(%rip), %ebx 	# Load correct_num into ebx

		cmpl %ebx, %eax             # Compare the values in eax and ebx
		je win						# Jumps to win message if the two are equal
		
		popq %rbp					# We pop the stack and return
        ret

	#simply prints the win message
	win:

		inc win_flag				# Sets the win flag to TRUE
		lea win_msg, %rdi			# Loads the message prompt into rdi
		xor	%rax, %rax				# Cleans rax
		call printf					# Prints the message prompt with function

		# Since we are technically still in the comparison function
		# We do not need to push the stack, but we do want to pop it to avoid returning
		# To the continuation of the function, we want to get back to main
		popq %rbp					# We pop the stack and return to main
        ret
	
	# The main loop of the guessing game, asks the user to take a guess and calls the guess_num and
	# compare_num functions
	guessing_game:

		# Checking how many tries the user has left
		call guess_num
		call compare_num

		xorq %rax, %rax
		cmp win_count, %rax
		jne double_or_nothing

		dec %rcx
		cmp %rcx, %rax				# compares the amount of tries left to 0
		je lose			# If the user has no guesses left, jumps to the lose function

		popq %rbp					# We pop the stack and return to main
        ret
	
	# Sends the lose message and ends the game
	lose:
#		pushq %rbp					# Entering a function, pushing stack
#        movq %rsp, %rbp	

		lea game_over, %rdi			# Loads the message prompt into rdi
		xor	%rax, %rax				# Cleans rax
		call printf					# Prints the message prompt with function

		popq %rbp					# We pop the stack and return to main
        ret
	# Prints double or nothing prompt and accepts user imput, sets double_flag according to answer
	double_or_nothing:
		lea double_msg, %rdi		# Loads double message into rdi
		xor %rax, %rax				# Cleans rax
		call printf					# Calling printf function		

		popq %rbp					# We pop the stack and return to main
        ret
		


		