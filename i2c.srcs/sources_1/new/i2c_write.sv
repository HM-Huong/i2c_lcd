`timescale 1ns / 1ps

module i2c_write(
	input logic clk, reset,
	input logic [1:0] command, // 00 start, 01 write, 10 wait, 11 stop
	input logic [6:0] addr,
	input logic [7:0] data,
	output logic [2:0] status, // rgb

	// i2c interface
	output tri scl,
	inout  tri sda
);

	//symbolic constant
	localparam START_CMD   =3'b000;
	localparam WR_CMD      =3'b001;
	localparam RD_CMD      =3'b010;
	localparam STOP_CMD    =3'b011;
	localparam RESTART_CMD =3'b100;

	typedef enum{
		RED = 3'b100,
		GREEN = 3'b010,
		BLUE = 3'b001,
		YELLOW = 3'b110,
		PURPLE = 3'b101
	} color_type;

	typedef enum {
		IDLE,
		WRITE_ADDRESS,
		WAIT_ACK,
		WRITE_DATA
	} state_type;

	logic [7:0] din, dout;
	logic i2c_wr_cmd;
	logic [2:0] i2c_cmd;
	logic ready, done_tick, ack;
	state_type state_reg, state_next;
	color_type status_reg, status_next;

	/*
		system clock: 100MHz
		i2c frequency: 100kHz
		dvsr = 100MHz / 100kHz = 1000
	*/
	i2c_master  i2c_master_inst (
		.clk(clk),
		.reset(reset),
		.din(din),
		.dvsr(1000),
		.cmd(i2c_cmd),
		.wr_cmd(i2c_wr_cmd),

		// output
		.sda(sda),
		.scl(scl),
		.ready(ready),
		.ack(ack),
		.done_tick(done_tick),
		.dout(dout)
	);

	always_ff @(posedge clk, posedge reset)
	begin
		if (reset) begin
			state_reg <= IDLE;
			status_reg <= BLUE;
		end else begin
			state_reg <= state_next;
			status_reg <= status_next;
		end
	end

  // next state logic
	always_comb begin
		state_next = state_reg;
		status_next = status_reg;

		i2c_wr_cmd = 0;
		i2c_cmd = 0;
		case (state_reg)
			IDLE: begin
				if (command == 2'b00) begin
					i2c_wr_cmd = 1;
					i2c_cmd = START_CMD;
					status_next = BLUE;
				end
				if (!ready) begin // beginning start signal 
					state_next = WRITE_ADDRESS;
				end
			end

			WRITE_ADDRESS: begin
				if (ready) begin
					state_next = WAIT_ACK;
					i2c_wr_cmd = 1;
					i2c_cmd = WR_CMD;
					din = {addr, 1'b0}; // 0 mean write
				end
				
			end

			WAIT_ACK: begin
				status_next = YELLOW;
				if (ready && ack) begin
					status_next = RED;
					i2c_wr_cmd = 1;
					i2c_cmd = STOP_CMD;
					state_next = IDLE;
				end else if (ready && !ack) begin
					state_next = WRITE_DATA;
				end
			end


			WRITE_DATA: begin
				status_next = GREEN;
				case (command)
					2'b01: begin // write data
						state_next = WAIT_ACK;
						i2c_wr_cmd = 1;
						i2c_cmd = WR_CMD;
						din = data;
					end
					
					2'b11: begin // stop writing
						state_next = IDLE;
						status_next = BLUE;
						i2c_wr_cmd = 1;
						i2c_cmd = STOP_CMD;
					end
					
					default: begin // wait
						state_next = WRITE_DATA;
						status_next = GREEN;
					end
				endcase
			end
		endcase
	end
	
	assign status = status_reg;
endmodule
