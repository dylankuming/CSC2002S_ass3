.data
    filename:   .asciiz"C:/Users/dylan/OneDrive - University of Cape Town/UNIVERSITY FILES/Third Year/Semester 2/CSC2002S/Assignment 3/Images/tree_64_in_ascii_lf.ppm" # File path for the input PPM image
    buffer:     .space 50000 # Buffer to hold the content of the input file
    output:     .space 50000 # Buffer to hold the content of the output file after processing
    reversed_value: .space 4 # Buffer to hold the reversed string representation of a number
    average_before: .asciiz"Average pixel value of the original image:\n" # Message for the average pixel value before modification
    average_after:  .asciiz"\nAverage pixel value of new image:\n" # Message for the average pixel value after modification
    outfile:    .asciiz"C:/Users/dylan/OneDrive - University of Cape Town/UNIVERSITY FILES/Third Year/Semester 2/CSC2002S/Assignment 3/output.ppm" # File path for the output PPM image

.text
.globl main

main:
    # Open File for reading
    li $v0, 13 # System call code for opening a file
    la $a0, filename # Load the address of the file name
    li $a1, 0 # File open mode: 0 (read)
    li $a2, 0 # File permission: 0 (not applicable for reading)
    syscall # Execute system call
    move $s6, $v0   # Store file descriptor in $s6

    # Read file into buffer
    li $v0, 14 # System call code for reading from a file
    move $a0, $s6 # File descriptor
    la $a1, buffer # Load the address of the buffer
    li $a2, 49999 # Number of bytes to read
    syscall # Execute system call
    move $s7, $v0   # Store number of characters read in $s7

    # Close file
    li $v0, 16 # System call code for closing a file
    move $a0, $s6 # File descriptor
    syscall # Execute system call

    # Initialize registers
    li $t0, 0   # Character counter
    li $t1, 0   # Count end of line characters
    li $t4, 0   # Position for writing to in output buffer
    li $t5, 10  # Value used for division by 10 in integer to string conversion
    li $t7, 0   
    li $s1, 0   # Sum of modified pixel values for average calculation
    li $s2, 0   # Sum of original pixel values for average calculation

# Loop to process the header of the PPM file
file_info_loop:
    beq $t1, 4, pixel_value_loop # If 4 end of line characters are counted, move to processing pixel values
    lb $t2, buffer($t0) # Load a byte from the buffer into $t2
    sb $t2, output($t4) # Store the byte in the output buffer
    addi $t0, 1 # Increment character counter
    addi $t4, 1 # Increment output buffer position
    beq $t2, 10, lf # If end of line character is encountered, increment end of line counter
    j file_info_loop

# Increment end of line counter
lf:
    addi $t1, 1 
    j file_info_loop

# Loop to process the pixel values in the PPM file
pixel_value_loop:
    li $s0, 0   # Register to hold the current pixel value
    li $t7, 0

# Convert ASCII string to integer
string_to_int:
    lb $t2, buffer($t0) # Load a byte from the buffer
    addi $t0, $t0, 1 # Increment character counter
    beq $t2, $zero, write_file # If null terminator is encountered, move to file writing
    beq $t2, 10, add_ten # If end of line character is encountered, increment the pixel value by ten
    
    # Convert ASCII character to integer and build up the pixel value
    sub $t2, $t2, 48 
    mul $s0, $s0, 10 
    add $s0, $s0, $t2

    j string_to_int

# Add ten to the pixel value, ensuring it doesn’t exceed 255
add_ten:
    add $s2, $s2, $s0 # Add the original pixel value to the sum
    bgt $s0, 245, set_value # If the pixel value is greater than 245, set it to 255
    addi $s0, 10 # Otherwise, add ten to the pixel value
    add $s1, $s1, $s0 # Add the modified pixel value to the sum
    j int_to_string

# Set the pixel value to 255 if adding ten would exceed 255
set_value:
    li $s0, 255 
    add $s1, $s1, $s0 

# Convert integer pixel value to ASCII string
int_to_string:
    div $s0, $t5 # Divide the pixel value by ten to separate the digits
    mflo $s0 
    mfhi $t3 
    addi $t3, 48 # Convert the remainder to ASCII
    sb $t3, reversed_value($t7) # Store the ASCII character in the reversed string buffer
    addi $t7, 1 
    beq $s0, $zero, startReverse # If the pixel value is zero, start reversing the string
    j int_to_string

# Reverse the ASCII string for correct output
startReverse:
    li $t6, 2 

reverse_string:
    lb $t2, reversed_value($t6) # Load a character from the reversed string buffer
    sb $t2, output($t4) # Store the character in the output buffer
    addi $t4, 1 # Increment output buffer position
    beq $t6, $zero, newLine # If all characters are processed, add a new line character to the output
    sub $t6, 1 
    j reverse_string

# Add a new line character to the output
newLine:
    li $t5, 10 
    sb $t5 output($t4) 
    addi $t4, 1 
    j pixel_value_loop

# Print the averages and write the modified image to a file
write_file:
    # Print the average pixel value before modification
    li $v0, 4 
    la $a0, average_before 
    syscall 

    # Calculate and print the average pixel value before modification
    li $t0, 3133440 # Total number of pixels times max value
    mtc1 $t0, $f13 # Move to co-processor 1
    mtc1 $s2, $f12 
    div.s $f12, $f12, $f13 # Divide the sum of original values by total pixels times max value
    li $v0, 2 
    syscall 

    # Print the message for average pixel value after modification
    li $v0, 4 
    la $a0, average_after 
    syscall 

    # Calculate and print the average pixel value after modification
    li $t0, 3133440 # Total number of pixels times max value
    mtc1 $t0, $f13 
    mtc1 $s1, $f12 
    div.s $f12, $f12, $f13 # Divide the sum of modified values by total pixels times max value
    li $v0, 2 
    syscall 

    # Open the output file for writing
    li $v0, 13 
    la $a0, outfile 
    li $a1, 1 
    li $a2, 0 
    syscall 
    move $s8, $v0 

    # Write the content of the output buffer to the file
    li $v0, 15 
    move $a0, $s8 
    la $a1, output 
    li $a2, 50000 
    syscall 

    # Close the output file
    li $v0, 16 
    move $a0, $s8 
    syscall 

# Exit the program
exit:
    li $v0, 10 
    syscall 
