# DE10Pro/Stratix 10 Test of Serial Lite III

## Notes

* Main system under test is a Platform Designer project soc.qsys


## Software for Nios-V processor

* [Nios-V quick start guide from Intel](https://usermanual.wiki/m/464277d99f971805ff972a1bd8eef56602928f237221631fb7126fa954e03d0a.pdf)
* Board support package (BSP) can be generated within Platform Designer: File->New BSP
  * I put the bsp in: software/bsp/settings.bsp
* From the command-line in software/bsp generate the BSP files:
```
niosv-bsp -g settings.bsp
```
* Simple top-level C file put in app/main.c:
```
#include "HAL/inc/sys/alt_stdio.h"

int
main(void)
{
  alt_putstr("Hello World!\n");
  return 0;
}
```
* generate the CMakeLists.txt:
```
niosv-app --dir=./ --bsp-dir=../bsp --srcs=main.c --elf-name=main.elf
```
* build using:
```
make
```
* start a jtag terminal, e.g. in a new xterm window:
```
xterm -e juart-terminal &
```
* download and run the code:
```
niosv-download -g main.elf
```


## Tuning Serial Links

Analog parameters for serial links can be tuned using System Console.  Please see the demonstration video below:

[![Link Tuning Video](https://img.youtube.com/vi/y_UbtNqbIaM/default.jpg)](https://youtu.be/y_UbtNqbIaM)