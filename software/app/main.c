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
read_rx_fifo(alt_u32 base_addr, alt_u32 ctl_addr)
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


void
report_rx_data_err(alt_u32 sl3_base)
{
  int status = IORD_32DIRECT(SL3_0_BASE, 0x0d0 * 4);
  if(status==0)
    alt_printf("RX error status: no errors\n");
  else {
    alt_printf("RX error status:\n");
    if((status>> 0) & 1) alt_printf("  phy_fifo_overflow\n");
    if((status>> 1) & 1) alt_printf("  rx_block_lostlock\n");
    if((status>> 3) & 1) alt_printf("  rx_crc32err\n");
    if((status>> 4) & 1) alt_printf("  rx_pcs_err\n");
    if((status>> 5) & 1) alt_printf("  rx_align_retry_fail\n");
    if((status>> 6) & 1) alt_printf("  rx_alignment_lostlock\n");
    if((status>> 7) & 1) alt_printf("  adapt_fifo_overflow\n");
    if((status>> 8) & 1) alt_printf("  ecc_error_corrected\n");
    if((status>> 9) & 1) alt_printf("  ecc_err_fatal\n");
    if((status>>10) & 1) alt_printf("  rx_deskew_fatal\n");
    if((status>>11) & 1) alt_printf("  rx_data_err\n");
  }
}

int
main(void)
{
  alt_putstr("Start...\n");
  //int loop_back_mode = 0xffffffff; // loop-back on
  int loop_back_mode = 0; // loop-back off
  //  IOWR_32DIRECT(SL3_0_BASE, 0x0c2, 0xf); // link_reinit?
  //  IOWR_32DIRECT(SL3_0_BASE, 0x0c2, 0x0); // link_reinit?
  //IOWR_32DIRECT(SL3_0_BASE, 0x064 * 4, 0xffffffff); // force lock of RX PLL to data?
  IOWR_32DIRECT(SL3_0_BASE, 0x061 * 4, loop_back_mode); // set loop-back mode
  IOWR_32DIRECT(SL3_0_BASE, 0x090 * 4, 0xffffffff); // clear error status register
  IOWR_32DIRECT(SL3_0_BASE, 0x0d0 * 4, 0xffffffff); // clear RX Error status register

  IOWR_32DIRECT(SL3_1_BASE, 0x061 * 4, loop_back_mode); // set loop-back mode
  IOWR_32DIRECT(SL3_1_BASE, 0x090 * 4, 0xffffffff); // clear error status register
  IOWR_32DIRECT(SL3_1_BASE, 0x0d0 * 4, 0xffffffff); // clear RX Error status register
  
  alt_printf("Port B Loopback = 0x%x\n", IORD_32DIRECT(SL3_0_BASE, 0x061 * 4));
  alt_printf("Port B Error status register = 0x%x\n", IORD_32DIRECT(SL3_0_BASE, 0x090 * 4));
  alt_printf("Port C Loopback = 0x%x\n", IORD_32DIRECT(SL3_1_BASE, 0x061 * 4));
  alt_printf("Port C Error status register = 0x%x\n", IORD_32DIRECT(SL3_1_BASE, 0x090 * 4));

  altera_avalon_fifo_init(RX_FIFO_0_IN_CSR_BASE, 0, 0, 128);
  altera_avalon_fifo_init(RX_FIFO_1_IN_CSR_BASE, 0, 0, 128);

  read_status();

  alt_putstr("Port B: Read anything left in the RX FIFO\n");
  read_rx_fifo(RX_FIFO_0_OUT_BASE, RX_FIFO_0_IN_CSR_BASE);
  alt_putstr("Port C: Read anything left in the RX FIFO\n");
  read_rx_fifo(RX_FIFO_1_OUT_BASE, RX_FIFO_1_IN_CSR_BASE);

  alt_putstr("Port B: Write to FIFO\n");
  write_tx_fifo(TX_FIFO_0_IN_BASE, RX_FIFO_0_IN_CSR_BASE);
  alt_putstr("Port C: Write to FIFO\n");
  write_tx_fifo(TX_FIFO_1_IN_BASE, RX_FIFO_1_IN_CSR_BASE);

  alt_putstr("Port B: Read RX FIFO\n");
  read_rx_fifo(RX_FIFO_0_OUT_BASE, RX_FIFO_0_IN_CSR_BASE);
  alt_putstr("Port C: Read RX FIFO\n");
  read_rx_fifo(RX_FIFO_1_OUT_BASE, RX_FIFO_1_IN_CSR_BASE);

  alt_printf("Port B: TX Error status register = 0x%x\n", IORD_32DIRECT(SL3_0_BASE, 0x090 * 4));
  alt_printf("Port B: RX error status register = 0x%x\n", IORD_32DIRECT(SL3_0_BASE, 0x0d0 * 4));
  report_rx_data_err(SL3_0_BASE);

  alt_printf("Port C: TX Error status register = 0x%x\n", IORD_32DIRECT(SL3_1_BASE, 0x090 * 4));
  alt_printf("Port C: RX error status register = 0x%x\n", IORD_32DIRECT(SL3_1_BASE, 0x0d0 * 4));
  report_rx_data_err(SL3_1_BASE);

  alt_putstr("The end\n\004");    
  return 0;
}



// TODO:
// - check phy_mgmt_addr - MSB has to be "manually set" - see pg 61 of PDF doc
