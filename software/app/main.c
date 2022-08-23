#include "HAL/inc/sys/alt_stdio.h"
#include "HAL/inc/io.h"
#include "system.h"
#include "altera_avalon_fifo.h"
#include "altera_avalon_fifo_util.h"
#include "altera_avalon_fifo_regs.h"



void
write_tx_fifo(alt_u32 base_addr, alt_u32 ctl_addr)
{
  int j, status;
  for(j=0; j<16; j++) {
    altera_avalon_fifo_write_other_info(base_addr, ctl_addr, 0x0003); // set EOP and SOP (end/start of packet)
    status = altera_avalon_fifo_write_fifo(base_addr, ctl_addr, j);
    if(status!=0) {
      alt_printf("ERROR: fifo write error code = 0x%x\n", status);
      return;
    }
  }
}


void
read_rx_fifo(int base_addr, int ctl_addr)
{
  int num_left, data;
  num_left = altera_avalon_fifo_read_level(ctl_addr);
  alt_printf("num_left = 0x%x\n", num_left);
  while(num_left>1) {
    num_left = altera_avalon_read_fifo(base_addr, ctl_addr, &data);
    alt_printf("read %x\n",data);
  }
}


void
read_status()
{
  int status;
  status = IORD_32DIRECT(PIO_STATUS_BASE,0);
  alt_printf("status from PIO = 0x%x\n",status);
}

int
main(void)
{
  alt_putstr("Start...\n");
  //  IOWR_32DIRECT(SL3_0_BASE, 0x0c2, 0xf); // link_reinit?
  //  IOWR_32DIRECT(SL3_0_BASE, 0x0c2, 0x0); // link_reinit?
  IOWR_32DIRECT(SL3_0_BASE, 0x061, 0xffffffff); // set loop-back mode?
  //IOWR_32DIRECT(SL3_0_BASE, 0x064, 0xffffffff); // force lock of RX PLL to data?
  alt_printf("Loopback = 0x%x\n", IORD_32DIRECT(SL3_0_BASE, 0x061));
  altera_avalon_fifo_init(RX_FIFO_IN_CSR_BASE, 0, 0, 128);
  read_status();
  alt_putstr("Read anything left in the RX FIFO\n");
  read_rx_fifo(RX_FIFO_OUT_BASE, RX_FIFO_IN_CSR_BASE);
  alt_putstr("Write to FIFO\n");
  write_tx_fifo(TX_FIFO_IN_BASE, RX_FIFO_IN_CSR_BASE);
  alt_putstr("Read from FIFO\n");
  read_rx_fifo(RX_FIFO_OUT_BASE, RX_FIFO_IN_CSR_BASE);
  alt_putstr("The end\n\004");    
  return 0;
}
