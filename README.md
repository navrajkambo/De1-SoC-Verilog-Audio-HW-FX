# De1-SoC-Verilog-Audio-Loopback

This is a simple project which is meant to generate hardware nessessary to loopback the ADC and DAC from the DE1-SoC audio codec. The project is supposed to be a starting point for hardware audio DSP. The Audio codec is initialized for 16-bit audio, 48kHz left justified, but can be changed using QSYS. Also, the ADC and DAC are configured to be using the streaming interface rather than 
the memory-mapped interface so that you don't need to mess around with the Avalon bus. There is also hardware that saves data to the on-board SDRAM using an SDRAM controller. What makes this project special is that you don't need to instantiate the NIOS II softcore or HPS hardcore processors to get the system to work. Everything is done in hardware!

## Getting Started

Clone this repo, and then open the project in Quartus. You should be able to compile and program your DE1-SoC without needing to change anything. 

## Features
1) Mute audio using switch 9 (`SW[9]`)
2) Listen to delayed audio effect using switch 1 (`SW[1]`)
2) Add delayed audio effect using switch 2 (`SW[2]`)
3) Blink LED 0 (`LEDR[0]`) using switch 0 (`SW[0]`)
4) Save audio samples to 64MB SDRAM chip (only using 32MB)

## Custom Modules

To synchronize the audio and audio effects between the audio codec and SDRAM, a module is needed which generates the appropriate `ready-valid` handshake for the codec ADC and DAC, and the `read-write-ack` handshake for the SDRAM. The module is also responsible for generating the delay in the audio by indexing the read and write addresses with a bias.

## Hardware Output

Here is what the whole system looks like.
<object data="https://github.com/navrajkambo/De1-SoC-Verilog-Audio-Loopback/blob/SDRAM-audio-interface/netlists.PDF" type="application/pdf" width="700px" height="700px">
    <embed src="https://github.com/navrajkambo/De1-SoC-Verilog-Audio-Loopback/blob/SDRAM-audio-interface/netlists.PDF">
        <p>This browser does not support PDFs. Please download the PDF to view it: <a href="https://github.com/navrajkambo/De1-SoC-Verilog-Audio-Loopback/blob/SDRAM-audio-interface/netlists.PDF">Download PDF</a>.</p>
    </embed>
</object> 

## TODO
* [x] Get audio codec working
* [x] Integrate SDRAM into design
* [x] Create FSM for SDRAM between codec FIFOs
* [x] Test SDRAM read and write
* [x] Test delayed audio
* [x] Work on delayed audio effect
* [ ] Create an audio codec PCB for use on DE0-Nano

## Contact Me
- You can contact me at `nkambo1@my.bcit.ca`
- Check out my resume -> 'https://navrajkambo.github.io'

## Links
- SDRAM controller `https://github.com/stffrdhrn/sdram-controller`
- Avalon bridge `http://people.ece.cornell.edu/land/courses/ece5760/DE1_SOC/External_Bus_to_Avalon_Bridge.pdf`
- Altera Audio IP `https://fpgauniversity.intel.com/redirect/materials?id=/pub/Intel_Material/18.1/University_Program_IP_Cores/Audio_Video/Audio.pdf`
- Altera Audio/Video Config IP `https://fpgauniversity.intel.com/redirect/materials?id=/pub/Intel_Material/18.1/University_Program_IP_Cores/Audio_Video/Audio_and_Video_Config.pdf`
- Wolfson Audio Codec `http://www1.cs.columbia.edu/~sedwards/classes/2011/4840/Wolfson-WM8731-audio-CODEC.pdf`
