`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2024 01:40:10 PM
// Design Name: 
// Module Name: UBX_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module UBX_tb
(
);

// ===============================================================================================
// WIRE AND REGISTER DECLERATION 
// ===============================================================================================

	// clock and reset 
		reg 			s_reset 	= 1'b1;
		reg 			s_clk 	= 1'b0;
	
	// Inst_FileReaderv_1
		wire [15:0] 	ubx_tdata;
		wire 		ubx_tvalid;
		wire [7:0]	pyl_tdata;
		wire [15:0]	csid_tdata;
		wire [15:0]	length_tdata;
		wire 		packet_tvalid;

// ===============================================================================================
// CODE BODY  
// ===============================================================================================

	FileReaderv_1 # 
		(
			.G_interval					(16),
			.G_data_width 				(16),
			.G_half_width 				(8),
			.G_data_len	 				(1024),
			.real_file_name_addr 			("Mat_Out_UBXUBX_00_Real.txt"),
			.imag_file_name_addr 			("Mat_Out_UBXUBX_00_Real.txt")
		)
	Inst_FileReaderv_1
		(
			.i_Clk   					(s_clk),
			.i_Reset 					(s_reset),
			.o_ax_1_data_tdata   			(ubx_tdata),
			.o_ax_1_data_tvalid  			(ubx_tvalid)
	
		);

	UBX_parser_top Inst_UBX_parser_top
		(
			.i_uart_clk		(s_clk),						
			.i_data_tdata		(ubx_tdata[7:0]),				
			.i_data_tvalid	(ubx_tvalid),					
			.o_csid_tdata		(csid_tdata),				
			.o_length_tdata	(length_tdata),					
			.o_pyl_tdata		(pyl_tdata),				
			.o_pkt_tvalid		(packet_tvalid)			
		);

// =================================================================================================
// generate clock and reset 
// =================================================================================================

always @(s_reset)
begin 
	#200 s_reset = ~ s_reset;
end 
initial begin
	forever #5 s_clk = ~s_clk;  
end



endmodule
