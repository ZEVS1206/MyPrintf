#include <stdio.h>

extern "C" int my_printf(const char *format, ...);


int main()
{
    const char * str = "World!";
    int number = 15;
    //my_printf("%d\n", 0b0101);
    // if (my_printf("Hello, %c %s %h %o %b\n", str[0], str, 0xa6, number, number) == 0xDED)
    // {
    //     my_printf("I am DED!\n");
    // }
    //my_printf("%d %d %d %d %d %d %d %d\n", 1, 2, 3, 4, 5, 6, 7, 8);
    //my_printf("%d %d %d %d %c %c %c %c %h %h %o %o %b %b\n", 1, 2, 3, 4, 'a', 'b', 'c', 'd', 0xa6, 0x22, 0011, 0022, 0b1010, 0b0101);
    for (int i = 0; i < 12; i++)
    {
        my_printf("%d\n", i);
    }
    return 0;
}