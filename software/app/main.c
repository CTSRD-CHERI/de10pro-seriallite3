#include "HAL/inc/sys/alt_stdio.h"
#include "HAL/inc/io.h"
#include "system.h"
//#include "altera_avalon_fifo.h"
//#include "altera_avalon_fifo_util.h"
//#include "altera_avalon_fifo_regs.h"
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


void
print_link_status()
{
  int base = PIO_STATUS_BASE;
  int status;
  status = IORD_32DIRECT(base, 0);
  /* From DE10pro:
       assign status[10:0] = link_status_A;
       assign status[11] = | cal_busy;
       assign status[15:12] = {htile_fast_lock_D1, htile_fast_lock_D0, htile_fast_lock_A1, htile_fast_lock_A0};

     Where link_status_A is defined in SerialLite3.bsv:
       typedef struct {
         Bit #(5) error_rx;
	 Bit #(4) error_tx;
	 Bool link_up_tx;
	 Bool link_up_rx;
       } SerialLite3_LinkStatus deriving (Bits);
  */
  alt_printf("Chan A: Link up: tx=%x,rx=%x;  error_tx=0x%x,  error_rx=0x%x,  calibration_busy=%x,  htile_lock (4-bits)=0x%x\n",
	     exbit(status,0),
	     exbit(status,1),
	     (status>>2) & 0xf,
	     (status>>6) & 0x1f,
	     exbit(status,11),
	     (status>>12) & 0xf);
  status = status>>16;
  alt_printf("Chan D: Link up: tx=%x,rx=%x;  error_tx=0x%x,  error_rx=0x%x,  calibration_busy=%x,  htile_lock (4-bits)=0x%x\n",
	     exbit(status,0),
	     exbit(status,1),
	     (status>>2) & 0xf,
	     (status>>6) & 0x1f,
	     exbit(status,11),
	     (status>>12) & 0xf);
}


int
check_testreg(struct fifoDetails f)
{
  int j,t,d;
  int pass=1;
  int testreg_addr_offset=0x10*8;
  for(j=0; j<10; j++) {
    t=j;
    IOWR_32DIRECT(f.base_addr, testreg_addr_offset, ~t);
    d = IORD_32DIRECT(f.base_addr, testreg_addr_offset);
    if(d!=t) {
      alt_printf("Chan %c: testreg expecting 0x%x but read 0x%x - fail\n", f.chan_letter, t, d);
      pass=0;
    }
  }
  return pass;
}


int
status_fifo(struct fifoDetails f, int fifonum)
{
  int status;
  status = IORD_32DIRECT(f.base_addr,8*(1+2*fifonum));
  //  alt_printf("DEBUG: Chan %c: status=0x%x\n", f.chan_letter, status);
  return status;
}


int
status_rx_fifo_notEmpty(struct fifoDetails f, int fifonum)
{
  return exbit(status_fifo(f, fifonum),1);
}


int
status_tx_fifo_notFull(struct fifoDetails f, int fifonum)
{
  return exbit(status_fifo(f, fifonum),0);
}


void
write_tx_fifo(struct fifoDetails f, int fifonum, int data)
{
  // TODO: check FIFO isn't full!!!
  IOWR_32DIRECT(f.base_addr, 8*2*fifonum, data);
}


void
read_rx_fifo(struct fifoDetails f, int fifonum, int chan_index, int silent)
{
  int data, ctr;
  ctr = 0;
  while(status_rx_fifo_notEmpty(f, fifonum)) {
    data = IORD_32DIRECT(f.base_addr,8*2*fifonum);
    print_n_tabs(chan_index*3);
    if(silent==0)
      alt_printf("0x%x: RX-%c 0x%x\n",ctr,f.chan_letter,data);
    ctr++;
  }
}


int
main(void)
{
  const int num_chan = 2;
  const int fifonum = 0; // 0=serial-link, 1=loopback
  struct fifoDetails fs[num_chan];
  //int phy_mgmt_addr_offset = 1<<15; // word address offset to access physical management (PMA) addresses; MSB of address bits
  //int j, d, e, status;
  int j, chan;

  alt_putstr("Start...\n");
  
  // Check testreg to ensure we're probably communicating with a BERT
  fs[0].base_addr = MKBERT_INSTANCE_0_BASE;
  fs[0].chan_letter = 'A';
  fs[1].base_addr = MKBERT_INSTANCE_1_BASE;
  fs[1].chan_letter = 'D';
  for(j=0; j<num_chan; j++) {
    alt_printf("BERT 0x%x on Chan %c at base address 0x%x\n",
	       j,
	       fs[j].chan_letter,
	       fs[j].base_addr);
    check_testreg(fs[j]);
  }

  print_link_status();

  alt_printf("Write-read tests on the channels\n");
  for(j=0; j<10; j++)
      for(chan=0; chan<num_chan; chan++) {
	write_tx_fifo(fs[chan], fifonum, (1<<16) | (j+1));
	read_rx_fifo(fs[chan], fifonum, 0, 0);
      }
  
  for(j=0; j<5; j++)
      for(chan=0; chan<num_chan; chan++)
	read_rx_fifo(fs[chan], fifonum, 0, 0);

  chan=0;
  for(j=0; j<100; j++)
    if(status_tx_fifo_notFull(fs[chan], fifonum))
      write_tx_fifo(fs[chan], fifonum, (1<<16) | (j+1));
    else
      alt_printf("Managed to fill up the tx fifo.  j=0x%x\n",j);

  alt_printf("Reading all data from the FIFOs\n");
  for(j=0; j<200; j++)
    for(chan=0; chan<num_chan; chan++)
      read_rx_fifo(fs[chan], fifonum, 0, 0);

  alt_putstr("The end\n\n");
  usleep(1000000);

  alt_putstr("\004");
  return 0;
}



// TODO:
// - check phy_mgmt_addr - MSB has to be "manually set" - see pg 61 of PDF doc
