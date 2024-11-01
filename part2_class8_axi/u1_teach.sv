input awvalid,       // master is sending new address
output reg awready,  // slave is ready to accept request
input [3:0] awid,    // unique ID for each transaction
input [3:0] alen,    // burst length AXI3: 1 to 16, AXI4: 1 to 256
input [2:0] asize,   // unique transaction size: 1, 2, 4, 8, 16..., 128 bytes
input [31:0] awaddr, // write address of transaction
input [1:0] aburst,  // burst type: fixed, INCR, WRAP


input wvalid,       // master is sending new data
output reg wready,  // slave is ready to accept new data
input [3:0] wid,    // unique id for transaction
input [31:0] wdata, // data
input [3:0] wstrb,  // lane having valid data
input wlast,        // last transfer in write burst


input bready,           // master is ready to accept response
output reg bvalid,      // slave has valid response
output reg [3:0] bid,   // unique id for transaction
output reg [1:0] bresp, // status of write transaction

