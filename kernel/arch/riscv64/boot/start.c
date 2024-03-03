
#include "common/micro.h"
#include "common/vars.h"
#include "arch/plat/generic/machine.h"

ALIGN(STACK_ALIGNMENT)
char kernel_stack[PLAT_CPU_NUM][STACK_ALIGNMENT];

void start()
{
    for(;;);
}