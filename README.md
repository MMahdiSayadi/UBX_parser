# UBX_parser
 this repo containt rtl code which parse ubx packet came from uart.


## How to build project 
to build the project run below command in the vivado tcl console.
```shll
cd build_folder 
source vivado_build2.tcl
```
once the project is built, you can run the test bench and see the result.

## Project Considerations
notice that this packet protocol is on uart platform. since your system clock is higher than uart data rate 
so your data came with specific initiation interval. and this core work only with data which have initiation interval.
and it is not suitable for burst data. if checksum of the packet does not match with calculated checksum in the core the `packet_error`
signal will be ativated. 

    for simulation you have to add data in the `TestFiles` folder to the simulation sources of the vivado.









