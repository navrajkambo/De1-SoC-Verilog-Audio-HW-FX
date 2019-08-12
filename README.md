# De1-SoC-Verilog-Audio-Loopback

This is a simple project which is meant to generate hardware nessessary to loopback the ADC and DAC from the DE1-SoC audio codec. The project is meant to be a starting point for hardware audio DSP. The Audio codec is initialized for 16-bit audio, 48kHz left justified, but can be changed using QSYS. Also, the ADC and DAC are configured to be using the streaming interface rather than 
the memory-mapped interface so that you don't need to mess around with the Avalon bus. 

## Getting Started

Clone this repo, and then open the project in Quartus. You should be able to compile and program your DE1-SoC without needing to change anything. 

## Hardware Output

Here is what the whole system looks like. 
![RTL](https://github.com/navrajkambo/De1-SoC-Verilog-Audio-Loopback/blob/master/RTL.PNG "Hardware generated by Quartus")

## Contact Me
- You can contact me at `nkambo1@my.bcit.ca`
- Check out my resume -> `https://navrajkambo.github.io`

## Links
- Avalon bridge `http://people.ece.cornell.edu/land/courses/ece5760/DE1_SOC/External_Bus_to_Avalon_Bridge.pdf`
- Altera Audio IP `https://fpgauniversity.intel.com/redirect/materials?id=/pub/Intel_Material/18.1/University_Program_IP_Cores/Audio_Video/Audio.pdf`
- Altera Audio/Video Config IP `https://fpgauniversity.intel.com/redirect/materials?id=/pub/Intel_Material/18.1/University_Program_IP_Cores/Audio_Video/Audio_and_Video_Config.pdf`
- Wolfson Audio Codec `http://www1.cs.columbia.edu/~sedwards/classes/2011/4840/Wolfson-WM8731-audio-CODEC.pdf`
