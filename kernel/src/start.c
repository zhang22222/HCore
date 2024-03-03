
#include "micro.h"
#include "vars.h"
#include "machine.h"
#include "sbi.h"

ALIGN(STACK_ALIGNMENT)
char kernel_stack[PLAT_CPU_NUM][STACK_ALIGNMENT];

void start()
{
    for (char *p = "hello hcore\n"; *p; p++)
    {
        console_putchar(*p);
    }
}