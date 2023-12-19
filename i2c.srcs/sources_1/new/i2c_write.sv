`timescale 1ns / 1ps

module i2c_write(
	input logic clk, reset,
	input logic [1:0] command, // 00 start, 01 write, 10 wait, 11 stop
	input logic [6:0] addr,
	input logic [7:0] data,
	output logic [2:0] status, // rgb

	// i2c 
	output tri scl,
	inout  tri sda
);

	//symbolic constant
	localparam START_CMD   =3'b000;
	localparam WR_CMD      =3'b001;
	localparam RD_CMD      =3'b010;
	localparam STOP_CMD    =3'b011;
	localparam RESTART_CMD =3'b100;

	typedef enum bit [3:0] {
		RED = 3'b100,
		GREEN = 3'b010,
		BLUE = 3'b001,
		YELLOW = 3'b110,
		PURPLE = 3'b101
	} rgb_type;
	
	typedef enum {
		IDLE,
		START,
		WRITE_ADDRESS,
		WAIT_ACK,
		CHECK_ACK,
		WRITE_DATA,
		STOP1, STOP2
	} state_type;

	logic [7:0] din;
	logic i2c_wr_cmd;
	logic [2:0] i2c_cmd;
	logic ready, done_tick, ack;
	state_type state_reg, state_next;
	rgb_type status_reg, status_next;
	/*
		system clock: 100MHz
		i2c frequency: 100kHz
		dvsr = 100MHz / 100kHz = 1000
	*/
	i2c_master  i2c_master_inst (
		.clk(clk),
		.reset(reset),
		.din(din),
		.dvsr(32'd1000),
		.cmd(i2c_cmd),
		.wr_cmd(i2c_wr_cmd),

		// output
		.sda(sda),
		.scl(scl),
		.ready(ready),
		.ack(ack),
		.done_tick(done_tick),
		.dout()
	);

	always_ff @(posedge clk) begin
		state_reg <= state_next;
		status_reg <= status_next;
	end

  // next state logic
	always_comb begin
		state_next = state_reg;
		status_next = status_reg;
		
		din = 0;
		i2c_cmd = 0;
		i2c_wr_cmd = 0;
		case (state_reg)
			IDLE: begin // ready = 1
				// send start command
				// status_next = PURPLE;
				if (command == 0) begin
					i2c_wr_cmd = 1;
					i2c_cmd = START_CMD;
				end
				
				if (!ready)
					state_next = START;
			end
			
			START: begin // ready = 0
				status_next = BLUE;
				if (ready) // hold state
					state_next = WRITE_ADDRESS;
			end
			
			WRITE_ADDRESS: begin // ready = 1
				status_next = GREEN;
				i2c_wr_cmd = 1;
				i2c_cmd = WR_CMD;
				din = {addr, 1'b0}; // 0 mean write
				if (!ready) begin   // sending address
					state_next = WAIT_ACK;
				end
				
			end

			WAIT_ACK: begin // ready = 0
				status_next = YELLOW;
				if (ready) begin   // sent address/data
					state_next = CHECK_ACK;
				end
			end

			CHECK_ACK: begin // ready = 1
				status_next = BLUE;
				if (ack == 0) begin
					if (command == 1) begin
						state_next = WRITE_DATA;
					end else if (command == 3) begin
						status_next = PURPLE;
						state_next = STOP1;
					end
				end else begin
					status_next = RED;
					state_next = STOP1;
				end 
			end
			
			WRITE_DATA: begin // ready = 1
				status_next = GREEN;
				i2c_wr_cmd = 1;
				i2c_cmd = WR_CMD;
				din = data;
				if (!ready) begin
					state_next = WAIT_ACK;
				end
			end
			
			STOP1: begin
				i2c_wr_cmd = 1;
				i2c_cmd = STOP_CMD;
				if (!ready) begin
					state_next = STOP2;
				end
			end

			STOP2: begin
				if (ready) begin
					state_next = IDLE;
				end
			end
		endcase

		if (reset) begin
			state_next = IDLE;
			status_next = PURPLE;
		end 
	end
	
	assign status = status_reg;
	
endmodule
