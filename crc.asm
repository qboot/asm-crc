# CRC Checksum calculation in risc-V
# Inspired by: https://dvsoft.developpez.com/Articles/CRC/

.data

buffer: .asciz "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
buffer_size: .word 100

# CRC16-CCITT Specific
crc_polynomial: .word 0x1021
crc_init_value: .word 0xFFFF

str_1: .asciz "String 1: "
str_2: .asciz "String 2: "

str_equal: .asciz "Strings are equal! :D"
str_not_equal: .asciz "Strings are not equal! :("
str_new_line: .asciz "\n\n"

str_checksum_1: .asciz "Checksum 1: "
str_checksum_2: .asciz "Checksum 2: "

.text

.macro process_byte # params: a0 = current byte / t0 = checksum

la s3, crc_polynomial # polynomial address
lw s4, 0(s3) # polynomial
slli s4, s4, 8 # create 8 empty bits on right

li s5, 8 # iterator (init value: byte size)

slli t0, t0, 8 # create 8 empty bits on right
add t0, t0, a0 # add input byte to checksum

byte_for:
	beqz s5, end_byte_for # if i == 0, break for loop

	slli t0, t0, 1 # move 1 bit to left

	mv s6, t0 # temp copy of checksum. Goal: find the 25th bit's value (from 32 bits)
	slli s6, s6, 7 # move 7 bits to left
	srli s6, s6, 31 # move 31 bits to left

	beqz s6, end_update_checksum # if bit == 0, do NOT update checksum

	update_checksum:
		xor t0, t0, s4 # checksum ^ polynomial
	end_update_checksum:

	addi s5, s5, -1 # i--

	j byte_for
end_byte_for:

slli t0, t0, 8 # delete 8 bits on the left
srli t0, t0, 16 # delete 16 bits on the right

.end_macro # return: t0 = checksum

.macro process_string # params: NO

la s0, buffer # buffer address
la s1, buffer_size # size address
la s2, crc_init_value # init value address
lw t0, 0(s2) # checksum (default value)
lw t1, 0(s1) # size
li t2, 0 # iterator

li a7, 8 # read str string
mv a0, s0 # set buffer
mv a1, t1 # set max number of char
ecall

string_for:
	beq t1, t2, end_string_for # if i > size, break for

	lb a0, 0(s0) # load char from buffer

	li t3, '\n' # null terminator
	beq a0, t3, end_string_for # if end of string, break for

	process_byte # process char in a0

	addi s0, s0, 1 # move to next char address
	addi t2, t2, 1 # i++

	j string_for
end_string_for:

li a0, 0x00
process_byte # process char in a0

li a0, 0x00
process_byte # process char in a0

mv a0, t0

.end_macro # return: a0 = checksum

########
# MAIN #
########

## VAR

li s10, 0 # str_1 checksum
li s11, 0 # str_2 checksum

## STR 1

li a7, 4 # print first message
la a0, str_1
ecall

process_string # call macro
mv s10, a0 # save str_1 checksum

## STR 2

li a7, 4 # print second message
la a0, str_2
ecall

process_string # call macro
mv s11, a0 # save str_2 checksum

## COMPARE & PRINT

# new line
li a7, 11
li a0, '\n'
ecall

beq s10, s11, is_equal

li a7, 4
la a0, str_not_equal
ecall
j end_is_equal

is_equal:
	li a7, 4
	la a0, str_equal
	ecall
end_is_equal:

# new line
li a7, 4
la a0, str_new_line
ecall

li a7, 4 # print first checksum message
la a0, str_checksum_1
ecall

# print first checksum
li a7, 1
mv a0, s10
ecall

# new line
li a7, 11
li a0, '\n'
ecall

li a7, 4 # print second checksum message
la a0, str_checksum_2
ecall

# print second checksum
li a7, 1
mv a0, s11
ecall
