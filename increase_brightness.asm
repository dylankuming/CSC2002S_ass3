.data
    filename:   .asciiz "house_64_in_ascii_lf.ppm"   # File name to open
    buffer:     .space 100000                          # Allocate buffer space for reading

.text
.globl main

main:
    # Open the file for reading
    li   $v0, 13            # system call for open file
    la   $a0, filename      # load address of filename into $a0
    li   $a1, 0             # flag for read mode
    li   $a2, 0             # mode is ignored for reading
    syscall                 # execute the system call
    move $s6, $v0           # save file descriptor in $s6

    # Read from the file
    li   $v0, 14            # system call for read from file
    move $a0, $s6           # file descriptor
    la   $a1, buffer        # address of the buffer to store read data
    li   $a2, 100000          # number of bytes to read
    syscall                 # execute the system call
    move $s7, $v0           # number of bytes actually read, save in $s7

    # Close the file
    li   $v0, 16            # system call for close file
    move $a0, $s6           # file descriptor
    syscall                 # execute the system call

    li $v0, 4
    la $a0, buffer
    syscall

exit:
    # Exit the program
    li   $v0, 10            # system call for exit
    syscall                 # execute the system call
