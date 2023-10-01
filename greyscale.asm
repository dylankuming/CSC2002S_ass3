.data
    file_in: .asciiz "C:/Users/dylan/OneDrive - University of Cape Town/UNIVERSITY FILES/Third Year/Semester 2/CSC2002S/Assignment 3/Images/tree_64_in_ascii_lf.ppm"  # input file path
    file_out: .asciiz "C:/Users/dylan/OneDrive - University of Cape Town/UNIVERSITY FILES/Third Year/Semester 2/CSC2002S/Assignment 3/greyscale.ppm" # output file path
    buffer_in: .space 60000  # input buffer space
    buffer_out: .space 60000  # output buffer space
.text
.globl main

main:
    # File Handling
    li $v0, 13 # syscall for opening a file
    la $a0, file_in # load input file path
    li $a1, 0 # flag for read mode
    li $a2, 0 # no use in read mode
    syscall # execute syscall
    move $s6, $v0 # store file descriptor to s6

    li $v0, 13 # syscall for opening a file
    la $a0, file_out # load output file path
    li $a1, 1 # flag for write mode
    li $a2, 0 # no use in write mode
    syscall # execute syscall
    move $s7, $v0 # store file descriptor to s7

read_file:
    li $v0, 14 # syscall for reading from a file
    move $a0, $s6 # move file descriptor to a0
    la $a1, buffer_in # load address of input buffer
    li $a2, 60000 # number of bytes to read
    syscall # execute syscall

    la $s0, buffer_in # load address of input buffer to s0
    la $s1, buffer_out # load address of output buffer to s1
    la $s2, buffer_out # another pointer for output buffer
    li $t0, 1 # initialize counter for header lines

    # Hardcoding P2 format specification for the output image header
    li $t1, 80 # ASCII for 'P'
    sb $t1, ($s1) # store 'P' to output buffer
    addi $s0, $s0, 1 # increment input buffer address
    addi $s1, $s1, 1 # increment output buffer address
    li $t1, 50 # ASCII for '2'
    sb $t1, ($s1) # store '2' to output buffer
    addi $s0, $s0, 1 # increment input buffer address
    addi $s1, $s1, 1 # increment output buffer address
    li $t1, 10 # ASCII for newline
    sb $t1, ($s1) # store newline to output buffer
    addi $s0, $s0, 1 # increment input buffer address
    addi $s1, $s1, 1 # increment output buffer address

loop_h:
    lb $t1, ($s0) # load byte from input buffer
    sb $t1, ($s1) # store byte to output buffer
    addi $s0, $s0, 1 # increment input buffer address
    addi $s1, $s1, 1 # increment output buffer address
    beq $t1, 10, end_hline # if newline, go to end of header line
    j loop_h # loop again

end_hline:
    addi $t0, $t0, 1 # increment header line counter
    beq $t0, 4, end_h # if 4 lines read, end header reading
    j loop_h # else continue loop

end_h: 
    # Initialization for reading pixel values
    li $t2, 0 # initialize integer value of pixel component
    li $t0, 0 # initialize digit counter
    li $t3, 0 # initialize counter for the number of pixels read
    li $t4, 0 # initialize sum of RGB components
    li $t5, 0 # initialize line counter for the grayscale values

to_int:
    lb $t1, ($s0) # load a byte from the input buffer
    beq $t1, 10, end_line # if newline, end line reading
    beq $t1, 0, end_file # if null byte, end of file reached
    addi $t1, $t1, -48 # convert ASCII to integer
    mul $t2, $t2, 10 # previous value times 10
    add $t2, $t2, $t1 # add current value
    addi $s0, $s0, 1 # increment input pointer
    j to_int # loop

end_line:
    # Process the end of a line, calculate the average and prepare for next line
    addi $s0, $s0, 1 # increment input pointer for next line
    addi $t3, $t3, 1 # increment pixel counter
    add $t4, $t4, $t2 # add current pixel value to sum
    li $t2, 0 # reset current pixel value for next pixel
    beq $t3, 3, end_three_line # if 3 pixels read (RGB), calculate grayscale value
    j to_int # continue reading next pixel value

end_three_line:
    # Calculate the grayscale value and prepare for the output
    addi $t5, $t5, 1 # increment grayscale line counter
    beq $t5, 4097, end_file # if all lines read, end file processing
    divu $t4, $t4, 3 # calculate average grayscale value
    mflo $t2 # get the quotient

    # Determine padding needed for output grayscale value
    blt $t2, 100, pad_2 # if value less than 100, 2 characters needed
    addi $s1, $s1, 3 # prepare for 3 characters in output buffer
    li $t7, 10 # ASCII for newline
    sb $t7, ($s1) # store newline to output buffer
    j to_string # convert integer to string

pad_2:
    blt $t2, 10, pad_1 # if value less than 10, 1 character needed
    addi $s1, $s1, 2 # prepare for 2 characters in output buffer
    li $t7, 10 # ASCII for newline
    sb $t7, ($s1) # store newline to output buffer
    j to_string # convert integer to string

pad_1:
    addi $s1, $s1, 1 # prepare for 1 character in output buffer
    li $t7, 10 # ASCII for newline
    sb $t7, ($s1) # store newline to output buffer
    j to_string # convert integer to string

to_string:
    # Convert integer grayscale value to string
    beqz $t2, end_to_string # if 0, end conversion
    divu $t2, $t2, 10 # divide by 10 to get each digit
    mfhi $t3 # get remainder
    addi $t3, $t3, 48 # convert to ASCII
    sb $t3, -1($s1) # store ASCII character to output buffer
    addi $s1, $s1, -1 # move buffer pointer backward
    addi $t0, $t0, 1 # increment character count
    j to_string # loop

end_to_string:
    # Finalize the conversion and prepare for next grayscale value
    add $s1, $s1, $t0 # adjust output buffer pointer
    addi $s1, $s1, 1 # move to next position
    li $t0, 0 # reset character count
    li $t4, 0 # reset grayscale sum
    li $t3, 0 # reset pixel counter
    j to_int # start reading next grayscale value

end_file:
    # End of file, finalize output buffer
    sb $t1, ($s1) # store last byte to output buffer
    sub $s2, $s1, $s2 # calculate the size of output data

    # Write to output file
    li $v0, 15 # syscall for writing to a file
    move $a0, $s7 # move file descriptor to a0
    la $a1, buffer_out # load address of output buffer
    move $a2, $s2 # move size of data to a2
    syscall # execute syscall

close_files:
    # Close input file
    li $v0, 16 # syscall for closing a file
    move $a0, $s6 # move file descriptor to a0
    syscall # execute syscall

    # Close output file
    li $v0, 16 # syscall for closing a file
    move $a0, $s7 # move file descriptor to a0
    syscall # execute syscall

exit:
    # Exit the program
    li $v0, 10 # syscall for exit
    syscall # execute syscall
