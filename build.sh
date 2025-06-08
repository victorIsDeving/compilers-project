#!/bin/bash

bison -d parser.y -o parser.tab.c || { echo "Bison failed"; exit 1; }
flex lexer.l || { echo "Flex failed"; exit 1; }
gcc parser.tab.c lex.yy.c -Wall -g -O0 -o cimples_compiler|| { echo "Compilation failed"; exit 1; }
