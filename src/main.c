//
// Created by tux on 21.08.22.
//

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#define FILENAME "program.asm"
#define PREAMBLE "preamble.asm"

#define CAN_BE_OPTIMIZED_OP(c) \
        ((c == '>' || c == '<' || c == '+' || c == '-'))

typedef unsigned char boolean;

#define true 1
#define false 0

FILE *asm_f = NULL;
FILE *pre_f = NULL;

// Close all open file descriptors
void cl_files() {
    if (asm_f)
        fclose(asm_f);
    if (pre_f)
        fclose(pre_f);
}

// Open required files, copy preamble to target file
void ini_files() {
    asm_f = fopen(FILENAME, "w");
    if (!asm_f) {
        printf("Could not open target assembly file: %s\n", FILENAME);
        cl_files();
        exit(0);
    }

    // Copy the preamble
    pre_f = fopen(PREAMBLE, "r");
    if (!pre_f) {
        printf("Could not open preamble file: %s.\n", PREAMBLE);
        cl_files();
        exit(0);
    }

    int c = 0;
    while ((c = getc(pre_f)) != EOF) {
        fwrite(&c, 1, 1, asm_f);
    }

    fclose(pre_f);
    pre_f = NULL;
}

// Count uninterrupted repeating series of characters
unsigned int ct_series(const unsigned char *s, unsigned int pos) {
    unsigned int rep = 1;
    unsigned char c = s[pos];
    for (unsigned int i = pos + 1; i < strlen(s); i ++) {
        if (s[i] == c)
            rep ++;
        else
            break;
    }
    return rep;
}

int main(void) {
    // Initialize the required files
    ini_files();

    // Source code. Just a temporary solution. We'll probably read it from a file provided by the user later.
    const unsigned char *prog = ">++++++++[<+++++++++>-]<.>++++[<+++++++>-]<+.+++++++..+++.>>++++++[<+++++++>-]<+"
                                "+.------------.>++++++[<+++++++++>-]<+.<.+++.------.--------.>>>++++[<++++++++>-"
                                "]<+.";

    unsigned int pos = 0;           // Current op position in prog array
    unsigned int loop_no = 0;       // Current loop number
    unsigned int max_loop_no = 0;   // Highest loop number yet
    unsigned int base_loop_no = 0;  // Holds the lowest loop number

    fprintf(asm_f, "\t\t;; Code gen output starts here\n");

    // Do the compilation
    while (true) {

        // Current bf operator
        char op = prog[pos];

        // Series length
        unsigned int ct = ct_series(prog, pos);

        // Exclude loops from the series optimization (for safety, for now ...)
        pos += (CAN_BE_OPTIMIZED_OP(op)) ? ct : 1;

        if (pos > strlen(prog)) {
            break;
        }

        switch (op) {

            case '+':
                fprintf(asm_f, "\t\tmov cl, [mem + rbx]\n");
                if (ct > 1)
                    fprintf(asm_f, "\t\tadd cl, %d\n", ct);
                else
                    fprintf(asm_f, "\t\tinc cl\n");
                fprintf(asm_f, "\t\tmov [mem + rbx], cl\n");
                break;

            case '-':
                fprintf(asm_f, "\t\tmov cl, [mem + rbx]\n");
                if (ct > 1)
                    fprintf(asm_f, "\t\tsub cl, %d\n", ct);
                else
                    fprintf(asm_f, "\t\tdec cl\n");
                fprintf(asm_f, "\t\tmov [mem + rbx], cl\n");
                break;

            case '>':
                if (ct > 1)
                    fprintf(asm_f, "\t\tadd rbx, %d\n", ct);
                else
                    fprintf(asm_f, "\t\tinc rbx\n");
                break;

            case '<':
                fprintf(asm_f, "\t\tdec rbx\n");
                break;

            case '.':
                fprintf(asm_f, "\t\tmov cl, [mem + rbx]\n");
                fprintf(asm_f, "\t\tmov [char], cl\n");
                for (unsigned int i = 0; i < ct; i ++)
                    fprintf(asm_f, "\t\tcall write\n");
                break;

            case '[':
                fprintf(asm_f, "\tL%d:\n", loop_no);

                loop_no ++;

                // Always update the max loop number (if necessary)
                if (loop_no > max_loop_no) {
                    max_loop_no = loop_no;
                }

                break;

            case ']':
                fprintf(asm_f, "\t\tmov cl, [mem + rbx]\n");
                fprintf(asm_f, "\t\tcmp cl, 0\n");
                fprintf(asm_f, "\t\tjnz L%d\n", loop_no - 1);

                loop_no --;

                // If we're back at our base 'offset' number, set the offset and loop id offset.
                if (loop_no == base_loop_no) {
                    loop_no = max_loop_no;
                    base_loop_no = max_loop_no;
                }
                break;

            default:
                break;
        }
    }

    // Make sure we exit the program to avoid segmentation faults (or other memory-related errors)
    fprintf(asm_f, "\t\tjmp exit");

    // Close the files
    cl_files();

    return 0;
}