module sram (
		input  wire [0:0]  data_a,    //    data_a.datain_a,  Data input to port A of the memory.The data port is required for all RAM operation modes:SINGLE_PORT,DUAL_PORT,BIDIR_DUAL_PORT,QUAD_PORT
		output wire [0:0]  q_a,       //       q_a.dataout_a, Data output from port A of the memory. The data port is required if the operation modes parameter is set to any of the following values:SINGLE_PORT,BIDIR_DUAL_PORT,QUAD_PORT,ROM
		input  wire [0:0]  data_b,    //    data_b.datain_b,  Data input to port B of the memory.The data_b port is required if the operation_mode parameter is set to BIDIR_DUAL_PORT and QUAD_PORT
		output wire [0:0]  q_b,       //       q_b.dataout_b, Data output from port B of the memory. The q_b port is required if the operation_mode is set to the following values:DUAL_PORT,BIDIR_DUAL_PORT,QUAD_PORT
		input  wire [16:0] address_a, // address_a.address_a, Address input to port A of the memory.The address_a signal is required for all operation modes.
		input  wire [16:0] address_b, // address_b.address_b, Address input to port B of the memory.The address_b port is required if the operation_mode parameter is set to the following values:DUAL_PORT,BIDIR_DUAL_PORT,QUAD_PORT
		input  wire        wren_a,    //    wren_a.wren_a,    Write enable input for address_a port.The wren_a signal is required all RAM operation modes:SINGLE_PORT,DUAL_PORT,BIDIR_DUAL_PORT,QUAD_PORT
		input  wire        wren_b,    //    wren_b.wren_b,    Write enable input for address_b port.The wren_b port is required if operation_mode is set to BIDIR_DUAL_PORT and QUAD_PORT.
		input  wire        clock      //     clock.clk,       Memory clock, refer to user guide for specific details
	);
endmodule

