### README

#### Description:
This README provides detailed instructions on how to run the provided MIPS assembly programs. The two programs perform different operations on PPM image files: `increase_brightness.asm` increases the brightness of a color PPM image, and `greyscale.asm` converts a color PPM image to greyscale.

#### Requirements:
- The programs are intended to be run on the QTSpim simulator.
- The input images should be in PPM format.

#### Instructions:

### 1. **Setting up the File Paths**
Before running the programs, you need to set the file paths of the input and output images directly in the assembly code. The paths should be absolute.

  **For `increase_brightness.asm`:**
   - Navigate to the `.data` section, located at the top of the code.
   - Edit the `file_in` line to direct it to the location of your input PPM file.
     ```mips
     file_in: .asciiz "ABSOLUTE_PATH_TO_YOUR_INPUT_FILE"
     ```
   - Adjust the `file_out` line to indicate the desired location for saving the new image.
     ```mips
     file_out: .asciiz "ABSOLUTE_PATH_TO_YOUR_OUTPUT_FILE"
     ```

   **For `greyscale.asm`:**
   - The modification steps mirror those outlined above. Simply adjust the `file_in` and `file_out` paths located in the `.data` section.


   **For `greyscale.asm`:**
   - The steps are the same as above; just modify the `file_in` and `file_out` paths in the `.data` section.

### 2. **Running the Programs**
   **Using QTSpim:**
   - Open QTSpim.
   - Load the assembly file (`File` > `Reinitialize and Load File`).
   - Navigate to your directory and select the appropriate `.asm` file.
   - Press the "Run" button to execute the program.

### 3. **Viewing the Results**
   - Open the output file specified in the `outfile` line with an image editor/viewer to see the changes made by the program.
   - For `increase_brightness.asm`, the brightness of the image will be increased.
   - For `greyscale.asm`, the image will be converted to greyscale.

#### Additional Notes:
- Make sure the input image is in the correct format (PPM) and the file paths are accessible and correct.
- Ensure QTSpim has the necessary permissions to read and write files if required.

#### Troubleshooting:
- If the image does not appear as expected, ensure that the file path and image format are correct.
- Check the QTSpim console for any error messages or notifications.

