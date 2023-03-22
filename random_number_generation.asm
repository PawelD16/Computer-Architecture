#/// and ||| and \\\ are used to enclose loops and functions, so the code is easier to follow
.data
info_on_start: .asciiz "\nPrinting random numbers..."
info_on_end: .asciiz "\nNumbers printed!\n"
amount_of_random_numbers: .word 10
lenght_of_each_random_number: .word 10 

.text
main:
la $a0, info_on_start	#printing initial message
li $v0, 4
syscall

lw $t1, amount_of_random_numbers	#loading the total amount of numbers
lw $t3, lenght_of_each_random_number	#this is used to determine if the first digit of a number is being printed

#///////////////////////////////////////////////////////////////////////////////////////// for each number loop
next_number_loop:
blez $t1, end_of_program	#iterating amount_of_random_numbers counter, and possibly ending the program if it has reached 0
subi $t1, $t1, 1

lw $t2, lenght_of_each_random_number	#loading the amount of digits for each number

li $a0, 10	#loading character newLine
li $v0, 11	#printing character newLine, so the numbers are in a column
syscall

#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ making the number negative (if it was randomly chosen to be)
	li $a1, 101	#getting random chance to determine whether or no the number will be negative (chance from 0 to 100)
	li $v0, 42
	syscall

	move $t0, $a0
	subi $t0, $t0, 50 	#subtract 50 to determine if the number was greater or lower than 50 (if its lower than 50, we print '-' so the number generated is negative)
	bgez $t0, skip_prining_negative	#checking if n-50>=0, to see if we should print the number as negative

	li $a0, 45	#loading character '-'
	li $v0, 11	#printing character '-'
	syscall
	skip_prining_negative:
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

#||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| for each digit loop
		next_digit_loop:		#printing digit by digit allows to preset any length (even read it from user) without being worried that it won't fit in 32 bits (we can only go up to 2,147,483,647 with integers, so we would need to change the entire program if we wanted, for example, 30 digit long random numbers, if done with entrie numbers generated)
		li $a1, 10	#setting the max range to 10 (0<=number<10), so we get digits
		li $v0, 42 
		syscall		#generating random digit

		bnez $a0, skip_rerandomize	#checking if the number is 0, skipping if it isn't
		beq $t2, $t3, next_digit_loop 	#checking if its the first digit, if the number is 0 and its the first digit, we get a different random int
		skip_rerandomize:	#I wasn't sure if this section is required, as our generated "thing" was called a number and a string of characters

		li $v0, 1
		syscall		#printing the digit

		subi $t2, $t2, 1	#iterating amount of digits counter

		blez $t2, next_number_loop	#going to the next number if counter has reached 0
		j next_digit_loop
#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#/////////////////////////////////////////////////////////////////////////////////////////


end_of_program:
la $a0, info_on_end	#printing ending message
li $v0, 4
syscall

li, $v0, 10	#termination
syscall

