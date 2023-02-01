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


int
exbitfield(int word, int base, int len)
{
  // assume 0<len<32 and (base+len)<=32
  uint mask = (1<<len)-1;
  return (word>>base) & mask;
}


void
print_n_tabs(int n)
{
  for(; n>0; n--)
    alt_putchar('\t');
}


int
check_testreg(struct fifoDetails f)
{
  int j,t,d;
  int pass=true;
  int testreg_addr_offset=0x10*word_offset;
  for(j=0; j<10; j++) {
    t=j;
    IOWR_32DIRECT(f.base_addr, testreg_addr_offset, ~t);
    d = IORD_32DIRECT(f.base_addr, testreg_addr_offset);
    if(d!=t) {
      alt_printf("Chan %c: testreg expecting 0x%x but read 0x%x - fail\n", f.chan_letter, t, d);
      pass=false;
    }
  }
  return pass;
}


void
print_bert_build_timestamp(struct fifoDetails f)
{
  int lo = IORD_32DIRECT(f.base_addr, 0x12*word_offset);
  int hi = IORD_32DIRECT(f.base_addr, 0x13*word_offset);
  alt_printf("Chan %c: Bluespec built on %x-%x%x-%x%x %x%x:%x%x.%x%x\n",
	     f.chan_letter,
	     // year
	     exbitfield(hi,  8,16),
	     // month
	     exbitfield(hi,  4,4),
	     exbitfield(hi,  0,4),
	     // days
	     exbitfield(lo,  28,4),
	     exbitfield(lo,  24,4),
	     // hours
	     exbitfield(lo,  20,4),
	     exbitfield(lo,  16,4),
	     // minutes
	     exbitfield(lo, 12,4),
	     exbitfield(lo,  8,4),
	     // seconds
	     exbitfield(lo,  4,4),
	     exbitfield(lo,  0,4));
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
  status = status_device(fifonum);
  int link_up_tx = exbit(status,0);
  int link_up_rx = exbit(status,1);
  int error_tx = exbitfield(status,2,4);
  int error_rx = exbitfield(status,6,5);
  int calibration_busy = exbit(status,18) | exbit(status,19);
  int htile_lock = exbit(status,16) & exbit(status,17);
  int good = (link_up_tx==1)
           & (link_up_rx==1)
           & (error_tx==0)
           & (error_rx==0)
           & (calibration_busy==0)
           & (htile_lock==1);
  alt_printf("Chan %c: Link up: tx=%x,rx=%x;  error_tx=0x%x,  error_rx=0x%x,  calibration_busy (binary)=%x,  htile_lock (binary)=%x - Link is %s\n",
	     f.chan_letter,
	     link_up_tx,
	     link_up_rx,
	     error_tx,
	     error_rx,
	     calibration_busy,
	     htile_lock,
	     good ? "GOOD" : "BAD");
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
    usleep(100000); // sleep for 0.1s
  }
  // report on any remaining data received
  for(j=0; j<30; j++)
    for(chan=0; chan<num_chan; chan++) {
      report_rx_fifo(fs[chan], 0, chan, false);
      usleep(100000); // sleep for 0.1s
    }
}


void
echo_links(struct fifoDetails* fs, int num_chan)
{
  int chan, data;
  int cid0 = chip_id_lo();
  alt_putstr("Echo mode\n");
  while(1) {
    for(chan=0; chan<num_chan; chan++) {
      if(read_rx_fifo(fs[chan], 0, &data)) {
	alt_printf("Echo chan %c = 0x%x\n", fs[chan].chan_letter, data);
	write_tx_fifo(fs[chan], 0, (cid0<<16) | (data & 0xffff) );
      }
    }
  }
}


void
bert_report(struct fifoDetails* fs, int num_chan)
{
  int chan;
  for(chan=0; chan<num_chan; chan++)
    alt_printf("BERT - Channel %c:  number of errors = 0x%x 0x%x \tnumber of correct flits = 0x%x 0x%x\n",
	       fs[chan].chan_letter,
	       IORD_32DIRECT(fs[chan].base_addr, 7*word_offset),
	       IORD_32DIRECT(fs[chan].base_addr, 6*word_offset),
	       IORD_32DIRECT(fs[chan].base_addr, 5*word_offset),
	       IORD_32DIRECT(fs[chan].base_addr, 4*word_offset)
	       );
}


void
zero_bert_counters(struct fifoDetails* fs, int num_chan)
{
  int chan;
  for(chan=0; chan<num_chan; chan++)
    IOWR_32DIRECT(fs[chan].base_addr, 0x4*word_offset, 0);
}


void
bert_test_generation_enable(struct fifoDetails* fs, int num_chan, int enable)
{
  int chan, en;
  for(chan=0; chan<num_chan; chan++) {
    IOWR_32DIRECT(fs[chan].base_addr, 0x11*word_offset, enable);
    en = IORD_32DIRECT(fs[chan].base_addr, 0x11*word_offset);
    alt_printf("Chan %c: BERT enable = %s\n", fs[chan].chan_letter, en ? "True": "False");
  }
}


void
flush_links(struct fifoDetails* fs, int num_chan)
{
  int j, chan;
  
  alt_printf("Flushing data left in RX FIFOs\n");
  for(j=0; j<100; j++)
    for(chan=0; chan<num_chan; chan++) {
      report_rx_fifo(fs[chan], 0, chan, false);
      usleep(100000); // wait 0.1s
    }
}


void
test_write_read_one_link(struct fifoDetails fwrite, struct fifoDetails fread, int fifonum)
{
  const int num_flits = 10;
  int d[num_flits];
  int j,t;
  int cid0 = chip_id_lo();
  alt_printf("Fast write-read tests from channel %c to %c\n",fwrite.chan_letter, fread.chan_letter);
  for(j=0; j<num_flits; j++)
      write_tx_fifo(fwrite, fifonum, (cid0<<16) | (j+1));
  for(j=0; j<num_flits; j++)
    while(!read_rx_fifo(fread, fifonum, &d[j])) {};
  for(j=0; j<num_flits; j++)
    alt_printf("d[0x%x]=0x%x\n", j, d[j]);
  for(j=0; j<100; j++) {
    if(read_rx_fifo(fread, fifonum, &t))
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
    alt_printf("DOT:    \"0x%x\" -> \"0x%x\" [label=\"%c->\"];\n", linkid[chan], cid0,fs[chan].chan_letter);
}



int
main(void)
{
  const int num_chan = 4;
  // const int fifonum = 0; // 0=serial-link, 1=loopback
  struct fifoDetails fs[num_chan];
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

  print_bert_build_timestamp(fs[0]);
  
  for(chan=0; chan<num_chan; chan++)
    print_link_status(fs[chan], chan);

  for(chan=0; chan<num_chan; chan++)
    if(!check_testreg(fs[chan]))
      return 1;
  
  // test_write_read_channels(fs, num_chan);
  
  // set stdin to nonblocking to allow keyboard polling
  fcntl(0, F_SETFL, fcntl(0, F_GETFL) | O_NONBLOCK);

  alt_putstr("Start tests:\n");
  alt_putstr("   b = bit error-rate test report\n");
  alt_putstr("   z = zero bit error-rate test counters\n");
  alt_putstr("   0 = stop BERT test generation\n");
  alt_putstr("   1 = start BERT test generation\n");
  alt_putstr("   d = discover link topology (dot output)\n");
  alt_putstr("   f = flush links then exit\n");
  alt_putstr("   e = echo mode\n");
  alt_putstr("   o = test one link quickly\n");
  alt_putstr("   t = test\n");
  c=' ';

  while (flush_mode) {
    c = alt_getchar();
    if((int) c > 0) {
      if(c=='\004') // exit on ctl-D
	return 0;
      if((c=='0') || (c=='1') || (c=='b') || (c=='d') || (c=='f') || (c=='l') || (c=='o') || (c=='t') || (c=='z')) flush_mode = false;
      for(chan=0; chan<num_chan; chan++)
	report_rx_fifo(fs[chan], 0, chan, true);
    }
  }

  if(c=='b')
    bert_report(fs, num_chan);
  
  if(c=='d')
    discover_link_topology(fs, num_chan);
  
  if(c=='e')
    echo_links(fs, num_chan);

  if(c=='f')
    flush_links(fs, num_chan);

  if(c=='o') 
    test_write_read_one_link(fs[3], fs[0], 0);
  // Check one link in loop-back:  test_write_read_one_link(fs[0], fs[0], 1);
  
  if(c=='t')
    test_write_read_channels(fs, num_chan);

  if(c=='z')
    zero_bert_counters(fs, num_chan);

  if((c=='0') || (c=='1'))
    bert_test_generation_enable(fs, num_chan, c=='1' ? 1 : 0);
  
  alt_putstr("The end\n\n");
  usleep(1000000);

  alt_putstr("\004");
  return 0;
}



// TODO:
// - check phy_mgmt_addr - MSB has to be "manually set" - see pg 61 of PDF doc
