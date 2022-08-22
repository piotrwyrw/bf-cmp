cmake_minimum_required(VERSION 3.22.1)
project(bfcmp VERSION 22.08.2022 LANGUAGES C)

set(SOURCES src/main.c src/main.c)
add_executable(compiler ${SOURCES})