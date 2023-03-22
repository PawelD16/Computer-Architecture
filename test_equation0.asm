.data 
a: .word 5
b: .word 6
c: .word 7
d: .word 8

.text
main:
lw $t0, a #loading values to reg
lw $t1, b
lw $t2, c
lw $t3, d

add $t0, $t0, $t1 #(a+b)-(c-d)
sub $t2, $t2, $t3
sub $t0, $t0, $t2
move $a0, $t0

li $v0, 1 #output
syscall