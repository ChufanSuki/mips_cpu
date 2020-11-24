module d_cache_write_back (
    input wire clk, rst,
    //mips core
    input         cpu_data_req     ,
    input         cpu_data_wr      ,
    input  [1 :0] cpu_data_size    ,
    input  [31:0] cpu_data_addr    ,
    input  [31:0] cpu_data_wdata   ,
    output [31:0] cpu_data_rdata   ,
    output        cpu_data_addr_ok ,
    output        cpu_data_data_ok ,

    //axi interface
    output         cache_data_req     ,
    output         cache_data_wr      ,
    output  [1 :0] cache_data_size    ,
    output  [31:0] cache_data_addr    ,
    output  [31:0] cache_data_wdata   ,
    input   [31:0] cache_data_rdata   ,
    input          cache_data_addr_ok ,
    input          cache_data_data_ok
);
   //-----------------Cache Parameter------------------------
   parameter INDEX_WIDTH  = 10;
   parameter OFFSET_WIDTH = 2;
   localparam TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
   localparam CACHE_DEEPTH = 1 << INDEX_WIDTH;
   parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
   // Each line is 1 word
   //-----------------Internal Signals-----------------------
   reg             cache_valid[CACHE_DEEPTH - 1 : 0];
   reg             cache_dirty[CACHE_DEEPTH - 1 : 0];
   reg [TAG_WIDTH-1:0] cache_tag[CACHE_DEEPTH - 1 : 0];
   reg [31:0]          cache_block[CACHE_DEEPTH - 1 : 0];
   wire [OFFSET_WIDTH-1:0] offset;
   wire [INDEX_WIDTH-1:0]  index;
   wire [TAG_WIDTH-1:0]    tag;
   wire                  c_valid;
   wire                  c_dirty;
   wire [TAG_WIDTH-1:0]  c_tag;
   wire [31:0]           c_block;
   wire                  hit;
   wire                  miss;
//   wire                  load;
   wire                  store;
   wire                  dirty;
   wire                  clean;
   reg [1:0]             state;
   reg                   missed;
   wire                  isRM;
   wire                  isIDLE;
   reg                   addr_rcv;     
   wire                  read_finish;   
   wire                  isWM;
   reg                   waddr_rcv;
   wire                  write_finish;
   reg [TAG_WIDTH-1:0]   tag_save;
   reg [INDEX_WIDTH-1:0] index_save;
   wire [31:0]           write_cache_data;
   wire [3:0]            write_mask;
   integer               t;
   //--------------------------------------------------------
   assign isIDLE = (state == IDLE);
   assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
   assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
   assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];
   assign c_valid = cache_valid[index];
   assign c_dirty = cache_dirty[index];
   assign c_tag   = cache_tag  [index];
   assign c_block = cache_block[index];
   assign hit = c_valid && (c_tag == tag);
   assign miss = ~hit;
   assign store = cpu_data_wr;
   assign dirty = c_dirty;
   assign clean = ~dirty;
   assign isRM = state == RM;
   assign read_finish = isRM && cache_data_data_ok;
   assign isWM = state == WM;
   assign write_finish = isWM && cache_data_data_ok;
   assign cpu_data_rdata = hit ? c_block : cache_data_rdata;
   assign cpu_data_addr_ok = (cpu_data_req && hit) || (cache_data_req && isRM && cache_data_addr_ok);
   assign cpu_data_data_ok = (cpu_data_req && hit) || (isRM && cache_data_data_ok);
   assign cache_data_req = (isRM && ~addr_rcv) || (isWM && ~waddr_rcv);
   assign cache_data_wr = isWM;
   assign cache_data_size = cpu_data_size;
   assign cache_data_addr = cache_data_wr ? {c_tag, index, offset} : cpu_data_addr;
   assign cache_data_wdata = c_block;
   assign write_mask = cpu_data_size==2'b00 ?
                            (cpu_data_addr[1] ? (cpu_data_addr[0] ? 4'b1000 : 4'b0100):
                                                (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
                            (cpu_data_size==2'b01 ? (cpu_data_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111);
   assign write_cache_data = cache_block[index] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} |
                             cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};
   //------------------------------------------------------------
   always @(posedge clk, posedge rst) begin
      if(rst) begin
         state <= IDLE;
         missed <= 1'b0;
         tag_save <= 0;
         index_save <= 0;
         addr_rcv <= 0;
         waddr_rcv <= 0;
         for (t = 0; t < CACHE_DEEPTH; t = t +1) begin
            cache_valid[t] <= 0;
            cache_dirty[t] <= 0;
         end
      end
      else begin
         case(state)
           IDLE: begin
              if (cpu_data_req) begin
                 if (hit)
                   state <= IDLE;
                 else if (miss && dirty)
                   state <= WM;
                 else if (miss && clean)
                   state <= RM;
              end
              missed <= 1'b0;
           end
           WM: begin
              if (cache_data_data_ok)
                state <= RM;
           end
           RM: begin
              if (cache_data_data_ok)
                state <= IDLE;
              missed <= 1'b1;
           end
         endcase // case (state)

         addr_rcv <= (cache_data_req && isRM && cache_data_addr_ok) ? 1'b1 :
                     read_finish ? 1'b0 : addr_rcv;
         waddr_rcv <= (cache_data_req && isWM && cache_data_addr_ok) ? 1'b1 :
                      write_finish ? 1'b0 : waddr_rcv;
         tag_save <= cpu_data_req ? tag : tag_save;
         index_save <= cpu_data_req ? index : index_save;
         if (read_finish) begin
            cache_valid[index_save] <= 1'b1;
            cache_dirty[index_save] <= 1'b0;
            cache_tag[index_save] <= tag_save;
            cache_block[index_save] <= cache_data_rdata;
         end
         else if ((hit || missed) && store && isIDLE) begin
            cache_dirty[index] <= 1'b1;
            cache_block[index] <= write_cache_data;
         end
      end
   end // always @ (posedge clk)

   // addr_rcv is set when the cache data address (from axi) is ok
   // and is clear when reset or after read finished. It is tied 1 when the cache is reading on memory.
endmodule
