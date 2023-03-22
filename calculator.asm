.data
arg1: .asciiz "\nargument pierwszy: "
arg2: .asciiz "\nargument drugi: "
arg3: .asciiz "\nargument trzeci: "
result: .asciiz "\nwynik: "
no_eq: .asciiz "\nzly argument rownania!\n"
end_question: .asciiz "\nwlaczyc kalkulator od nowa? (Y=1/N=0): "

.text
main:
la $a0, arg1 #print arg1
li $v0, 4
syscall
li $v0, 5 #read and load first argument
syscall
move $t1, $v0

la $a0, arg2 #print arg2
li $v0, 4
syscall
li $v0, 5 #read and load second argument
syscall
move $t2, $v0

la $a0, arg3 #print arg3
li $v0, 4
syscall
li $v0, 5 #read and load third argument
syscall
move $t3, $v0

li $t4, 0 #loading values of equations
li $t5, 1
li $t6, 2
li $t7, 3

beq $t2, $t4, addition #equations jumpto
beq $t2, $t5, subtraction
beq $t2, $t6, multiplication
beq $t2, $t7, division
j incorrect_eq #else if no equation chosen

addition: #equation operations
add $t1, $t1, $t3
j output
subtraction:
sub $t1, $t1, $t3
j output
multiplication:
mul $t1, $t1, $t3
j output
division:
div $t1, $t1, $t3


output: #output if correct equation
la $a0, result #print result string
li $v0, 4
syscall
move $a0, $t1 #print result itself
li $v0, 1
j end

incorrect_eq: #output if incorrect equation
la $a0, no_eq
li $v0, 4

end:
syscall
la $a0, end_question #print question string
li $v0, 4
syscall
li $v0, 5 #read and load first argument
syscall
bne $v0, $zero, main


