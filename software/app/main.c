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
  alt_u32 base_addr_tx;
  alt_u32 base_addr_rx;
  alt_u32 ctl_addr_tx;
  alt_u32 ctl_addr_rx;
  alt_u32 sl3_base_addr;
  char chan_letter;
};


int
exbit(int word, int bit_pos)
{
  return (word>>bit_pos) & 0x1;
}

void
write_tx_fifo(struct fifoDetails f, int data)
{
  int status;
  altera_avalon_fifo_write_other_info(f.base_addr_tx, f.ctl_addr_tx, 0x0003); // set EOP and SOP (end/start of packet)
  status = altera_avalon_fifo_write_fifo(f.base_addr_tx, f.ctl_addr_tx, data);
  if(status!=0)
    alt_printf("ERROR: fifo write error code = 0x%x\n", status);
}


void
write_seq_tx_fifo(struct fifoDetails f)
{
  int j;
  for(j=0; j<8; j++)
    write_tx_fifo(f, j | (((int) f.chan_letter - (int) 'A' + 1) << 12));
}


void
write_burst_tx_fifo(struct fifoDetails f, int data, int burst_len)
{
  int status, j;
  for(j=0; j<burst_len; j++) {
    int sop = j==0 ? 1 : 0;
    int eop = j==(burst_len-1) ? 1 : 0;
    altera_avalon_fifo_write_other_info(f.base_addr_tx, f.ctl_addr_tx, (eop<<1) | sop); // set EOP and SOP (end/start of packet)
    //altera_avalon_fifo_write_other_info(f.base_addr_tx, f.ctl_addr_tx, (sop<<1) | eop); // HACK test
    status = altera_avalon_fifo_write_fifo(f.base_addr_tx, f.ctl_addr_tx, data | ((j+1)<<24));
    if(status!=0)
      alt_printf("ERROR: fifo write error code = 0x%x\n", status);
  }
}


void
print_n_tabs(int n)
{
  for(; n>0; n--)
    alt_putchar('\t');
}


void
read_rx_fifo(struct fifoDetails f, int chan_index)
{
  int num_left, data, ctr;
  num_left = altera_avalon_fifo_read_level(f.ctl_addr_rx);
  alt_printf("num_left = 0x%x\n", num_left);
  ctr = 0;
  while(num_left>1) {
    num_left = altera_avalon_read_fifo(f.base_addr_rx, f.ctl_addr_rx, &data);
    print_n_tabs(chan_index*3);
    alt_printf("0x%x: RX-%c 0x%x\n",ctr,f.chan_letter,data);
    ctr++;
  }
}


void
read_many_rx_fifo(struct fifoDetails *fs, int num_chan)
{
  int num_left, data, j;
  for(j=0; j<num_chan; j++) {
    num_left = altera_avalon_fifo_read_level(fs[j].ctl_addr_rx);
    while(num_left>1) {
      num_left = altera_avalon_read_fifo(fs[j].base_addr_rx, fs[j].ctl_addr_rx, &data);
      print_n_tabs(j*3);
      alt_printf("RX-%c: 0x%x\n", fs[j].chan_letter, data);
    }
  }
}


void
write_seq_many_rx_fifo(struct fifoDetails *fs, int num_chan)
{
  int seq, j;
  for(seq=0; seq<16; seq++)
    for(j=0; j<num_chan; j++) {
      write_tx_fifo(fs[j], j | (((int) fs[j].chan_letter - (int) 'A' + 1) << 12));
      read_many_rx_fifo(fs, num_chan);
    }
}


void
read_status_pio()
{
  int status;
  status = IORD_32DIRECT(PIO_STATUS_BASE,0);
  alt_printf("status from PIO = 0x%x\n",status);
  alt_printf("TX-B link up = %x\n", exbit(status, 0));
  alt_printf("RX-B link up = %x\n", exbit(status, 1));
  alt_printf("TX-C link up = %x\n", exbit(status, 2));
  alt_printf("RX-C link up = %x\n", exbit(status, 3));
  if(((status>>8) & 0xf) == 0)
    alt_printf("H-tile clocks calibrated\n");
  else
    alt_printf("ERROR: H-tile clocks are still busy calibrating\n");
  if(((status>>4) & 0xf) == 0xf)
    alt_printf("H-tile clocks locked\n");
  else
    alt_printf("ERROR: H-tile clocks not locked\n");
}


void
report_data_error(struct fifoDetails f)
{
  int tx_status = IORD_32DIRECT(f.sl3_base_addr, 0x090 * 4);
  int rx_status = IORD_32DIRECT(f.sl3_base_addr, 0x0d0 * 4);
  int rx_aligned = IORD_32DIRECT(f.sl3_base_addr, 0x0c1 * 4);
  int device_reg = IORD_32DIRECT(f.sl3_base_addr, 0x081 * 4);
  if(tx_status==0)
    alt_printf("TX-%c: no errors\n", f.chan_letter);
  else
    alt_printf("TX-%c: TX Error status register = 0x%x\n", f.chan_letter, tx_status);
  if(rx_status==0)
    alt_printf("RX-%c: no errors\n", f.chan_letter);
  else
    {
      alt_printf("RX-%c: RX error status register = 0x%x\n", f.chan_letter, rx_status);
      if(exbit(rx_status, 0) == 1) alt_printf("  phy_fifo_overflow\n");
      if(exbit(rx_status, 1) == 1) alt_printf("  rx_block_lostlock\n");
      if(exbit(rx_status, 3) == 1) alt_printf("  rx_crc32err\n");
      if(exbit(rx_status, 4) == 1) alt_printf("  rx_pcs_err\n");
      if(exbit(rx_status, 5) == 1) alt_printf("  rx_align_retry_fail\n");
      if(exbit(rx_status, 6) == 1) alt_printf("  rx_alignment_lostlock\n");
      if(exbit(rx_status, 7) == 1) alt_printf("  adapt_fifo_overflow\n");
      if(exbit(rx_status, 8) == 1) alt_printf("  ecc_error_corrected\n");
      if(exbit(rx_status, 9) == 1) alt_printf("  ecc_err_fatal\n");
      if(exbit(rx_status,10) == 1) alt_printf("  rx_deskew_fatal\n");
      if(exbit(rx_status,11) == 1) alt_printf("  rx_data_err\n");
    }
  if(exbit(rx_aligned,9) == 0)
    alt_printf("RX-%c: ERROR: RX not aligned, LASM_misaligned_counter=0x%x, LASM_DESKEW_entered=%x  LASM_FRAME_LOCK_entered=%x\n",
	       f.chan_letter, rx_aligned>>2, exbit(rx_aligned,1), exbit(rx_aligned,0) );
  if(exbit(device_reg,27)==1)
    alt_printf("RX-%c: ERROR: CRC32 checker error\n", f.chan_letter);
  if(exbit(device_reg,25)==0)
    alt_printf("RX-%c: ERROR: Frame synchronizer rx_sync_lock=0\n", f.chan_letter);
  if(exbit(device_reg,24)==0)
    alt_printf("RX-%c: ERROR: RX FIFO rx_word_lock=0\n", f.chan_letter);
}


void
report_all_data_error(struct fifoDetails *fs, int num_chan)
{
  int j;
  for(j=0; j<num_chan; j++)
    report_data_error(fs[j]);
}


int
main(void)
{
  const int num_chan = 2;
  struct fifoDetails fs[num_chan];
  int j, d, status;

  alt_putstr("Start...\n");
  
  fs[0].base_addr_tx = TX_FIFO_0_IN_BASE;
  fs[0].base_addr_rx = RX_FIFO_0_OUT_BASE;
  fs[0].ctl_addr_tx = TX_FIFO_0_IN_CSR_BASE;
  fs[0].ctl_addr_rx = RX_FIFO_0_IN_CSR_BASE;
  fs[0].sl3_base_addr = SL3_0_BASE;
  fs[0].chan_letter = 'B';

  fs[1].base_addr_tx = TX_FIFO_1_IN_BASE;
  fs[1].base_addr_rx = RX_FIFO_1_OUT_BASE;
  fs[1].ctl_addr_tx = TX_FIFO_1_IN_CSR_BASE;
  fs[1].ctl_addr_rx = RX_FIFO_1_IN_CSR_BASE;
  fs[1].sl3_base_addr = SL3_1_BASE;
  fs[1].chan_letter = 'C';

  //int loop_back_mode = 0xffffffff; // loop-back on
  int loop_back_mode = 0; // loop-back off
  //  IOWR_32DIRECT(SL3_0_BASE, 0x0c2, 0xf); // link_reinit?
  //  IOWR_32DIRECT(SL3_0_BASE, 0x0c2, 0x0); // link_reinit?
  //IOWR_32DIRECT(SL3_0_BASE, 0x064 * 4, 0xffffffff); // force lock of RX PLL to data?

  for(j=0; j<num_chan; j++) {
    IOWR_32DIRECT(fs[j].sl3_base_addr, 0x061 * 4, loop_back_mode); // set loop-back mode
    // The following reset sequence seems to make it worse!
    //IOWR_32DIRECT(fs[j].sl3_base_addr, 0x042 * 4, 0x3); // tx and rx reset
    //IOWR_32DIRECT(fs[j].sl3_base_addr, 0x042 * 4, 0x2); // rx reset
    //usleep(100000);
    //IOWR_32DIRECT(fs[j].sl3_base_addr, 0x042 * 4, 0x0); // tx and rx reset release

    //IOWR_32DIRECT(fs[j].sl3_base_addr, 0x0c2 * 4, 0xf); // force link_reinit
    //IOWR_32DIRECT(fs[j].sl3_base_addr, 0x0c2 * 4, 0); // clear link_reinit

    // reset from pg 43 of manual:
    //IOWR_32DIRECT(fs[j].sl3_base_addr, 0x2e2 * 4, 0xf); // TX and RX analog and digital reset
    //IOWR_32DIRECT(fs[j].sl3_base_addr, 0x2e2 * 4, 0x0); // TX and RX analog and digital reset release
    
    IOWR_32DIRECT(fs[j].sl3_base_addr, 0x090 * 4, 0xffffffff); // clear error status register
    IOWR_32DIRECT(fs[j].sl3_base_addr, 0x0d0 * 4, 0xffffffff); // clear RX Error status register

    int rx_aligned = IORD_32DIRECT(fs[j].sl3_base_addr, 0x0c1 * 4);
    for(d=0; (d<100) && (exbit(rx_aligned,9)==0); d++) {
      usleep(1000);
      rx_aligned = IORD_32DIRECT(fs[j].sl3_base_addr, 0x0c1 * 4);
    }
    rx_aligned = IORD_32DIRECT(fs[j].sl3_base_addr, 0x0c1 * 4);
    if(exbit(rx_aligned,9)==0)
      alt_printf("ERROR: timed out waiting for rx_aligned on channel %c\n",fs[j].chan_letter);

    alt_printf("Port %c Loopback = 0x%x\n", fs[j].chan_letter, IORD_32DIRECT(fs[j].sl3_base_addr, 0x061 * 4));
    alt_printf("Port %c Error status register = 0x%x\n", fs[j].chan_letter, IORD_32DIRECT(fs[j].sl3_base_addr, 0x090 * 4));
  }

  report_all_data_error(fs, num_chan);
  read_status_pio();

  for(j=0; j<num_chan; j++) {
    // altera_avalon_fifo_init(alt_u32 address, alt_u32 ienable, alt_u32 emptymark, alt_u32 fullmark)
    status = altera_avalon_fifo_init(fs[j].ctl_addr_rx, 0, 1, 1000);
    if(status!=0)
      alt_printf("RX-%c: ERROR: altera_avalong_fifo_init returned 0x%x\n", fs[j].chan_letter, status);
    alt_printf("RX-%c: Read anything left in the RX FIFO\n", fs[j].chan_letter);
    read_rx_fifo(fs[j], j);
  }

  //d = 200/(256/32);
  /*
  d=2;
  for(j=0; j<num_chan; j++) {
    alt_printf("Write burst of 0x%x to channel %c\n", d, fs[j].chan_letter);
    write_burst_tx_fifo(fs[j], 0x1234, d);
    read_many_rx_fifo(fs, num_chan);
  }
  */
  /*
  for(d=0x10; d<0x20; d++) {
    for(j=0; j<num_chan; j++) {
      int data = d | ((j+1)<<16);
      alt_printf("TX-%c: 0x%x\t\t", fs[j].chan_letter, data);
      write_tx_fifo(fs[j], data);
    }
    alt_putchar('\n');
    read_many_rx_fifo(fs, num_chan);
  }
  */

  
  for(j=0; j<num_chan; j++) {
    alt_printf("Port %c: Write to FIFO\n", fs[j].chan_letter);
    write_seq_tx_fifo(fs[j]);
  }

  for(j=0; j<num_chan; j++) {
    alt_printf("Port %c: Read RX FIFO\n", fs[j].chan_letter);
    read_rx_fifo(fs[j], j);
  }

  report_all_data_error(fs, num_chan);
  
  read_status_pio();
  
  alt_putstr("The end\n\004");    
  return 0;
}



// TODO:
// - check phy_mgmt_addr - MSB has to be "manually set" - see pg 61 of PDF doc
