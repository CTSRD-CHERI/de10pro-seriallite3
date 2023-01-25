#include <stdbool.h>
#include "HAL/inc/sys/alt_stdio.h"
//#include <stdio.h>
#include <fcntl.h>
#include "HAL/inc/io.h"
#include "system.h"
#include "unistd.h"

/*****************************************************************************
 * Notes on aligning lanes
 * L/H-tile manual - page 225 shows a flow chart
 *   - rx_fifo_rd_en
 *   - rx_fifo_align_clr
 *****************************************************************************/

const int word_offset=8;


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
print_link_status_old()
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
  int testreg_addr_offset=0x10*word_offset;
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
  status = IORD_32DIRECT(f.base_addr,word_offset*(1+2*fifonum));
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
  IOWR_32DIRECT(f.base_addr, word_offset*2*fifonum, data);
}


int
read_rx_fifo(struct fifoDetails f, int fifonum, int* data)
{
  if(status_rx_fifo_notEmpty(f, fifonum)) {
    (*data) = IORD_32DIRECT(f.base_addr,word_offset*2*fifonum);
    return true;
  } else {
    (*data) = 0;
    return false;
  }
}


void
report_rx_fifo(struct fifoDetails f, int fifonum, int chan_index, int silent)
{
  int data;
  while(read_rx_fifo(f, fifonum, &data)) {
    if(silent==false) {
      print_n_tabs(chan_index*3);
      alt_printf("RX-%c 0x%x\n",f.chan_letter,data);
    }
  }
}


int
status_device(int csr_index)
{
  return IORD_32DIRECT(MKSTATUSDEVICE_INSTANCE_0_BASE, csr_index*4);
}


int chip_id_lo() { return status_device(4); }
int chip_id_hi() { return status_device(5); }

void
print_link_status(struct fifoDetails f, int fifonum)
{
  int status;
  // assert 0<=fifonum<=3
  status = status_device(fifonum);
  alt_printf("Chan %c: Link up: tx=%x,rx=%x;  error_tx=0x%x,  error_rx=0x%x,  calibration_busy (binary)=%x%x,  htile_lock (binary)=%x%x\n",
	     f.chan_letter,
	     exbit(status,0),
	     exbit(status,1),
	     (status>>2) & 0xf,
	     (status>>6) & 0x1f,
	     exbit(status,18),
	     exbit(status,19),
	     exbit(status,16),
	     exbit(status,17));
}



void
test_write_read_channels(struct fifoDetails* fs, int num_chan)
{
  int j, chan;
  int cid0 = chip_id_lo();
  alt_printf("Write-read tests on the channels\n");
  for(j=0; j<100; j++) {
    for(chan=0; chan<num_chan; chan++)
      write_tx_fifo(fs[chan], 0, (cid0<<16) | (j+1));
    for(chan=0; chan<num_chan; chan++) {
      report_rx_fifo(fs[chan], 0, chan, false);
    }
    usleep(500000);
  }
}



void
test_write_read_one_link(struct fifoDetails fwrite, struct fifoDetails fread)
{
  const int num_flits = 10;
  int d[num_flits];
  int j,t;
  int cid0 = chip_id_lo();
  alt_printf("Fast write-read tests from channel %c to %c\n",fwrite.chan_letter, fread.chan_letter);
  for(j=0; j<num_flits; j++)
      write_tx_fifo(fwrite, 0, (cid0<<16) | (j+1));
  for(j=0; j<num_flits; j++)
    while(!read_rx_fifo(fread, 0, &d[j])) {};
  for(j=0; j<num_flits; j++)
    alt_printf("d[0x%x]=0x%x\n", j, d[j]);
  for(j=0; j<100; j++) {
    if(read_rx_fifo(fread, 0, &t))
      alt_printf("other data=0x%x\n",t);
    usleep(10000);
  }
}



void
discover_link_topology(struct fifoDetails* fs, int num_chan)
{
  int j, chan, data;
  int cid0 = chip_id_lo();
  int linkid[num_chan];

  for(chan=0; chan<num_chan; chan++)
    linkid[chan] = 0;
  
  alt_printf("Determininin topology.  Produces 'dot' format graph\n");
  for(j=0; j<10; j++) {
    for(chan=0; chan<num_chan; chan++)
      write_tx_fifo(fs[chan], 0, cid0);
    for(chan=0; chan<num_chan; chan++) {
      if(read_rx_fifo(fs[chan], 0, &data))
	linkid[chan] = data;
    }
    usleep(500000);
  }
  for(chan=0; chan<num_chan; chan++)
    alt_printf("DOT:    \"0x%x\" -> \"0x%x\";\n", linkid[chan], cid0);
}



int
main(void)
{
  const int num_chan = 4;
  const int fifonum = 0; // 0=serial-link, 1=loopback
  struct fifoDetails fs[num_chan];
  //int phy_mgmt_addr_offset = 1<<15; // word address offset to access physical management (PMA) addresses; MSB of address bits
  //int j, d, e, status;
  int j, chan;
  char c;
  int flush_mode = true;

  alt_putstr("Start...\n");

  alt_printf("ChipID = 0x%x %x\n", chip_id_hi(), chip_id_lo());
  // Check testreg to ensure we're probably communicating with a BERT
  fs[0].base_addr = MKBERT_INSTANCE_0_BASE;
  fs[0].chan_letter = 'A';
  fs[1].base_addr = MKBERT_INSTANCE_1_BASE;
  fs[1].chan_letter = 'B';
  fs[2].base_addr = MKBERT_INSTANCE_2_BASE;
  fs[2].chan_letter = 'C';
  fs[3].base_addr = MKBERT_INSTANCE_3_BASE;
  fs[3].chan_letter = 'D';
  for(j=0; j<num_chan; j++) {
    alt_printf("BERT 0x%x on Chan %c at base address 0x%x\n",
	       j,
	       fs[j].chan_letter,
	       fs[j].base_addr);
    check_testreg(fs[j]);
  }

  for(chan=0; chan<num_chan; chan++)
    print_link_status(fs[chan], chan);

  // test_write_read_channels(fs, num_chan);
  
  // set stdin to nonblocking to allow keyboard polling
  fcntl(0, F_SETFL, fcntl(0, F_GETFL) | O_NONBLOCK);

  alt_putstr("Start tests:\n");
  alt_putstr("   d = discover link topology (dot output)\n");
  alt_putstr("   f = flush then exit\n");
  alt_putstr("   l = loop-back\n");
  alt_putstr("   o = test one link quickly\n");
  alt_putstr("   t = test\n");
  c=' ';
  while (flush_mode) {
    c = alt_getchar();
    if((int) c > 0) {
      if(c=='\004') // exit on ctl-D
	return 0;
      if((c=='d') || (c=='f') || (c=='l') || (c=='o') || (c=='t')) flush_mode = false;
      for(chan=0; chan<num_chan; chan++)
	report_rx_fifo(fs[chan], fifonum, chan, true);
    }
  }

  if(c=='d')
    discover_link_topology(fs, num_chan);
  
  if(c=='l') {
    alt_putstr("Loopback mode\n");
    int cid0 = chip_id_lo();
    while(1) {
      for(chan=0; chan<num_chan; chan++) {
	int data;
	if(read_rx_fifo(fs[chan], fifonum, &data)) {
	  alt_printf("Loopback chan %c = 0x%x\n", fs[chan].chan_letter, data);
	  write_tx_fifo(fs[chan], fifonum, (cid0<<16) | (data & 0xffff) );
	}
      }
    }
  }

  if(c=='f') {
    alt_printf("Flushing data left in RX FIFOs\n");
    for(j=0; j<200; j++)
      for(chan=0; chan<num_chan; chan++)
	report_rx_fifo(fs[chan], fifonum, chan, false);
  }

  if(c=='o') 
    test_write_read_one_link(fs[3], fs[0]);
  
  if(c=='t') {
    alt_printf("Write-read tests on the channels\n");
    for(j=0; j<10; j++) {
      for(chan=0; chan<num_chan; chan++)
	write_tx_fifo(fs[chan], fifonum, ((chan|0x1000)<<16) | (j+1));
      //      write_tx_fifo(fs[chan], fifonum, (cid0<<16) | (j+1));
      for(chan=0; chan<num_chan; chan++) {
	alt_printf("Chan=%c\n", fs[chan].chan_letter);
	report_rx_fifo(fs[chan], fifonum, chan, false);
      }
    }
  
    for(j=0; j<100; j++)
      for(chan=0; chan<num_chan; chan++)
	report_rx_fifo(fs[chan], fifonum, 0, false);
  }
  
  alt_putstr("The end\n\n");
  usleep(1000000);

  alt_putstr("\004");
  return 0;
}



// TODO:
// - check phy_mgmt_addr - MSB has to be "manually set" - see pg 61 of PDF doc
