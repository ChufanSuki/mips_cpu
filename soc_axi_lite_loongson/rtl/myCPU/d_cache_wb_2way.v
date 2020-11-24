module d_cache_2way (
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
    
    reg                 cache_valid [CACHE_DEEPTH - 1 : 0][1:0];
    reg                 cache_dirty [CACHE_DEEPTH - 1 : 0][1:0];
    reg                 cache_ru    [CACHE_DEEPTH - 1 : 0][1:0];
    reg [TAG_WIDTH-1:0] cache_tag   [CACHE_DEEPTH - 1 : 0][1:0];
    reg [31:0]          cache_block [CACHE_DEEPTH - 1 : 0][1:0];
    wire [OFFSET_WIDTH-1:0] offset;
    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;
    wire                 c_valid[1:0];
    wire                 c_dirty[1:0]; 
    wire                 c_ru   [1:0];
    wire [TAG_WIDTH-1:0] c_tag  [1:0];
    wire [31:0]          c_block[1:0];   
    wire hit, miss;   
    wire load, store;
    wire current_way;
    wire dirty, clean;
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
    reg [1:0] state;
    reg missed;
    assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];
    assign c_valid[0] = cache_valid[index][0];
    assign c_valid[1] = cache_valid[index][1];
    assign c_dirty[0] = cache_dirty[index][0];
    assign c_dirty[1] = cache_dirty[index][1];
    assign c_ru   [0] = cache_ru   [index][0];
    assign c_ru   [1] = cache_ru   [index][1];
    assign c_tag  [0] = cache_tag  [index][0];
    assign c_tag  [1] = cache_tag  [index][1];
    assign c_block[0] = cache_block[index][0];
    assign c_block[1] = cache_block[index][1];
    assign hit = c_valid[0] & (c_tag[0] == tag) | c_valid[1] & (c_tag[1] == tag);
    assign miss = ~hit;
    assign current_way = hit ? (c_valid[0] & (c_tag[0] == tag) ? 1'b0 : 1'b1) : 
                   c_ru[0] ? 1'b1 : 1'b0; 
    assign store = cpu_data_wr;
    assign load = cpu_data_req & ~store;
    assign dirty = c_dirty[current_way];
    assign clean = ~dirty;


    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            missed <= 1'b0;
        end
        else begin
            case(state)
                IDLE: begin
                    if (cpu_data_req) begin
                        if (hit) 
                            state <= IDLE;
                        else if (miss & dirty)
                            state <= WM;
                        else if (miss & clean)
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
            endcase
        end
    end

    wire isRM;  
    reg addr_rcv;    
    wire read_finish;   
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    cache_data_req & isRM & cache_data_addr_ok ? 1'b1 :
                    read_finish ? 1'b0 : 
                    addr_rcv;
    end
    assign isRM = state==RM;
    assign read_finish = isRM & cache_data_data_ok;

    wire isWM;   
    reg waddr_rcv;    
    wire write_finish; 
    always @(posedge clk) begin
        waddr_rcv <= rst ? 1'b0 :
                     cache_data_req& isWM & cache_data_addr_ok ? 1'b1 :
                     write_finish ? 1'b0 :
                     waddr_rcv;
    end
    assign isWM = state==WM;
    assign write_finish = isWM & cache_data_data_ok;

    assign cpu_data_rdata   = hit ? c_block[current_way] : cache_data_rdata; 
    assign cpu_data_addr_ok = cpu_data_req & hit | cache_data_req & isRM & cache_data_addr_ok;
    assign cpu_data_data_ok = cpu_data_req & hit | isRM & cache_data_data_ok;
    assign cache_data_req   = isRM & ~addr_rcv | isWM & ~waddr_rcv;
    assign cache_data_wr    = isWM;
    assign cache_data_size  = cpu_data_size;
    assign cache_data_addr  = cache_data_wr ? {c_tag[current_way], index, offset}:
                                              cpu_data_addr;
    assign cache_data_wdata = c_block[current_way];

    reg [TAG_WIDTH-1:0] tag_save;
    reg [INDEX_WIDTH-1:0] index_save;
    
    always @(posedge clk) begin
        tag_save   <= rst ? 0 :
                      cpu_data_req ? tag : tag_save;
        index_save <= rst ? 0 :
                      cpu_data_req ? index : index_save;
    end

    wire [31:0] write_cache_data;
    wire [3:0] write_mask;
    assign write_mask = cpu_data_size==2'b00 ?
                            (cpu_data_addr[1] ? (cpu_data_addr[0] ? 4'b1000 : 4'b0100):
                                                (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
                            (cpu_data_size==2'b01 ? (cpu_data_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111);
    assign write_cache_data = cache_block[index][current_way] & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} | 
                              cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

    wire isIDLE = state==IDLE;

    integer t, y;
    always @(posedge clk) begin
        if(rst) begin
            for(t=0; t<CACHE_DEEPTH; t=t+1) begin 
                for (y = 0; y<2; y=y+1) begin
                    cache_valid[t][y] <= 0;
                    cache_dirty[t][y] <= 0;
                    cache_ru   [t][y] <= 0;
                end
            end
        end
        else begin
            if(read_finish) begin 
                cache_valid[index_save][current_way] <= 1'b1;           
                cache_dirty[index_save][current_way] <= 1'b0; 
                cache_tag  [index_save][current_way] <= tag_save;
                cache_block[index_save][current_way] <= cache_data_rdata; 
            end
            else if (store & isIDLE & (hit | missed)) begin 
                cache_dirty[index][current_way] <= 1'b1; 
                cache_block[index][current_way] <= write_cache_data;      
            end

            if ((load | store) & isIDLE & (hit | missed)) begin
                cache_ru[index][current_way]   <= 1'b1;
                cache_ru[index][1-current_way] <= 1'b0; 
            end
        end
    end
endmodule
