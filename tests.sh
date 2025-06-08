#!/bin/bash

echo "TEST 1"
./cimples_compiler < tests/test1.cimples

echo -e "\nTEST 2"
./cimples_compiler < tests/test2.cimples

echo -e "\nTEST 3"
./cimples_compiler < tests/test3.cimples

echo -e "\nTEST 4"
./cimples_compiler < tests/test4.cimples

echo -e "\nTEST 5"
./cimples_compiler < tests/test5.cimples