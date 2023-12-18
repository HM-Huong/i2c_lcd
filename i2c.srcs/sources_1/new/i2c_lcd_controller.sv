`timescale 1ns / 1ps


module i2c_lcd_controller(
	input  logic clk,
	input  logic rst_n,
	output logic [2:0] status,
	output tri scl,
	inout  tri sda 
);
	
	localparam n = 4; // len = 144

	typedef enum {
		SEND_ADDRESS,
		ACK,
		SEND_COMMAND,
		WAIT,
		DONE
	} state_type;

	typedef enum{
		RED = 3'b100,
		GREEN = 3'b010,
		BLUE = 3'b001,
		YELLOW = 3'b110,
		PURPLE = 3'b101
	} color_type;

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
	logic [1:0] cmd_next, cmd_reg;
	logic [7:0] data_reg, data_next, addr_reg, addr_next;
	logic [2:0] status_i;
	logic [7:0] rom [0:n];
	state_type state_reg, state_next;
	initial
    	$readmemh("rom.mem", rom);
    
	i2c_write  i2c_write_inst (
		.clk(clk),
		.reset(!rst_n),
		.command(cmd_reg), // 00 start, 01 write, 10 wait, 11 stop
		.addr('h2f),
		.data(data_reg),
		.status(status_i),
		.scl(scl),
		.sda(sda)
	);
	
	assign status = status_i;

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			state_reg <= SEND_ADDRESS;
			c_reg <= 0;
			addr_reg <= 0;
			data_reg <= 0;
			cmd_reg <= 0;
		end else begin
			state_reg <= state_next;
			c_reg <= c_next;
			addr_reg <= addr_next;
			data_reg <= data_next;
			cmd_reg <= cmd_next;
		end
	end

	always_comb begin
		state_next = state_reg;
		c_next = c_reg + 1;
		addr_next = addr_reg;
		data_next = data_reg;
		cmd_next = cmd_reg;
		case (state_reg)
			SEND_ADDRESS: begin
				cmd_next = 2'b00;
				state_next = ACK;
			end
			ACK: begin
				case (status_i)
					RED:
						state_next = DONE;
					GREEN:
						state_next = SEND_COMMAND;
					default:
						state_next = ACK;
				endcase
			end
			SEND_COMMAND: begin
				c_next = 0;
				cmd_next = 2'b01;
				data_next = rom[addr_reg];
				// waiting for ack
				if (status_i == GREEN) begin
					state_next = WAIT;
				end
				// i2c module didn't ack
				if (status_i == RED) begin
					state_next = DONE;
				end
			end
			WAIT: begin
				cmd_next = 2'b10; // wait
				if (c_reg == dvsr) begin
					state_next = SEND_COMMAND;
					addr_next = addr_reg + 1;
					if (addr_reg == n - 1) begin
						state_next = DONE;
					end
				end
			end
			DONE: begin
				cmd_next = 2'b11;
				data_next = 0;
			end
		endcase
	end

endmodule  

