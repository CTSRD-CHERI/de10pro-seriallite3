#include "HAL/inc/sys/alt_stdio.h"
#include "HAL/inc/io.h"
#include "system.h"
#include "altera_avalon_fifo.h"
#include "altera_avalon_fifo_util.h"
#include "altera_avalon_fifo_regs.h"
#include "unistd.h"

/*****************************************************************************
 * Notes on aligning lanes
 * L/H-tile manual - page 225 shows a flow chart
 *   - rx_fifo_rd_en
 *   - rx_fifo_align_clr
 *****************************************************************************/

struct fifoDetails {
  alt_u32 base_addr;
  char chan_letter;
};


int
exbit(int word, int bit_pos)
{
  return (word>>bit_pos) & 0x1;
}


void
print_n_tabs(int n)
{
  for(; n>0; n--)
    alt_putchar('\t');
}


int
status_fifo(struct fifoDetails f)
{
  return IORD_32DIRECT(f.base_addr,4);
}


int
status_rx_fifo_notEmpty(struct fifoDetails f)
{
  return exbit(status_fifo(f),1);
}


void
write_tx_fifo(struct fifoDetails f, int data)
{
  // TODO: check FIFO isn't full!!!
  IOWR_32DIRECT(f.base_addr, 0, data);
}


void
read_rx_fifo(struct fifoDetails f, int chan_index, int silent)
{
  int data, ctr;
  ctr = 0;
  while(status_rx_fifo_notEmpty(f)) {
    data = IORD_32DIRECT(f.base_addr,0);
    print_n_tabs(chan_index*3);
    if(silent==0)
      alt_printf("0x%x: RX-%c 0x%x\n",ctr,f.chan_letter,data);
    ctr++;
  }
}


int
main(void)
{
  const int num_chan = 1;
  struct fifoDetails fs[num_chan];
  int phy_mgmt_addr_offset = 1<<15; // word address offset to access physical management (PMA) addresses; MSB of address bits
  int j, d, e, status;

  alt_putstr("Start...\n");
  
  fs[0].base_addr = MKBERT_INSTANCE_0_BASE;
  fs[0].chan_letter = 'A';

  for(j=0; j<10; j++) {
    write_tx_fifo(fs[0], (1<<16) | (j+1));
    read_rx_fifo(fs[0], 0, 0);
  }
  
  alt_putstr("The end\n\n");
  usleep(1000000);
  alt_putstr("\004");
  return 0;
}



// TODO:
// - check phy_mgmt_addr - MSB has to be "manually set" - see pg 61 of PDF doc
