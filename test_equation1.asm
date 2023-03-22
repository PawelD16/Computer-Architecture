.data
a: .word 5

.text
main:
lw $t0 a
li $t1 1 #used to hold val while multiplying
li $t2 1 #1 used for beq

multiply:
beq $t0, $t2, end
mul $t1, $t0, $t1
subi $t0, $t0, 1
j multiply

end:
move $a0, $t1
li $v0, 1 #output
syscall

