module d_cache_write_back_4way_fakeLRU (
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
    parameter  INDEX_WIDTH  = 10, OFFSET_WIDTH = 2;
    localparam TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
    localparam CACHE_DEEPTH = 1 << INDEX_WIDTH;
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
    //-----------------Internal Signals------------------------
    reg                 cache_valid [CACHE_DEEPTH - 1 : 0][3:0];
    reg                 cache_dirty [CACHE_DEEPTH - 1 : 0][3:0];
    reg [TAG_WIDTH-1:0] cache_tag   [CACHE_DEEPTH - 1 : 0][3:0];
    reg [31:0]          cache_block [CACHE_DEEPTH - 1 : 0][3:0];
    reg [2:0]           tree_table  [CACHE_DEEPTH - 1 : 0];
   // tree[3] -> tree[1]
   //        -> tree[2]
    wire [2:0] tree;
    wire [OFFSET_WIDTH-1:0] offset;
    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;
    wire                 c_valid[3:0];
    wire                 c_dirty[3:0];
    wire [TAG_WIDTH-1:0] c_tag  [3:0];
    wire [31:0]          c_block[3:0];
    wire hit, miss;
    wire [1:0] current_way;
    wire store;
    wire dirty;
    wire clean;
    reg [1:0] state;
    reg missed;
    wire isRM; 
    reg addr_rcv;  
    wire read_finish; 
    wire isWM; 
    reg waddr_rcv;   
    wire write_finish; 
    wire isIDLE;
    integer t, y;
    wire [31:0] write_cache_data;
    wire [3:0] write_mask;
    reg [TAG_WIDTH-1:0] tag_save;
    reg [INDEX_WIDTH-1:0] index_save; 
    wire loaded;
    //-----------------------------------------------------
    assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];
    assign c_valid[0] = cache_valid[index][0];
    assign c_valid[1] = cache_valid[index][1];
    assign c_valid[2] = cache_valid[index][2];
    assign c_valid[3] = cache_valid[index][3];
    assign c_dirty[0] = cache_dirty[index][0];
    assign c_dirty[1] = cache_dirty[index][1];
    assign c_dirty[2] = cache_dirty[index][2];
    assign c_dirty[3] = cache_dirty[index][3];
    assign c_tag  [0] = cache_tag  [index][0];
    assign c_tag  [1] = cache_tag  [index][1];
    assign c_tag  [2] = cache_tag  [index][2];
    assign c_tag  [3] = cache_tag  [index][3];
    assign c_block[0] = cache_block[index][0];
    assign c_block[1] = cache_block[index][1];
    assign c_block[2] = cache_block[index][2];
    assign c_block[3] = cache_block[index][3];
    assign tree = tree_table[index];
    assign hit = (c_valid[0] && (c_tag[0] == tag)) || 
                 (c_valid[1] && (c_tag[1] == tag)) ||
                 (c_valid[2] && (c_tag[2] == tag)) ||
                 (c_valid[3] && (c_tag[3] == tag));
    assign miss = ~hit;
    assign current_way = hit ? (c_valid[0] && (c_tag[0] == tag) ? 2'b00 :
                          c_valid[1] && (c_tag[1] == tag) ? 2'b01 :
                          c_valid[2] && (c_tag[2] == tag) ? 2'b10 :
                          2'b11) : 
                   tree[2] ? {tree[2], tree[0]} :
                             {tree[2], tree[1]}; 
    assign store = cpu_data_wr;
    assign loaded = cpu_data_req && ~store; // FIXME
    assign dirty = c_dirty[current_way];
    assign clean = ~dirty;
    assign isWM = state == WM;
    assign isIDLE = state == IDLE;
    assign write_finish = isWM & cache_data_data_ok;
    assign cpu_data_rdata   = hit ? c_block[current_way] : cache_data_rdata;
    assign cpu_data_addr_ok = cpu_data_req & hit | cache_data_req & isRM & cache_data_addr_ok;
    assign isRM = state==RM;
    assign read_finish = isRM & cache_data_data_ok;
    assign cpu_data_data_ok = cpu_data_req & hit | isRM & cache_data_data_ok;
    assign cache_data_req   = isRM & ~addr_rcv | isWM & ~waddr_rcv;
    assign cache_data_wr    = isWM;
    assign cache_data_size  = cpu_data_size;
    assign cache_data_addr  = cache_data_wr ? {c_tag[current_way], index, offset}:
                                              cpu_data_addr;
    assign cache_data_wdata = c_block[current_way];
    assign write_mask = cpu_data_size==2'b00 ?
                            (cpu_data_addr[1] ? (cpu_data_addr[0] ? 4'b1000 : 4'b0100):
                                                (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
                            (cpu_data_size==2'b01 ? (cpu_data_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111);
    assign write_cache_data = cache_block[index][current_way] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} | 
                              cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};
                              
    always @(posedge clk, posedge rst) begin
      if(rst) begin
         state <= IDLE;
         missed <= 1'b0;
         tag_save <= 0;
         index_save <= 0;
         addr_rcv <= 0;
         waddr_rcv <= 0;
         for(t=0; t<CACHE_DEEPTH; t=t+1) begin 
             for (y = 0; y<4; y=y+1) begin
                 cache_valid[t][y] <= 0;
                 cache_dirty[t][y] <= 0;  
             end
             tree_table[t] <= 3'b000;
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
              cache_valid[index_save][current_way] <= 1'b1;      
              cache_dirty[index_save][current_way] <= 1'b0; 
              cache_tag  [index_save][current_way] <= tag_save;
              cache_block[index_save][current_way] <= cache_data_rdata;
          end
          else if (store & isIDLE & (hit | missed)) begin 
              cache_dirty[index][current_way] <= 1'b1; 
              cache_block[index][current_way] <= write_cache_data;
          end
         if ((hit || missed) && isIDLE && (loaded || store)) begin
              if (current_way[1] == 1'b0)
                  {tree_table[index][2], tree_table[index][1]} <= ~current_way;
              else
                  {tree_table[index][2], tree_table[index][0]} <= ~current_way;
          end
      end
   end // always @ (posedge clk)
endmodule
   
