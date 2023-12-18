
module tb_i2c_lcd_controller;

  // Parameters

  //Ports
  reg  clk;
  reg  rst_n;
  wire [2:0] status;
  wire scl;
  wire sda;
  reg serital_data;
  reg [7:0] debug;
  
  assign sda = serital_data ? 1'bz : 0;

  i2c_lcd_controller  i2c_lcd_controller_inst (
    .clk(clk),
    .rst_n(rst_n),
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
		serital_data = 0;
		rst_n = 0;
		#T;
		rst_n = 1;
		
//		wait(status == 3'b110); // yellow -> beginning of writing phase
//		#(8*4000*T);	// wait writing 8 bit
//		debug = 1;
//		// fake ack signal
//		serital_data = 0;
//		#(4000*T); // 1 scl
//		serital_data = 1;
//		wait(status == 3'b001); // blue -> check ack 
		
//		wait(status == 3'b110); // yellow -> beginning of writing phase
//		#(8*4000*T);	// wait writing 8 bit
//		debug = 2;
//		// fake ack signal
//		serital_data = 0;
//		#(4000*T); // 1 scl
//		serital_data = 1;
//		wait(status == 3'b001); // blue -> check ack 
		
//		wait(status == 3'b110); // yellow -> beginning of writing phase
//		#(8*4000*T);	// wait writing 8 bit
//		debug = 3;
//		// fake ack signal
//		serital_data = 0;
//		#(4000*T); // 1 scl
//		serital_data = 1;
//		wait(status == 3'b001); // blue -> check ack 
		
//		wait(status == 3'b110); // yellow -> beginning of writing phase
//		#(8*4000*T);	// wait writing 8 bit
//		debug = 4;
//		// fake ack signal
//		serital_data = 0;
//		#(4000*T); // 1 scl
//		serital_data = 1;
//		wait(status == 3'b001); // blue -> check ack 
		
//		wait(status == 3'b110); // yellow -> beginning of writing phase
//		#(8*4000*T);	// wait writing 8 bit
//		debug = 1;
//		// fake ack signal
//		serital_data = 0;
//		#(4000*T); // 1 scl
//		serital_data = 1;
//		wait(status == 3'b001); // blue -> check ack 
		
//		wait(status == 3'b110); // yellow -> beginning of writing phase
//		#(8*4000*T);	// wait writing 8 bit
//		debug = 2;
//		// fake ack signal
//		serital_data = 0;
//		#(4000*T); // 1 scl
//		serital_data = 1;
//		wait(status == 3'b001); // blue -> check ack 
		
//		wait(status == 3'b110); // yellow -> beginning of writing phase
//		#(8*4000*T);	// wait writing 8 bit
//		debug = 3;
//		// fake ack signal
//		serital_data = 0;
//		#(4000*T); // 1 scl
//		serital_data = 1;
//		wait(status == 3'b001); // blue -> check ack 
		
//		wait(status == 3'b110); // yellow -> beginning of writing phase
//		#(8*4000*T);	// wait writing 8 bit
//		debug = 4;
//		// fake ack signal
//		serital_data = 0;
//		#(4000*T); // 1 scl
//		serital_data = 1;
//		wait(status == 3'b001); // blue -> check ack 
		
//		wait(status == 3'b110); // yellow -> beginning of writing phase
//		#(8*4000*T);	// wait writing 8 bit
//		debug = 1;
//		// fake ack signal
//		serital_data = 0;
//		#(4000*T); // 1 scl
//		serital_data = 1;
//		wait(status == 3'b001); // blue -> check ack 
		
//		wait(status == 3'b110); // yellow -> beginning of writing phase
//		#(8*4000*T);	// wait writing 8 bit
//		debug = 2;
//		// fake ack signal
//		serital_data = 0;
//		#(4000*T); // 1 scl
//		serital_data = 1;
//		wait(status == 3'b001); // blue -> check ack 
		
//		wait(status == 3'b110); // yellow -> beginning of writing phase
//		#(8*4000*T);	// wait writing 8 bit
//		debug = 3;
//		// fake ack signal
//		serital_data = 0;
//		#(4000*T); // 1 scl
//		serital_data = 1;
//		wait(status == 3'b001); // blue -> check ack 
		
//		wait(status == 3'b110); // yellow -> beginning of writing phase
//		#(8*4000*T);	// wait writing 8 bit
//		debug = 4;
//		// fake ack signal
//		serital_data = 0;
//		#(4000*T); // 1 scl
//		serital_data = 1;
//		wait(status == 3'b001); // blue -> check ack 
	end
endmodule