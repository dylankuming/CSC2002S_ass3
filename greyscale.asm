.data
filename:   .asciiz"C:/Users/dylan/OneDrive - University of Cape Town/UNIVERSITY FILES/Third Year/Semester 2/CSC2002S/Assignment 3/Images/tree_64_in_ascii_lf.ppm"  # Input file path
outfile:    .asciiz"C:/Users/dylan/OneDrive - University of Cape Town/UNIVERSITY FILES/Third Year/Semester 2/CSC2002S/Assignment 3/greyscale.ppm"  # Output file path
buffer:     .space 50000  # Buffer for input file
output:     .space 50000  # Buffer for output file
reversed_value: .space 4  # Buffer for reversed values

.text
.globl main

main:
    # Open the file for reading
    li $v0, 13  # System call for open file
    la $a0, filename  # Address of file name
    li $a1, 0  # File mode (0 = read)
    li $a2, 0  # Permissions (not needed for read)
    syscall  # Make system call
    move $s6, $v0   # Store file descriptor

    # Read the file into the buffer
    li $v0, 14  # System call for read from file
    move $a0, $s6  # File descriptor
    la $a1, buffer  # Address of buffer
    li $a2, 49999  # Number of bytes to read
    syscall  # Make system call
    move $s7, $v0   # Store number of characters read

    # Close the file
    li $v0, 16  # System call for close file
    move $a0, $s6  # File descriptor
    syscall  # Make system call

    # Initialize registers for loop processing
    li $t0, 3   # Position in buffer
    li $t1, 0   # Newline character counter
    li $t4, 0   # Position in output buffer
    li $t7, 0   # Position in reversed_value buffer
    li $s1, 0   # Sum of RGB values
    li $t5, 0   # Counter for every 3 lines

    # Manually write "P2\n" to the output to change file type to grayscale
    li $t2, 80  # ASCII value for 'P'
    sb $t2, output($t4)  # Store 'P' in output
    addi $t4, 1  # Increment position in output buffer
    li $t2, 50  # ASCII value for '2'
    sb $t2, output($t4)  # Store '2' in output
    addi $t4, 1  # Increment position in output buffer
    li $t2, 10  # ASCII value for newline character
    sb $t2, output($t4)  # Store newline in output
    addi $t4, 1  # Increment position in output buffer

# Loop through file info until the pixel values are reached
file_info_loop:
    beq $t1, 3, pixel_value_loop    # Skip to pixel values after 3 new lines
    lb $t2, buffer($t0)  # Load byte from buffer
    sb $t2, output($t4)  # Store byte in output buffer
    addi $t0, 1  # Increment buffer position
    addi $t4, 1  # Increment output buffer position
    beq $t2, 10, lf  # If newline, increment newline counter
    j file_info_loop  # Otherwise, continue loop

# Increment newline counter and continue loop
lf:
    addi $t1, 1  # Increment newline counter
    j file_info_loop  

# Begin processing pixel values for grayscale conversion
pixel_value_loop:
    li $s0, 0   # Reset current value holder

# Convert ASCII characters to integer pixel value
string_to_int:
    lb $t2, buffer($t0)  # Load byte from buffer
    addi $t0, $t0, 1  # Increment buffer position
    beq $t2, $zero, write_file  # If null terminator, begin writing file
    beq $t2, 10, plus  # If newline, process accumulated value
    
    # Compute integer value from ASCII characters
    sub $t2, $t2, 48  # Convert ASCII to integer
    mul $s0, $s0, 10  # Shift current value left by one digit
    add $s0, $s0, $t2  # Add new digit to current value

    j string_to_int  # Continue loop

# Process accumulated RGB values for grayscale conversion
plus:
    add $s1, $s1, $s0  # Add current value to sum
    addi $t5, 1  # Increment line counter
    beq $t5, 3, average  # If 3 lines processed, calculate average
    j pixel_value_loop  # Otherwise, continue loop

# Calculate the average of the 3 RGB values for grayscale
average:
    li $s6, 3  # Divider for averaging
    div $s1, $s6  # Divide sum by 3
    mflo $s0  # Load quotient as grayscale value
    li $s1, 0  # Reset sum
    li $t7, 0  # Reset reversed_value position
    li $t5, 10  # Reset line counter

# Convert integer grayscale value to ASCII string
int_to_string:
    div $s0, $t5  # Divide grayscale value by 10 to separate digits
    mflo $s0  # Load quotient
    mfhi $t3  # Load remainder
    addi $t3, 48  # Convert remainder to ASCII
    sb $t3, reversed_value($t7)  # Store ASCII character in reversed_value buffer
    addi $t7, 1  # Increment reversed_value position
    beq $s0, $zero, startReverse  # If quotient is 0, reverse the string
    j int_to_string  # Otherwise, continue loop

# Reverse the ASCII string to get the correct order
startReverse:
    li $t6, 2  # Set position in reversed_value buffer

reverse_string:
    lb $t2, reversed_value($t6)  # Load ASCII character from reversed_value
    sb $t2, output($t4)  # Store ASCII character in output buffer
    addi $t4, 1  # Increment output buffer position
    beq $t6, $zero, newLine  # If all characters processed, add newline to output
    sub $t6, 1  # Otherwise, decrement position in reversed_value
    j reverse_string  # Continue loop

# Add newline character to output buffer and continue loop
newLine:
    li $t5, 10  # ASCII value for newline
    sb $t5, output($t4)  # Store newline in output buffer
    addi $t4, 1  # Increment output buffer position
    li $t5, 0  # Reset line counter
    j pixel_value_loop  # Continue pixel value processing loop

# Write the grayscale data to the output file
write_file:
    li $v0, 4  # System call for print string
    la $a0, outfile  # Address of output file path string
    syscall  # Make system call

    # Open the output file for writing
    li $v0, 13  # System call for open file
    la $a0, outfile  # Address of output file name
    li $a1, 1  # File mode (1 = write)
    li $a2, 0  # Permissions (not needed for write)
    syscall  # Make system call
    move $s8, $v0  # Store file descriptor

    # Write the content of the output buffer to the file
    li $v0, 15  # System call for write to file
    move $a0, $s8  # File descriptor
    la $a1, output  # Address of output buffer
    li $a2, 50000  # Number of bytes to write
    syscall  # Make system call

    # Close the output file
    li $v0, 16  # System call for close file
    move $a0, $s8  # File descriptor
    syscall  # Make system call

# Exit the program
exit:
    li $v0, 10  # System call for exit
    syscall  # Make system call
