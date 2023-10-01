.data
    file_in: .asciiz "C:/Users/dylan/OneDrive - University of Cape Town/UNIVERSITY FILES/Third Year/Semester 2/CSC2002S/Assignment 3/Images/tree_64_in_ascii_lf.ppm" # input file path
    file_out: .asciiz "C:/Users/dylan/OneDrive - University of Cape Town/UNIVERSITY FILES/Third Year/Semester 2/CSC2002S/Assignment 3/output.ppm" # output file path
    out1: .asciiz "Average pixel value of the original image:\n" # message prefix for original image avg value
    out2: .asciiz "\nAverage pixel value of new image:\n" # message prefix for new image avg value
    buffer_in: .space 100000 # input buffer space
    buffer_out: .space 100000 # output buffer space
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
    li $a2, 100000 # number of bytes to read
    syscall # execute syscall

    la $s0, buffer_in # load address of input buffer to s0
    la $s1, buffer_out # load address of output buffer to s1
    la $s2, buffer_out # another pointer for output buffer
    li $t0, 0 # initialize counter for header lines

loop_h:
    lb $t1, ($s0) # load byte from input buffer
    sb $t1, ($s1) # store byte to output buffer
    addi $s0, $s0, 1 # increment input buffer address
    addi $s1, $s1, 1 # increment output buffer address
    beq $t1, 10, end_hline # if new line character, go to end of header line
    j loop_h # loop again

end_hline:
    addi $t0, $t0, 1 # increment header line counter
    beq $t0, 4, end_h # if 4 lines read, end header reading
    j loop_h # else continue loop

end_h: 
    # Initialize registers for reading pixel values and calculations
    li $t2, 0 # initialize integer value of pixel component
    li $t0, 0 # initialize digit counter
    li.d $f0, 0.0 # initialize sum for original pixel values
    li.d $f2, 0.0 # initialize sum for modified pixel values
    li $t5, 0 # initialize line counter

to_int:
    lb $t1, ($s0) # load a byte from the input buffer
    beq $t1, 10, end_line # if new line, end line reading
    beq $t1, 0, end_file # if null byte, end of file reached
    addi $t1, $t1, -48 # convert ASCII to integer
    mul $t2, $t2, 10 # previous value times 10
    add $t2, $t2, $t1 # add current value
    addi $s0, $s0, 1 # increment input pointer
    addi $s1, $s1, 1 # increment output pointer
    addi $t0, $t0, 1 # increment digit counter
    j to_int # loop

end_line:
    # Handle end of line and calculate average
    addi $t5, $t5, 1 # increment line counter
    beq $t5, 12290, end_file # if all lines read, end file processing
    mtc1 $t2, $f4 # move integer to coprocessor
    cvt.d.w $f4, $f4 # convert word to double
    add.d $f0, $f0, $f4 # add to sum of original pixel values
    addi $s0, $s0, 1 # increment input pointer for next line

    # Check for edge cases, maximum value, or increase by 10
    blt $t2, 10, pad # if value less than 10, handle padding
    bgt $t2, 89, pad # if value greater than 89, handle padding
    bgt $t2, 244, max_vals # if value greater than 244, set to max 255
    addi $t2, $t2, 10 # add 10 to the value
    mtc1 $t2, $f4 # move new value to coprocessor
    cvt.d.w $f4, $f4 # convert to double
    add.d $f2, $f2, $f4 # add to sum of modified pixel values
    li $t7, 10 # load ASCII of newline
    sb $t7, ($s1) # store newline to output buffer
    j to_string # convert integer to string

pad:
    # Handle padding for single and double digit values
    bgt $t2, 99, npad # if value greater than 99 but less than 244, no padding needed
    addi $t2, $t2, 10 # add 10 to value
    mtc1 $t2, $f4 # move to coprocessor
    cvt.d.w $f4, $f4 # convert to double
    add.d $f2, $f2, $f4 # add to sum of modified pixel values
    addi $t0, $t0, 1 # increment digit counter
    addi $s1, $s1, 1 # increment output pointer
    li $t7, 10 # load ASCII of newline
    sb $t7, ($s1) # store newline to output buffer
    j to_string # convert integer to string

npad:
    # Handle non-padded values
    addi $t2, $t2, 10 # add 10 to value
    mtc1 $t2, $f4 # move to coprocessor
    cvt.d.w $f4, $f4 # convert to double
    add.d $f2, $f2, $f4 # add to sum of modified pixel values
    li $t7, 10 # load ASCII of newline
    sb $t7, ($s1) # store newline to output buffer
    j to_string # convert integer to string

max_vals:
    # Handle max values
    li $t2, 255 # set value to max 255
    mtc1 $t2, $f4 # move to coprocessor
    cvt.d.w $f4, $f4 # convert to double
    add.d $f2, $f2, $f4 # add to sum of modified pixel values
    li $t7, 10 # load ASCII of newline
    sb $t7, ($s1) # store newline to output buffer
    j to_string # convert integer to string

to_string:
    # Convert integer value to string and store in output buffer
    beqz $t2, end_to_string # if value is 0, end conversion
    divu $t2, $t2, 10 # divide value by 10 to get each digit
    mfhi $t3 # move remainder to t3
    addi $t3, $t3, 48 # convert to ASCII
    sb $t3, -1($s1) # store ASCII character to output buffer, moving backwards
    addi $s1, $s1, -1 # move output pointer backwards
    j to_string # loop

end_to_string:
    # After conversion, adjust pointers and counters
    add $s1, $s1, $t0 # adjust output pointer position
    addi $s1, $s1, 1 # increment output pointer
    li $t0, 0 # reset value
    j to_int # start next value reading and conversion

end_file:
    # End of file, finalize output buffer and calculate size
    sb $t1, ($s1) # store last byte to output buffer
    sub $s2, $s1, $s2 # calculate size of output
    addi $s2, $s2, -2 # adjust size

    # Write to output file
    li $v0, 15 # syscall for writing to file
    move $a0, $s7 # move file descriptor to a0
    la $a1, buffer_out # load address of output buffer
    move $a2, $s2 # move size to a2
    syscall # execute syscall

close_files:
    # Close both files
    li $v0, 16 # syscall for closing file
    move $a0, $s6 # move file descriptor to a0
    syscall # execute syscall

    li $v0, 16 # syscall for closing file
    move $a0, $s7 # move file descriptor to a0
    syscall # execute syscall

averages:
    # Calculate average pixel values
    li.d $f4, 1044480.0 # load total number of pixels as double
    div.d $f0, $f0, $f4 # calculate average for original image
    div.d $f2, $f2, $f4 # calculate average for modified image

    # Print averages
    li $v0, 4 # syscall for printing string
    la $a0, out1 # load prefix message for original image
    syscall # execute syscall

    li $v0, 3 # syscall for printing double
    mov.d $f12, $f0 # move average of original image to f12
    syscall # execute syscall

    li $v0, 4 # syscall for printing string
    la $a0, out2 # load prefix message for modified image
    syscall # execute syscall

    li $v0, 3 # syscall for printing double
    mov.d $f12, $f2 # move average of modified image to f12
    syscall # execute syscall

exit:
    li   $v0, 10 # syscall for exit
    syscall # exit program
