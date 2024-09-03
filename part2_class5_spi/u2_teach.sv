rst = 1'b1;
@(posedge clk);
rst = 1'b1;
// we start our transaction by making chip select (cs) low.
cs = 1'b0;
miso = 1'b0;

// we wait for one clock tick and then we start sending the data
@(posedge clk);
// we know that in our memory, the first bit we send will determine the type of operation.
// hence, miso is having the value of 1.
// this indicate the right transaction. (correct transaction)

// 1 for write, 0 for read
miso = 1'b1;

// sending the data
@(posedge clk);
for(int i=0; i<16; i++) begin
  miso = data[i];
  // send data in each clock edge
  @(posedge clk);
end

@(posedge op_done);


// ===================================================================
// read transaction
miso = 1'b0;

@(posedge clk);
// send address
for(int i=0; i<8; i++) begin
  miso = data[i];
  @(posedge clk);
end

@(posedge ready);

for(int i=0; i<8; i++) begin
  @(posedge clk);
  datard[i] = mosi;
end
// wait for our operation done
@(posedge op_done);
