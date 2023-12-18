`timescale 1ns / 1ps


module i2c_lcd_controller(
	input  logic clk,
	input  logic rst_n,
	output logic [2:0] status,
	output tri scl,
	inout  tri sda 
);
	typedef enum {
		START,
		WRITE_ADDRESS,
		CHECK_ACK,
		WRITE_DATA,
		DELAY,
		STOP,
		DONE
	} state_type;

	localparam
		RED = 3'b100,
		GREEN = 3'b010,
		BLUE = 3'b001,
		YELLOW = 3'b110,
		PURPLE = 3'b101;

	/*
		When data is supplied to data pins, 
		a high-to-low pulse must be applied to en pin
		in order for the LCD to latch in the data present 
		at the data pins. This pulse must
		be a minimum of 450 ns wide.
		-> choose 1us = 1000 ns
		since the system clock is 100MHz (10ns),
		we need to count 100 cycles
	*/
	localparam dvsr = 100;
	logic [8:0] c_reg, c_next;

	localparam n = 144; // 144 bytes
	(*rom_style = "block"*) logic [7:0] rom [0:2 ** $clog2(n) - 1];
	logic [0:2 ** $clog2(n) - 1] addr_reg, addr_next;
	initial $readmemh("rom.mem", rom);

	logic [1:0] cmd_next, cmd_reg;
	logic [7:0] data;
	
	state_type state_reg, state_next;
    logic [2:0] status_i;
	
	i2c_write  i2c_write_inst (
		.clk(clk),
		.reset(!rst_n),
		.command(cmd_reg), // 00 start, 01 write, 10 wait, 11 stop
		.addr('h2f),
		.data(data),
		.status(status_i),
		.scl(scl),
		.sda(sda)
	);
	
	always_ff @(posedge clk) begin
		data <= rom[addr_reg];
		addr_reg <= addr_next;
	end

	always_ff @(posedge clk) begin
		state_reg <= state_next;
		c_reg <= c_next;
		cmd_reg <= cmd_next;
	end

	always_comb begin
		c_next = c_reg + 1;
		state_next = state_reg;
		addr_next = addr_reg;
		cmd_next = 0; // start/wait

		case (state_reg)
			START: begin
				if (status_i == BLUE) begin
					state_next = WRITE_ADDRESS;
				end
			end

			WRITE_ADDRESS: begin
				if (status_i == YELLOW) begin
					state_next = DELAY;
					c_next = 0;
				end
			end
			
			DELAY: begin
				if (c_reg == dvsr) begin
					state_next = CHECK_ACK;
				end
			end
			
			CHECK_ACK: begin
				if (status_i == RED) begin
					state_next = DONE;
				end else if (status_i == BLUE) begin
					state_next = WRITE_DATA;
				end
			end

			WRITE_DATA: begin // status = blue
				// write data
				if (addr_reg == n) begin
					state_next = STOP;
				end else begin
					cmd_next = 1'b01;
				end
				
				if (status_i == YELLOW) begin
					state_next = CHECK_ACK;
					addr_next = addr_reg + 1;
				end
			end

			STOP: begin
				cmd_next = 2'b11;
				if (status_i != BLUE) begin
					state_next = DONE;
				end
			end
			
			DONE: begin
				cmd_next = 2'b11;
				state_next = DONE; // stick here!
			end
		endcase

		if (!rst_n) begin
			addr_next = 0;
			state_next = START;
			c_next = 0;
			cmd_next = 0;
		end 
	end

	// output logic
	assign status = status_i;

endmodule  

