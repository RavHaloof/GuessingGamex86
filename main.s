// Avi Ben David, 324026038
.section	.data 				# global variables
	N: 							.long 10
	M: 							.long 5
	yes:						.asciz "y"
	no:							.asciz "n"
	double_it:					.long 2

.section	.rodata				# global constants
	init_msg: 					.asciz "Enter configuration seed:\n"
	ez_msg: 					.asciz "Would you like to play in easy mode? (y/n)"
	guess_msg: 					.asciz "What is your guess? "
	try_again_msg: 				.asciz "Incorrect. "
	lose_msg:					.asciz "Game over, you lost :(. The correct answer was "
	double_msg: 				.asciz "Double or nothing! Would you like to continue to another round?"
	win_msg:					.asciz "Congratz! You won "
	win_msg2: 					.asciz " rounds!"
	num_prompt:					.asciz "%d"
	chr_prompt:					.asciz "%s"
	go_down:					.asciz "\n"


.section	.bss				# IO variables
	seed_val:					.space 4
	num_guess:					.space 4
	double_answer:				.space 1
	ez_mode_answer:				.space 1
	correct_num:				.space 4
	win_flag:					.space 4
	win_count:					.space 4
	guess_counter:				.space 4

.section	.text
.globl		main
.type		main, @function
	main:
		#initialising
		pushq	%rbp
		movq	%rsp,	%rbp

		call enter_seed				# Gets seed from user input
		call random_num_gen			# Generates a random number between 0 - N
		# Sets the win counter to 0 since we start a new game
		mov $0, %rax
		mov %rax, win_flag
		
		call guessing_game

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
		inc %edx					# Increases the remainders by 1, idk why but you wanted it like that for some reason
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

		mov guess_counter, %rax					# Moves M to rax because dec doesn't work on variables
		dec %rax					
		mov %rax, guess_counter					# Decreases M by one

		lea try_again_msg, %rdi		# Loads the message prompt into rdi
		xor	%rax, %rax				# Cleans rax
		call printf					# Prints the message prompt with function

		popq %rbp					# We pop the stack and return to main
        ret

	win:

		lea win_msg, %rdi			# Loads the message prompt into rdi
		xor	%rax, %rax				# Cleans rax
		call printf					# Prints the message prompt with function
		call line_down

		mov $1, %rax
		mov %rax, win_flag			# Sets the win flag to 1, indicating that the user won
		add %rax, win_count			# increases the user's win count by 1
		
		# Since we are technically still in the comparison function
		# We do not need to push the stack, but we do want to pop it to avoid returning
		# To the continuation of the function, we want to get back to main

		popq %rbp					# We pop the stack and return to main
        ret
	
	guessing_game:
		pushq %rbp					# Entering a function, pushing stack
        movq %rsp, %rbp	
		
		# Sets the guess counter to M since we start a new game
		mov M, %rax
		mov %rax, guess_counter

		game_loop:

		call guess_num				# Aceepts user guess
		call compare_num			# Compares the guess with the actual answer

		# In case the user guessed the number right, checks the win flag and jumps to the label if it's equal to 1
		mov win_flag, %rcx			# Moves the value of the win flag to rcx, can be either 0 or 1
		cmp $0, %rcx				# Checks win flag, if it's 1, skips to the win label
		jne double_or_nothing

		# In case the ser is out of guesses, checks the number in counter, if it's 0, stops the game
		mov guess_counter, %ecx		# Moves the value of counter to ecx
		jecxz game_over_lose				# Jumps if ecx is zero, AKA if the user is out of guesses, ends the game

		# In case none of the two conditions were filled, continues the loop (meaning the user still has attempts left and he didn't win)
		jmp game_loop

		# If the user is out of attempts, he loses and we end the game
		game_over_lose:

		lea lose_msg, %rdi			# Loads the message prompt into rdi
		xor	%rax, %rax				# Cleans rax
		call printf					# Prints the message prompt with function

		lea num_prompt(%rip), %rdi	# Loads the seeds string into rdi
		mov correct_num, %rsi
		xor %rax, %rax				# Cleans rax
		call printf					# Calling printf function
		call line_down

		jmp end_loop

		# Accepts input from the user, if y is recieved, proceeds the game, if not, ends it
		double_or_nothing:

		lea double_msg, %rdi		# Loads the message prompt into rdi
		xor	%rax, %rax				# Cleans rax
		call printf					# Prints the message prompt with function
		call line_down

		lea chr_prompt(%rip), %rdi	# We add the prefix to scan the input correctly
    	lea double_answer(%rip), %rsi	# We put the seed number in rsi to be accepted by the scan
    	xor %rax, %rax				# We clean rax
    	call scanf					# Calling scanf function

		mov double_answer, %rcx			# Moves the user's answer to ecx, the actual answer is stored in cl since chars are byte sized
		cmpb yes, %cl					# compares only cl with 'y', if they're equal, "doubles" the game		
		je double_accepted

		end_loop:

		popq %rbp					# We pop the stack and return to main				
        ret

		double_accepted:

		mov $0, %rcx
		mov %rcx, win_flag

		call double_game

		mov win_count, %rcx
		inc %rcx
		mov %rcx, win_count

		lea num_prompt(%rip), %rdi	# Loads the seeds string into rdi
		mov win_count, %rsi
		xor %rax, %rax				# Cleans rax
		call printf					# Calling printf function
		call line_down

		lea num_prompt(%rip), %rdi	# Loads the seeds string into rdi
		mov win_flag, %rsi
		xor %rax, %rax				# Cleans rax
		call printf					# Calling printf function
		call line_down

		call random_num_gen

		jmp game_loop

	double_game:

		pushq %rbp					# Entering a function, pushing stack
        movq %rsp, %rbp	

		mov N, %ecx
		imul double_it, %ecx
		mov %ecx, N

		mov M, %rcx
		mov %rcx, guess_counter

		popq %rbp					# We pop the stack and return to main				
        ret
