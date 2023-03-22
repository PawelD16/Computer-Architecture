#Pawel Dudek, szyfr Cezara
.data
info0: .asciiz "\nWhat operation would you like to perform? (0=encryption/1=decrytpion}: "
info1: .asciiz "\nShift amount: "
info2: .asciiz "\nInput the text to be encrypted: "
info3: .asciiz "\nInput the text to be decrypted: "
error: .asciiz "\nincorrect input!"

user_input: .space 16 #reserves memory for 16 letters that user can input
length_of_alphabet: .word 26

#%t0 is type of operation, $t1 is shift amount, $t3 is text to be shifted, $t4 is the length of alphabet, $t5 is for operations on letters

.text
main:
la $a0, info0 #print info0 string
li $v0, 4
syscall
li $v0, 5 #read and load operation type
syscall
move $t0, $v0 

la $a0, info1 #print info1 string
li $v0, 4
syscall
li $v0, 5 #read and load shift amount
syscall
move $t1, $v0 

lw $t4, length_of_alphabet
li, $s1, 10 #loading in ascii code for line feed character

beqz $t0, encryption

decryption:
la $a0, info3 #print info3 string
li $v0, 4
syscall
neg $t1, $t1 #negating the shift amount means that we are decrytping
j text_reading

encryption:
la $a0, info2 #print info3 string
li $v0, 4
syscall

text_reading: #reading text entered by user
li $v0, 8
la $a0, user_input
la $a1, 18 #we need space for 18 because there is null char and line feed on the end (if we put this to 16, we can input 14 characters)
syscall
la $t3, user_input #loading read string

turn_shiftamount_positive: #making sure that shift is positive (for example shifting by -1 is the same as shifting 25)
slt $t7, $t1, $zero #if $t1 < 0 we set $t7 to 1
beqz $t7, end_of_turn_shiftamount_positive  #check if $t7 isn't 1, if so break
add $t1, $t1, $t4
j turn_shiftamount_positive
end_of_turn_shiftamount_positive:


loop: #loop that modifies letters
lb $t5, ($t3) #reading the letter
beqz $t5, end #checking if its null char or line feed (break conditions)
beq $t5, $s1, end 

j check_for_letters #this ensures our characters are letters
continue_loop:

subi $t5, $t5, 65 #subtracting 65 (so we get position of letter in alphabet)
add $t5, $t5, $t1 # $t5 = (number of letter + shift) % lenght of alphabet  
div $t5, $t4
mfhi $t5
addi $t5, $t5, 65 #adding back 65 so the ascii codes match up

sb $t5, ($t3) #setting char as $t5

addi $t3, $t3, 1 #next letter
j loop

end:
la $a0, user_input #loading the modified string
li $v0, 4
syscall

system_exit:
li $v0, 10 #end of program
syscall


############################################
check_for_letters: #checks if the ascii code is a letter (and makes small letters big, as we dont differentiacte between those)!
li $s0, 2
li $t7, 96
slt $t6, $t7, $t5 #if both are 1 then its a small letter
slti $t7, $t5, 123

add $t6, $t6, $t7
bne $t6, $s0, check_for_big_letters #checking if 97<%t5<122
subi $t5, $t5, 32
j continue_loop

check_for_big_letters:
li $t7, 64
slt $t6, $t7, $t5 #if both are 1 then its a small letter
slti $t7, $t5, 91

add $t6, $t6, $t7
bne $t6, $s0, error_label #checking if 65<%t5<90
j continue_loop

error_label:
la $a0, error #output error, a character wass not a letter! (our alphabet does not contain anything outside letters)
li $v0, 4
syscall
j system_exit
############################################


