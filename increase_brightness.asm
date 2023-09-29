.data
    filename:   .asciiz"C:/Users/dylan/OneDrive - University of Cape Town/UNIVERSITY FILES/Third Year/Semester 2/CSC2002S/Assignment 3/Images/tree_64_in_ascii_lf.ppm"
    buffer:     .space 50000
    output:     .space 50000
    reversed_value: .space 4
    average_before: .asciiz"Average pixel value of the original image:\n"
    average_after:  .asciiz"\nAverage pixel value of new image:\n"
    outfile:    .asciiz"C:/Users/dylan/OneDrive - University of Cape Town/UNIVERSITY FILES/Third Year/Semester 2/CSC2002S/Assignment 3/output.ppm"

.text
.globl main

main:

    #Open File for reading
    li $v0, 13
    la $a0, filename
    li $a1, 0
    li $a2, 0
    syscall
    move $s6, $v0   #$s6 stores file descriptor

    #Read file into buffer
    li $v0, 14
    move $a0, $s6
    la $a1, buffer
    li $a2, 49999
    syscall
    move $s7, $v0   #$s7 contains number of characters read

    #Close file
    li $v0, 16
    move $a0, $s6
    syscall

    li $t0, 0   #Character counter
    li $t1, 0   #Count end of line chars
    li $t4, 0   #Position writing to in output
    li $t5, 10  #Used to divide by 10
    li $t7, 0
    li $s1, 0
    li $s2, 0

file_info_loop:
    beq $t1, 4, pixel_value_loop
    lb $t2, buffer($t0)
    sb $t2, output($t4)
    addi $t0, 1
    addi $t4, 1
    beq $t2, 10, lf
    j file_info_loop

lf:
    addi $t1, 1
    j file_info_loop

pixel_value_loop:
    li $s0, 0   #$s0 will hold current value
    li $t7, 0

string_to_int:
    lb $t2, buffer($t0)
    addi $t0, $t0, 1
    beq $t2, $zero, write_file
    beq $t2, 10, add_ten
    
    sub $t2, $t2, 48
    mul $s0, $s0, 10
    add $s0, $s0, $t2

    j string_to_int

add_ten:
    add $s2, $s2, $s0
    bgt $s0, 245, set_value
    addi $s0, 10
    add $s1, $s1, $s0
    j int_to_string

set_value:
    li $s0, 255
    add $s1, $s1, $s0

int_to_string:
    div $s0, $t5
    mflo $s0
    mfhi $t3
    addi $t3, 48
    sb $t3, reversed_value($t7)
    addi $t7, 1
    beq $s0, $zero, startReverse
    j int_to_string

startReverse:
     li $t6, 2

reverse_string:
    lb $t2, reversed_value($t6)
    sb $t2, output($t4)
    addi $t4, 1
    beq $t6, $zero, newLine
    sub $t6, 1
    j reverse_string

newLine:
    li $t5, 10
    sb $t5 output($t4)
    addi $t4, 1
    j pixel_value_loop

write_file:

    li $v0, 4
    la $a0, average_before
    syscall

    li $t0, 3133440 # 64x64x3x255
    mtc1 $t0, $f13
    mtc1 $s2, $f12
    div.s $f12, $f12, $f13
    li $v0, 2
    syscall

    li $v0, 4
    la $a0, average_after
    syscall

    li $t0, 3133440 # 64x64x3x255
    mtc1 $t0, $f13
    mtc1 $s1, $f12
    div.s $f12, $f12, $f13
    li $v0, 2
    syscall
    # Open the output file for writing
    li $v0, 13         # System call code for opening a file (13)
    la $a0, outfile    # Load the address of the output file name
    li $a1, 1          # File open mode: 1 (write)
    li $a2, 0          # File permission: 0 (not applicable for writing)
    syscall
    move $s8, $v0      # Store the file descriptor in $s8

    # Write the content of the output buffer to the file
    li $v0, 15         # System call code for writing to a file (15)
    move $a0, $s8      # File descriptor
    la $a1, output     # Load the address of the output buffer
    li $a2, 50000      # Number of bytes to write (adjust as needed)
    syscall

    # Close the output file
    li $v0, 16         # System call code for closing a file (16)
    move $a0, $s8      # File descriptor
    syscall

exit:
    li $v0, 10
    syscall


