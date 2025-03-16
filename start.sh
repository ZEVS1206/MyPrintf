nasm -f elf64 $1.asm -o $1.o
ld -m elf_x86_64 -s -o $1 $1.o
./$1
