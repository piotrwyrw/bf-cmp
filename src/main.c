//
// Created by Piotr Wyrwas on 21.08.22.
//

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#define CAN_BE_OPTIMIZED_OP(c) \
        ((c == '>' || c == '<' || c == '+' || c == '-' || c == '.'))

#define IS_BRAINFUCK_OP(c) \
        (CAN_BE_OPTIMIZED_OP(c) || c == '[' || c == ']')

#define RESOLVE_PARAMETER(lng, shrt, target, strict)                                    \
        if (!strcmp(opt, lng) || !strcmp(opt, shrt)) {                          \
            if (strlen(target) != 0 && strict) {                                          \
                printf("The option %s (%s) is already set.\n", lng, shrt);      \
                exit(0);                                                        \
            }                                                                   \
            strcpy(target, val);                                                \
            return true;                                                        \
        }

#define VALIDATE(str, msg)          \
        if (strlen(str) == 0) {     \
            printf(msg);            \
            exit(0);                \
        }

#define emit(...) \
        fprintf(out_f, ##__VA_ARGS__);

typedef unsigned char boolean;

#define true 1
#define false 0

FILE *src_f = NULL;
FILE *out_f = NULL;
FILE *pre_f = NULL;

unsigned char out_file[100] = {0};
unsigned char pre_file[100] = {0};
unsigned char src_file[100] = {0};
unsigned char prj_name[100] = "Empty project";
unsigned char prog[200] = {0};

// Close all open file descriptors
void cl_files() {
    if (out_f)
        fclose(out_f);
    if (pre_f)
        fclose(pre_f);
    if (src_f)
        fclose(src_f);
}

// Open required files, copy preamble to target file, load source code
void ini_files() {
    out_f = fopen(out_file, "w");
    if (!out_f) {
        printf("Could not open output file: %s\n", out_file);
        cl_files();
        exit(0);
    }

    int c = 0;
    unsigned int len = 0;

    // Load the brainfuck source code
    src_f = fopen(src_file, "r");
    if (!src_f) {
        printf("Could not open source file: %s\n", src_file);
        cl_files();
        exit(0);
    }

    while ((c = getc(src_f)) != EOF) {
        if (!IS_BRAINFUCK_OP(c))
            continue;
        prog[len] = c;
        len ++;
    }

    fclose(src_f);
    src_f = NULL;

    // Copy the preamble
    pre_f = fopen(pre_file, "r");
    if (!pre_f) {
        printf("Could not open preamble file: %s.\n", pre_file);
        cl_files();
        exit(0);
    }

    while ((c = getc(pre_f)) != EOF) {
        fwrite(&c, 1, 1, out_f);
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

void usage(char *a) {
    printf(
            "Usage:\n"
            "  %s --source|-s source_file --output|-o output_file --preamble|-p preamble_file [--name|-n project_name]\n", a);
}

boolean resolv(char *opt, char *val) {
    RESOLVE_PARAMETER("--source", "-s", src_file, true);
    RESOLVE_PARAMETER("--output", "-o", out_file, true);
    RESOLVE_PARAMETER("--preamble", "-p", pre_file, true);
    RESOLVE_PARAMETER("--name", "-n", prj_name, false);
    return false;
}

void validate_params() {
    VALIDATE(src_file, "Source file has to be set.\n");
    VALIDATE(out_file, "Output file has to be set.\n");
    VALIDATE(pre_file, "Preamble fie has to be set.\n");
}

int main(int argc, char **argv) {

    int real_argc = argc - 1;

    if (real_argc <= 0) {
        usage(argv[0]);
        return -1;
    }

    // Parse command line arguments
    char option[100]    = {0};
    char value[200]     = {0};

    for (int i = 1; i < argc; i ++) {
        strcpy(option, argv[i]);
        if (i + 1 >= argc) {
            printf("Expected value for option: %s", option);
            return 0;
        }
        i ++;
        strcpy(value, argv[i]);
        if (!resolv(option, value)) {
            printf("Could not resolve option: %s", option);
            return 0;
        }
    }

    validate_params();

    printf("Getting things ready ..\n");

    // Initialize the required files
    ini_files();

    unsigned int pos = 0;           // Current op position in prog array
    unsigned int loop_no = 0;       // Current loop number
    unsigned int max_loop_no = 0;   // Highest loop number yet
    unsigned int base_loop_no = 0;  // Holds the lowest loop number

    emit( "\tjmp Execute\n\n");
    emit( "\tPROGRAM: db \"%s\", 10, 0\n\n", prj_name);
    emit( "Execute:\n");
    emit( "\tmov si, PROGRAM\n");
    emit( "\tcall Print\n\n");
    emit( "\t;; Project name: %s\n", prj_name);
    emit( "\t;; Source code:\n\t;; %s\n", prog);
    emit( "\t;; Code gen output starts here\n\n");

    printf("Compiling ..\n");

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
                emit( "\tmov cl, [CELLS + bx]\n");
                if (ct > 1) {
                    emit("\tadd cl, %d\n", ct);
                } else {
                    emit("\tinc cl\n");
                }
                emit( "\tmov [CELLS + bx], cl\n");
                break;

            case '-':
                emit( "\tmov cl, [CELLS + bx]\n");
                if (ct > 1) {
                    emit("\tsub cl, %d\n", ct);
                } else {
                    emit("\tdec cl\n");
                }
                emit( "\tmov [CELLS + bx], cl\n");
                break;

            case '>':
                if (ct > 1) {
                    emit("\tadd bx, %d\n", ct);
                } else {
                    emit("\tinc bx\n");
                }
                break;

            case '<':
                emit( "\tdec bx\n");
                break;

            case '.':
                emit( "\tmov cl, [CELLS + bx]\n");
                emit( "\tmov [CHAR], cl\n");
                emit( "\tpusha\n");
                for (unsigned int i = 0; i < ct; i ++)
                    emit( "\tcall Output\n");
                emit( "\tpopa\n");
                break;

            case ',':
                // To be implemented
                break;

            case '[':
                emit( "L%d:\n", loop_no);

                loop_no ++;

                // Always update the max loop number (if necessary)
                if (loop_no > max_loop_no) {
                    max_loop_no = loop_no;
                }

                break;

            case ']':
                emit( "\tmov cl, [CELLS + bx]\n");
                emit( "\tcmp cl, 0\n");
                emit( "\tjnz L%d\n", loop_no - 1);

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

    // Enter an infinite loop
    emit( "\n\t;; End of generated assembly\n");
    emit( "\tjmp $");

    printf("Finalizing ..\n");

    // Close the files
    cl_files();

    printf("~~ Compilation of \"%s\" successful. Emitted assembly into \"%s\". Used preamble: \"%s\" ~~\n", src_file, out_file, pre_file);
    printf("Done.\n");

    return 0;
}