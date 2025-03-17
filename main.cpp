#include <stdio.h>

extern "C" int my_printf(const char *format, ...);


int main()
{
    int number = -1100;
    my_printf("Hello, %d %d %s %c\n", number, 243, "WORLD", '!');
    return 0;
}