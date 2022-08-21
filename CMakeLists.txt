cmake_minimum_required(VERSION 3.22.1)

project(BrainFuck C)

set(SOURCES src/main.c src/main.c)

add_executable(compiler ${SOURCES})