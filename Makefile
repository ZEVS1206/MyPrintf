
CC = g++
ASM = nasm

CXXFLAGS = -Wall -Wextra -std=c++11 -O2

ASMFLAGS = -f elf64

LDFLAGS = -no-pie

TARGET = program

SRC_CPP = main.cpp
SRC_ASM = my_printf.asm

OBJ_CPP = $(SRC_CPP:.cpp=.o)
OBJ_ASM = $(SRC_ASM:.asm=.o)

all: $(TARGET)


$(TARGET): $(OBJ_CPP) $(OBJ_ASM)
	$(CC) $(OBJ_CPP) $(OBJ_ASM) -o $(TARGET) $(LDFLAGS)


$(OBJ_CPP): $(SRC_CPP)
	$(CC) $(CXXFLAGS) -c $(SRC_CPP) -o $(OBJ_CPP)


$(OBJ_ASM): $(SRC_ASM)
	$(ASM) $(ASMFLAGS) $(SRC_ASM) -o $(OBJ_ASM)


clean:
	rm -f $(OBJ_CPP) $(OBJ_ASM) $(TARGET)
run:
	./$(TARGET)


.PHONY: all clean