
module tb_i2c_write;

  reg  clk;
  reg  reset;
  reg [1:0] command;
  reg [6:0] addr;
  reg [7:0] data;
  wire [2:0] status;
  wire scl;
  wire sda;
  reg serital_data;
  reg [7:0] debug;
  
  assign sda = serital_data ? 1'bz : 0;
  
  i2c_write  i2c_write_inst (
    .clk(clk),
    .reset(reset),
    .command(command),
    .addr(addr),
    .data(data),
    .status(status),
    .scl(scl),
    .sda(sda)
  );

	localparam T = 10;
	always begin
		clk = 1'b0;
		#(T/2);
		clk = 1'b1;
		#(T/2);
	end
	
	initial begin
		serital_data = 1;
		reset = 1;
		#T;
		reset = 0;
		#(2000*T);
		
		// -------------------- start writing address
		debug = 0;
		command = 0;
		addr = 6'h21;
		wait(status == 3'b110); // yellow -> wait ready status
		#(8*4000*T);	// wait writing 8 bit
		
		// fake ack signal
		serital_data = 0;
		#(4000*T); // 1 scl
		serital_data = 1;
		
		// -------------------- start writing data
		debug = 1;
		command = 1;
		data = 8'h55;
		
		wait(status == 3'b110); // yellow - wait ready status
		#(8*4000*T);   // wait writing 8 bit
		
		// fake ack signal
		serital_data = 0;
		#(4000*T); // 1 scl
		serital_data = 1;
		
		// ------------------ wating some time
		debug = 2;
		command = 2'b10; // wait
		#(5*4000*T);
		
		// ----------------- start writing data
		debug = 3;
		command = 2'b01;
		data = 8'h22;
		
		wait(status == 3'b110); // yellow - wait ready status
		#(8*4000*T);   // wait writing 8 bit
		
		serital_data = 0;
		#(4000*T); // 1 scl
		serital_data = 1;
		
		// ---------------- stop
		debug = 4;
		command = 2'b11; // stop
		
		
		
		// ==================== repeat
		#(14*4000*T);
		
		// -------------------- start writing address
		debug = 0;
		command = 0;
		addr = 6'h77;
		wait(status == 3'b110); // yellow -> wait ready status
		debug = 7;
		#(8*4000*T);	// wait writing 8 bit
		
		// fake ack signal
		serital_data = 0;
		#(4000*T); // 1 scl
		serital_data = 1;
		
		// -------------------- start writing data
		debug = 1;
		command = 1;
		data = 8'h55;
		
		wait(status == 3'b110); // yellow - wait ready status
		#(8*4000*T);   // wait writing 8 bit
		
		// fake ack signal
		serital_data = 0;
		#(4000*T); // 1 scl
		serital_data = 1;
		
		// ------------------ wating some time
		debug = 2;
		command = 2'b10; // wait
		#(5*4000*T);
		
		// ----------------- start writing data
		debug = 3;
		command = 2'b01;
		data = 8'h22;
		
		wait(status == 3'b110); // yellow - wait ready status
		#(8*4000*T);   // wait writing 8 bit
		
		serital_data = 0;
		#(4000*T); // 1 scl
		serital_data = 1;
		
		// ---------------- stop
		debug = 4;
		command = 2'b11; // stop
		
	end


endmodule


