#include <stdio.h>

extern "C" int my_printf(const char *format, ...);


int main()
{
    int number = 12;
    my_printf("Hello, %b\n", number);
    return 0;
}