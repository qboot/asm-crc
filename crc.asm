# CRC Checksum
# inspired by: https://dvsoft.developpez.com/Articles/CRC/

.data

input: .word 'B', 'a', 'n', 'j', 'o', 'u', 'r', ' ', 'P', 'a', 'p', 'o'
size: .word 12

.text

la a0, input # *input
la a1, size # *size
lw t0, 0(a1) # size

li t1, 0 # hash
mv a2, a0 # *offset

for:
	slli t2, t0, 2 # calculate size of array in Bytes (12 * 4 Bytes)
	add t3, a0, t2 # find address of last item of array
	sub t4, t3, a2 # check if we have reach end of array
	beq t4, zero, end_for # interrupt for loop
	
	lw t5, 0(a2) # current item value
	add t1, t1, t5 # update hash
	addi a2, a2, 4 # goto next offset array item
	
	j for
end_for:

li t6, 0xFF # 255
rem a0, t1, t6 # modulo

li a7, 1
ecall
