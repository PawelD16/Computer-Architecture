 #$t0 - amount of strings, $t1 - string, $t2 - letter, $t3 - word, $t4 - holds value 32 (ascii of space), $t5 - hold value of 10 (ascii of line feed), $t6 - init value of $sp, $t7 - holds the length of word
.data
how_many_strings_info: .asciiz "\nHow many strings?: "
user_input: .space 1000		#giving user 100 characters to input
word: .asciiz ""		#singular word

.text
main:
li $v0, 4	#printing info
la $a0, how_many_strings_info
syscall

li $v0, 5	#reading amount of strings
syscall
move $t0, $v0 

add $t6, $zero, $sp
la $t3, word
li $t4, 32
li $t5, 10

text_reading:		#reading text entered by user
blez $t0, print_and_end	#ending the iterations

li $v0, 8
la $a0, user_input
li $a1, 100
syscall
la $t1, user_input	#loading read string

subi $t0, $t0, 1	#iterating the amount of senteces

chop_up_to_stack:
lb $t2, 0($t1)	#reading character

beqz $t2, load_to_stack	#checking if its null char or line feed (break conditions)
beq $t2, $t5, load_to_stack
beq $t2, $t4, load_to_stack	#if char it is space, we go and load another word

sb $t2, 0($t3) 		#setting character

addi $t3, $t3, 1	#going to the next character in word and in sentence
addi $t1, $t1, 1
j chop_up_to_stack

load_to_stack:
subi $sp, $sp, 4	#stack is "upside down", thats how its incremented
addi $t1, $t1, 1
addi $t3, $t3, 1
sw $t3, 0($sp)		#storing the word to the stack

beqz $t2, text_reading	#checking if its null char or line feed (break conditions)
beq $t2, $t5, text_reading
j chop_up_to_stack

print_and_end:
li $a0, 10	#putting a line feed
li $v0, 11
syscall

beq $sp, $t6, end	#if the value of sp is its starting value, all things have been printed

lw $a0, ($sp)		#prining the string from stack
li $v0, 4
syscall
addi $sp, $sp, 4	#iterating the stack
j print_and_end

end:
la $a0, word	#prining the first word
li $v0, 4
syscall
addi $sp, $sp, 4
li $v0, 10 #end of program
syscall