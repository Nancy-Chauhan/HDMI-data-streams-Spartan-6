Transmission of High-Definition Multimedia
Interface (HDMI) data streams to HDMI/DVI
monitors via Spartan 6 FPGA

![Transmission of HDMI Signals on HDMI/DVI Monitor Demo](https://github.com/Nancy-Chauhan/HDMI-Color-Bar/blob/master/Image.jpeg)

<strong>Implementation</strong>

For implementating the Project a new ISE WebPack project is created and all Verilog and VHDL
files are added.  These files together with other useful files (such as the . ucf file) are included.
Then  the  project  is  synthesized  and  implemented.   Bitstream  file  is  downloaded  to  the  FPGA
board and tested.
To test the design, we need to attach a monitor to the HDMI OUT (J2) port of the Atlys board.
An HDMI monitor can be connected directly using an HDMI cable.  To connect a DVI monitor,we
need an HDMI to DVI converter

<strong>Output</strong> 

We see the monitor display the coloured pattern as shown in above figure. The monitor shows the
default colored pattern without any change in switching configurations.
Using three DIP switches on the board (SW0, SW1, and SW3), the user is able to switch among
different  screen  modes.   Following  test  pattern  are  observed by  selecting
following switches which display 720p frames configurations :
1) sw1 = 1, sw0 = 0
2) sw2=1, sw1=0, sw0=0

![ HDMI frame display on a computer monitor-1](https://github.com/Nancy-Chauhan/HDMI-Color-Bar/blob/master/output%202.jpg)

Following test pattern are observed by selecting following switches which:
1) sw2=0, sw1 = 0, sw0 = 1

![ HDMI frame display on a computer monitor-2](https://github.com/Nancy-Chauhan/HDMI-Color-Bar/blob/master/output3.jpg)
