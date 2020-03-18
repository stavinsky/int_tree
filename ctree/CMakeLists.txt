cmake_minimum_required(VERSION 3.5)

project(int_tree LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
add_library(ctreelib SHARED ctree.cpp)
add_executable(ctree main.cpp ctree)
