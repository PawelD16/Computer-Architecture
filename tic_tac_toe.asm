#$t0 - hold adress of 2Dboard, $t1 - amount of rounds, $t2 - round won by player, $t3 - rounds won by computer, $t4 - moves played by player per round
#the player is 'x' (ascii value of 'x' is 120) and the computer is 'o' (ascii value of 'o' is 111)
.data
	amount_of_round_info: .asciiz "When playing click the number of a position that has not 'x' or 'o' to choose a move. Enter desired amount of rounds: \n"
	player_won: .asciiz "You win!\n"
	computer_won: .asciiz "You lose!\n"
	draw_info: .asciiz "Draw!\n"
	result_of_match: "The result of the match: (you)"
	incorrect_player_input: .asciiz "You can't do that move! Try a different one.\n"

	board:	.word 49, 50, 51, 52, 51, 54, 55, 56, 57
	
	.eqv DATA_SIZE 4 #size of integers (constant)

.text
	main:
		li $v0, 4	#printing info
		la $a0, amount_of_round_info
		syscall
	
		li $v0, 5	#read amount of rounds
		syscall
		move $t1, $v0
		
			match_loop:
				li $t4, 0	#if player has done 5 moves the round must be over
				subi $t1, $t1, 1
				bltz $t1, exit
				jal clear_board
				
					round_loop:
					jal print_board
						jal players_move
						addi $t4, $t4, 1
						jal check_for_winner_horizontal
						jal check_for_winner_vertical
						jal check_for_winner_diagonals
						
						jal computers_move
						jal check_for_winner_horizontal
						jal check_for_winner_vertical
						jal check_for_winner_diagonals
						
						beq $t4, 5, draw	#if player has done 5 moves and hasnt won then its a draw
						j round_loop
			
				j match_loop
							
	exit:	#exiting the program and printing the results
		li $v0, 4	#printing results
		la $a0, result_of_match
		syscall
		
		li $v0, 1	#printing players and computers score with a ':'
		move $a0, $t2
		syscall
		
		
		li $v0, 11	#printing players and computers score with a ':'
		li $a0, 58
		syscall
		
		li $v0, 1	#printing players and computers score with a ':'
		move $a0, $t3
		syscall
		
		li $v0, 10
		syscall
		
	
	players_move:	
		li $v0, 5
		syscall
		move $a1, $v0
		blez $a1, redo	#input value if lower than 0
		subi $a1, $a1, 9	
		bgtz $a1, redo	#input is bigger than 9
		addi $a1, $a1, 9	#if input is correct we check if it can be placed on the board
		j skip_redo
			redo:
				li $v0, 4	#printing info
				la $a0, incorrect_player_input
				syscall
				move $t8, $ra	#this is done so we can return to place where we jumped from
				jal print_board
				move $ra, $t8
				j players_move
		skip_redo:
		la $t0, board
		
		subi $a1, $a1, 1
		mul $a1, $a1, DATA_SIZE
		add $a1, $a1, $t0
		
		lw $a0, ($a1)	#finding if the value that player input is untaken
		
		subi $a0, $a0, 57
		bgtz $a0, redo	#checking if its taken already
		
		li $t9, 120	#putting in 'x'
		sb $t9, ($a1)
		
		jr $ra
		
	computers_move:	#move sequence is 4->5->6->9->1->7->8->2->3 (not random)
		li $t9, 0
		computers_move_loop:
		addi $t9, $t9, 1
		la $t0, board
		
		li $a1, 4
		beq $t9, 1, skip_choosing
		li $a1, 5
		beq $t9, 2, skip_choosing
		li $a1, 6
		beq $t9, 3, skip_choosing
		li $a1, 9
		beq $t9, 4, skip_choosing
		li $a1, 1
		beq $t9, 5, skip_choosing
		li $a1, 7
		beq $t9, 6, skip_choosing
		li $a1, 8
		beq $t9, 7, skip_choosing
		li $a1, 2
		beq $t9, 8, skip_choosing
		li $a1, 3
		beq $t9, 9, skip_choosing
		skip_choosing:
		
		subi $a1, $a1, 1
		mul $a1, $a1, DATA_SIZE
		add $a1, $a1, $t0
		
		lw $a0, ($a1)	#finding if the value that player input is untaken
		
		subi $a0, $a0, 57
		bgtz $a0, computers_move_loop	#checking if its taken already
		
		li $t9, 111	#putting in 'x'
		sb $t9, ($a1)
		
		jr $ra	
		
	check_for_winner_horizontal:	#checks for winner in rows, there are 3 ways to win there
		la $t0, board
		li $t9, 0	#for iterating over the board
		li $t8, 0	#as sum to check if 3 in a row were the same
		
		check_for_winner_horizontal_loop:			
			lw $a0, ($t0)
			
			add $t8, $t8, $a0
			
			addi $t9, $t9, 1
			addi $t0, $t0, DATA_SIZE
			
			beq $t9, 3, new_row	#checking if a new row has begun (and if there is a new winner, as these are the only times that is possible)
			beq $t9, 6, new_row
			beq $t9, 9, new_row
			j skip_in_check_for_winner_horizontal
				
				new_row:	#we need to check only the sum, its impossible to get that sum with other characters in place so there is no need for addidional cases!
					beq $t8, 360, player_won_the_round	#if the sum is 360, that means there were 3 'x''s in a row, so the player won
					beq $t8, 333, computer_won_the_round	#if the sum is 333, that means there were 3 'o''s in a row, so the computer won
					li $t8, 0	#zeroing $t8 for a new row if nobody won
			skip_in_check_for_winner_horizontal:
			
			bne $t9, 9, check_for_winner_horizontal_loop
		jr $ra
		
	check_for_winner_vertical:	#checks for winner in columns, there are 3 ways to win there
		la $t0, board
		li $t9, 0	#for iterating over the board
		li $t8, 0	#as sum to check if 3 in a collumn were the same
		
		check_for_winner_vertical_loop:
			lw $a0, ($t0)
			
			add $t8, $t8, $a0
			
			addi $t9, $t9, 1
			addi $t0, $t0, 12	#going to next in column
			
			beq $t9, 3, new_column	#checking if a new column has begun (and if there is a new winner, as these are the only times that is possible)
			beq $t9, 6, new_column
			beq $t9, 9, new_column
			j skip_in_check_for_winner_vertical
				
				new_column:	#we need to check only the sum, its impossible to get that sum with other characters in place so there is no need for addidional cases!
					beq $t8, 360, player_won_the_round	#if the sum is 360, that means there were 3 'x''s in a column, so the player won
					beq $t8, 333, computer_won_the_round	#if the sum is 333, that means there were 3 'o''s in a column, so the computer won
					
					subi $t0, $t0, 32	#going 8 slots back to end up at beginning of new column
					
					li $t8, 0	#zeroing $t8 for a new columnw if nobody won
					
			skip_in_check_for_winner_vertical:
			
			bne $t9, 9, check_for_winner_vertical_loop
		jr $ra
		
	check_for_winner_diagonals:	#checks for winner in diagonals, there are 2 cases here and they are different enough as to not need any loops
		la $t0, board
			check_for_winner_diagonal:
				li $t8, 0
				lw $a0, 0($t0)
				add $t8, $t8, $a0
				lw $a0, 16($t0)
				add $t8, $t8, $a0
				lw $a0, 32($t0)
				add $t8, $t8, $a0
		
				beq $t8, 360, player_won_the_round	#if the sum is 360, that means there were 3 'x''s in a diagonal, so the player won
				beq $t8, 333, computer_won_the_round	#if the sum is 333, that means there were 3 'o''s in a diagonal, so the computer won
				
			check_for_winner_counter_diagonal:
				li $t8, 0
				lw $a0, 8($t0)
				add $t8, $t8, $a0
				lw $a0, 16($t0)
				add $t8, $t8, $a0
				lw $a0, 24($t0)
				add $t8, $t8, $a0
		
				beq $t8, 360, player_won_the_round	#if the sum is 360, that means there were 3 'x''s in a counter diagonal, so the player won
				beq $t8, 333, computer_won_the_round	#if the sum is 333, that means there were 3 'o''s in a counter diagonal, so the computer won
		jr $ra
			
	player_won_the_round:	#player won the round
		move $t8, $ra	#this is done so we can return to place where we jumped from
		jal print_board
		move $ra, $t8
		addi $t2, $t2, 1	#adding 1 to win count for player
		li $v0, 4	#printing info
		la $a0, player_won
		syscall
		j match_loop
		
	computer_won_the_round:	#computer won the round
		move $t8, $ra	#this is done so we can return to place where we jumped from
		jal print_board
		move $ra, $t8
		addi $t3, $t3, 1	#adding 1 to win count for computer
		li $v0, 4	#printing info
		la $a0, computer_won
		syscall
		j match_loop
		
	draw:
		li $v0, 4	#printing info
		la $a0, draw_info
		syscall
		j match_loop
		
	clear_board:	#giving board these values so it prints as numbers 
		la $t0, board
		li $t9, 49	#starting at 49 means that we can use it to put in correct values
		clear_board_loop:
			sb $t9, ($t0)
			
			addi $t9, $t9, 1
			addi $t0, $t0, DATA_SIZE
			
			bne $t9, 58, clear_board_loop
		jr $ra
		
	print_board:
			li $v0, 11
			la $t0, board
			li $t9, 0	#as index
			print_board_loop:
					
				lw $a0, ($t0)
				syscall
				
				beq $t9, 2, print_newline
				beq $t9, 5, print_newline
				beq $t9, 8, print_newline
				j skip_in_print_board
				
					print_newline:	#prining newLine to make the board the correct shape
						li $a0, 10
						syscall
				skip_in_print_board:
					
				addi $t9, $t9, 1
				addi $t0, $t0, DATA_SIZE
				bne $t9, 9, print_board_loop
		jr $ra
