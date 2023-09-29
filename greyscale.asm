.data
filename:   .asciiz"C:/Users/dylan/OneDrive - University of Cape Town/UNIVERSITY FILES/Third Year/Semester 2/CSC2002S/Assignment 3/Images/tree_64_in_ascii_lf.ppm"
outfile:    .asciiz"C:/Users/dylan/OneDrive - University of Cape Town/UNIVERSITY FILES/Third Year/Semester 2/CSC2002S/Assignment 3/greyscale.ppm"
buffer:     .space 50000
output:     .space 50000
reversed_value: .space 4


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

    li $t0, 3   #Keeps track of position reading from in buffer
    li $t1, 0   #Count end of line chars
    li $t4, 0   #Keeps track of position writing to in output buffer
    li $t7, 0   #Keeps track of position writing to in reversed_string buffer
    li $s1, 0   #Holds sum of values of 3 lines that must be averaged 
    li $t5, 0   #Used to count to 3 lines

    #Write P
    li $t2, 80
    sb $t2, output($t4)
    addi $t4, 1
    #Write 2
    li $t2, 50
    sb $t2, output($t4)
    addi $t4, 1
    #Write \n
    li $t2, 10
    sb $t2, output($t4)
    addi $t4, 1

file_info_loop:
    beq $t1, 3, pixel_value_loop    #All file info stored after 3 new line characters
    lb $t2, buffer($t0)
    sb $t2, output($t4)
    addi $t0, 1
    addi $t4, 1
    beq $t2, 10, lf #If new line
    j file_info_loop

lf:
    addi $t1, 1
    j file_info_loop

pixel_value_loop:
    li $s0, 0   #$s0 will hold current value
    

string_to_int:
    lb $t2, buffer($t0)
    addi $t0, $t0, 1
    beq $t2, $zero, write_file
    beq $t2, 10, plus
    
    sub $t2, $t2, 48
    mul $s0, $s0, 10
    add $s0, $s0, $t2

    j string_to_int

plus:
    add $s1, $s1, $s0
    addi $t5, 1
    beq $t5, 3, average
    j pixel_value_loop

average:
    li $s6, 3
    div $s1, $s6
    mflo $s0
    li $s1,0
    li $t7, 0
    li $t5, 10

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
    sb $t5, output($t4)
    addi $t4, 1
    li $t5, 0
    j pixel_value_loop

write_file:

    li $v0, 4
    la $a0, outfile
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