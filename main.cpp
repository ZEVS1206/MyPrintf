#include <stdio.h>

extern "C" int my_printf(const char *format, ...);


int main()
{
    const char * str = "World!";
    int number = 12;
    my_printf("Hello, %s %b\n", str, number);
    return 0;
}