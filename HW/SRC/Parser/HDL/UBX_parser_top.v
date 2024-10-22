`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M.Mahdi Sayadi 
// 
// Create Date: 10/22/2024 12:26:06 PM
// Design Name: 
// Module Name: UBX_parser_top
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


module UBX_parser_top
	(
		input 				i_uart_clk,
		input 		[7:0] 	i_data_tdata,
		input 				i_data_tvalid,
		output reg	[15:0] 	o_csid_tdata,
		output reg	[15:0] 	o_length_tdata,
		output reg	[8:0] 	o_pyl_tdata,
		output reg			o_pkt_tvalid,
		output reg 			o_pkt_tlast,
		output reg 			pkt_error
	);

// ===============================================================================================
// PARAMETER DECLERATION 
// ===============================================================================================
	localparam UBX_HEADER_C = 16'hB562;
	localparam IDLE = 8'd0; 
	localparam HEADER = 8'd1; 
	localparam CLASSID = 8'd2; 
	localparam LENGTH = 8'd3; 
	localparam PAYLOAD = 8'd4; 
	localparam CHECKSUM = 8'd5; 
	localparam CHECKSUM_VALIDATE = 8'd6; 

// ===============================================================================================
// WIRE AND REGISTER DECLERATION 
// ===============================================================================================
	
	// INPUT_REGISTER_PROCESS
		reg [7:0] 	s_data_tdata  = 8'h00;
		reg 			s_data_tvalid = 1'b0;
		reg [7:0] 	s_rdata_tdata  = 8'h00;
		reg 			s_rdata_tvalid = 1'b0;
		reg [7:0]	pars_cs = IDLE;
	
	// PARSE_PROCESS
		reg 			calc_chechsum_flag = 1'b0;
		reg [7:0]	byte_cntr = 8'h00;	
		reg [15:0]	ubx_header = 16'h0000;
		reg [15:0]	ubx_csid   = 16'h0000;
		reg [15:0]	ubx_len   = 16'h0000;
		reg [7:0]	ubx_pyl   = 8'h00;
		reg [15:0]	ubx_CK   = 16'h0000;
		reg 			ubx_tvalid = 1'b0;
		reg 			ubx_tlast = 1'b0;
		wire [15:0]	little_len;
	
	// CHECKSUM_CALC_PROCESS
		reg [3:0]	csum_calc_cs = 4'h0;
		reg [7:0]	CK_A = 8'h00;
		reg [7:0]	CK_B = 8'h00;
		

// ===============================================================================================
// ASSIGNMENTS 
// ===============================================================================================
assign little_len = {ubx_len[7:0], ubx_len[15:8]};

// ===============================================================================================
// CODE BODY  
// ===============================================================================================


// INPUT_REGISTER_PROCESS 
always @(posedge i_uart_clk) begin 
	
	s_data_tdata 		<= i_data_tdata;
	s_data_tvalid		<= i_data_tvalid;
	s_rdata_tdata 	<= s_data_tdata;
	s_rdata_tvalid	<= s_data_tvalid;
	
end 

// PARSE_PROCESS
always @(posedge i_uart_clk) begin 
	
	case (pars_cs) 
		IDLE : begin 
			
			if (s_data_tvalid) begin 
				pars_cs <= HEADER;
			end 
			ubx_tvalid 			<= 1'b0;
			byte_cntr  			<= 8'h00;
			calc_chechsum_flag 	<= 1'b0;
			pkt_error 			<= 1'b0;
			ubx_tlast			<= 1'b0;
			
		end
		HEADER : begin 
			
			if (s_rdata_tvalid) begin 
				if (byte_cntr < 2 - 1 ) begin 
					byte_cntr <= byte_cntr + 1;
				end 
				else begin 
					byte_cntr  			<= 8'h00;
					pars_cs 				<= CLASSID;
					calc_chechsum_flag 	<= 1'b1;
				end
				ubx_header <= {ubx_header[7:0], s_rdata_tdata};
			end 
			
		end
		CLASSID : begin 
			
			if (ubx_header != UBX_HEADER_C ) begin 
				pars_cs <= IDLE;
			end
			else begin 
				
				if (s_rdata_tvalid) begin 
					if (byte_cntr < 2 - 1 ) begin 
						byte_cntr <= byte_cntr + 1;
					end
					else begin 
						byte_cntr  			<= 8'h00;
						pars_cs 				<= LENGTH;
					end
					ubx_csid <= {ubx_csid[7:0], s_rdata_tdata};
				end
			end
			
		end
		LENGTH : begin 
			
			if (s_rdata_tvalid) begin 
				if (byte_cntr < 2 - 1 ) begin 
					byte_cntr <= byte_cntr + 1;
				end
				else begin 
					byte_cntr  	<= 8'h00;
					pars_cs 		<= PAYLOAD;
				end
				ubx_len <= {ubx_len[7:0], s_rdata_tdata};
			end
		end
		PAYLOAD : begin 
			
			if (s_rdata_tvalid) begin 
				if (byte_cntr < little_len - 1 ) begin 
					byte_cntr <= byte_cntr + 1;
				end 
				else begin 
					byte_cntr  	<= 8'h00;
					pars_cs 		<= CHECKSUM;
					ubx_tlast	<= 1'b1;
				end
				ubx_pyl <= s_rdata_tdata;
			end
			ubx_tvalid <= s_rdata_tvalid;
			
		end
		CHECKSUM : begin 
			
			ubx_tlast	<= 1'b0;
			calc_chechsum_flag 	<= 1'b0;
			if (s_rdata_tvalid) begin 
				if (byte_cntr < 2 - 1 ) begin 
					byte_cntr <= byte_cntr + 1;
				end 
				else begin 
					byte_cntr  	<= 8'h00;
					pars_cs 		<= CHECKSUM_VALIDATE;
				end
				ubx_CK <= {ubx_CK[7:0], s_rdata_tdata};
			end
			ubx_tvalid <= 1'b0;
	
		end
		CHECKSUM_VALIDATE : begin 
			
			if (ubx_CK != {CK_A, CK_B}) begin 
				pkt_error <= 1'b1;
			end else begin 
				pkt_error <= 1'b0;
			end 
			pars_cs 		<= IDLE;
			
		end 
		default : begin 
		end 
	endcase	
end 

// CHECKSUM_CALC_PROCESS
always @(posedge i_uart_clk) begin 
	
	if ( s_rdata_tvalid && calc_chechsum_flag ) begin 
		
		CK_A <= CK_A + s_rdata_tdata;

	end else if ( pars_cs == IDLE ) begin 	
		CK_A <= 8'h00;	
	end 

	if ( pars_cs != IDLE ) begin 	
		case (csum_calc_cs)  
			4'h0 : begin 
				if ( s_rdata_tvalid && calc_chechsum_flag ) begin 
					csum_calc_cs <= 4'h1;
				end 
			end 
			4'h1 : begin 
				CK_B <= CK_B + CK_A;
				csum_calc_cs <= 4'h0;
			end 
			default : begin 
				
			end 
		endcase
	end else begin 
		CK_B <= 8'h00;	
	end;

end 

// OUTPUT_REGISTER_PROCESS
always @( posedge i_uart_clk ) begin 
	
	o_csid_tdata		<= ubx_csid;
	o_length_tdata	<= ubx_len;		
	o_pyl_tdata		<= ubx_pyl;	
	o_pkt_tvalid		<= ubx_tvalid;
	o_pkt_tlast		<= ubx_tlast;

end;





endmodule
