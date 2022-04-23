`timescale 1ns / 1ps

module kuznechik_cipher_apb_wrapper(
    input           pclk_i,
                    presetn_i,
                    pprot_i,                //unused
                    psel_i,
                    penable_i,
                    pwrite_i,
            [31:0]  paddr_i,
            [31:0]  pwdata_i,
            [3:0]   pstrb_i,
                    
    output    reg        pready_o,
              reg [31:0] prdata_o,
              wire        pslverr_o
    );
    
    wire apb_write = psel_i &  pwrite_i & penable_i;
    wire apb_read  = psel_i  & ~pwrite_i;
    wire valid;
    wire ack;
    wire [127:0] data_o;
    reg [7:0] memory [0:35];
    wire [127:0] data_in;

    
    assign pslverr_o = ((paddr_i <= 'h23) && (paddr_i >= 'h14) || (paddr_i == 32'b0 && (pstrb_i[3] || pstrb_i[2]))) && pwrite_i;
    
    assign data_in[127:120]=memory['h13];
    assign data_in[119:112]=memory['h12];
    assign data_in[111:104]=memory['h11];
    assign data_in[103:96]=memory['h10];
    assign data_in[95:88]=memory['hF];
    assign data_in[87:80]=memory['hE];
    assign data_in[79:72]=memory['hD];
    assign data_in[71:64]=memory['hC];
    assign data_in[63:56]=memory['hB];
    assign data_in[55:48]=memory['hA];
    assign data_in[47:40]=memory['h9];
    assign data_in[39:32]=memory['h8];
    assign data_in[31:24]=memory['h7];
    assign data_in[23:16]=memory['h6];
    assign data_in[15:8]=memory['h5];
    assign data_in[7:0]=memory['h4];
        
        
    kuznechik_cipher DUT(
        .clk_i      (pclk_i),
        .resetn_i   (presetn_i & memory[0][0]),
        .data_i     (data_in),
        .request_i  (memory[1]),
        .ack_i      (memory[1]),
        .data_o     (data_o),
        .valid_o    (valid),
        .busy_o     (busy)
    );
    
    
    initial begin 
       $readmemh("C:/Users/liokh/Desktop/mpsis/kuznetchik/rtl/APB_init.txt", memory);
    end
    
    always @(posedge pclk_i)
    begin
         memory['h2]<=valid;
         memory['h3]<=busy;
         if(valid) begin
              memory['h23]<=data_o[127:120];
              memory['h22]<=data_o[119:112];
              memory['h21]<=data_o[111:104];
              memory['h20]<=data_o[103:96];
              memory['h1F]<=data_o[95:88];
              memory['h1E]<=data_o[87:80];
              memory['h1D]<=data_o[79:72];
              memory['h1C]<=data_o[71:64];
              memory['h1B]<=data_o[63:56];
              memory['h1A]<=data_o[55:48];
              memory['h19]<=data_o[47:40];
              memory['h18]<=data_o[39:32];
              memory['h17]<=data_o[31:24];
              memory['h16]<=data_o[23:16];
              memory['h15]<=data_o[15:8];
              memory['h14]<=data_o[7:0];
            end                        
        if (!presetn_i) begin
           $readmemh("C:/Users/liokh/Desktop/mpsis/kuznetchik/rtl/APB_init.txt", memory);
        end
        else begin
            pready_o<=penable_i;
           
               if(apb_write) begin
                 if(paddr_i=='h4 || paddr_i=='h8 || paddr_i=='hC || paddr_i=='h10) begin
                    memory[paddr_i]['d0]<=pwdata_i[0];
                    memory[paddr_i]['d1]<=pwdata_i[1];
                    memory[paddr_i]['d2]<=pwdata_i[2];
                    memory[paddr_i]['d3]<=pwdata_i[3];
                    memory[paddr_i]['d4]<=pwdata_i[4];
                    memory[paddr_i]['d5]<=pwdata_i[5];
                    memory[paddr_i]['d6]<=pwdata_i[6];
                    memory[paddr_i]['d7]<=pwdata_i[7];
                    
                    memory[paddr_i+'d1]['d0]<=pwdata_i[8];
                    memory[paddr_i+'d1]['d1]<=pwdata_i[9];
                    memory[paddr_i+'d1]['d2]<=pwdata_i[10];
                    memory[paddr_i+'d1]['d3]<=pwdata_i[11];
                    memory[paddr_i+'d1]['d4]<=pwdata_i[12];
                    memory[paddr_i+'d1]['d5]<=pwdata_i[13];
                    memory[paddr_i+'d1]['d6]<=pwdata_i[14];
                    memory[paddr_i+'d1]['d7]<=pwdata_i[15];
                    
                    memory[paddr_i+'d2]['d0]<=pwdata_i[16];
                    memory[paddr_i+'d2]['d1]<=pwdata_i[17];
                    memory[paddr_i+'d2]['d2]<=pwdata_i[18];
                    memory[paddr_i+'d2]['d3]<=pwdata_i[19];
                    memory[paddr_i+'d2]['d4]<=pwdata_i[20];
                    memory[paddr_i+'d2]['d5]<=pwdata_i[21];
                    memory[paddr_i+'d2]['d6]<=pwdata_i[22];
                    memory[paddr_i+'d2]['d7]<=pwdata_i[23];
                    
                    memory[paddr_i+'d3]['d0]<=pwdata_i[24];
                    memory[paddr_i+'d3]['d1]<=pwdata_i[25];
                    memory[paddr_i+'d3]['d2]<=pwdata_i[26];
                    memory[paddr_i+'d3]['d3]<=pwdata_i[27];
                    memory[paddr_i+'d3]['d4]<=pwdata_i[28];
                    memory[paddr_i+'d3]['d5]<=pwdata_i[29];
                    memory[paddr_i+'d3]['d6]<=pwdata_i[30];
                    memory[paddr_i+'d3]['d7]<=pwdata_i[31];
                end
                else if(paddr_i=='h0) begin
                    if(pstrb_i[0]=='b1) memory[0] <= pwdata_i[7:0];
                        else if(pstrb_i[0]=='b0) memory[0]<=8'b0;
                    if(pstrb_i[1]=='b1) memory[1] <= pwdata_i[15:8];
                        else if(pstrb_i[1]=='b0) memory[1]<=8'b0;
                end
             end 
            else if(apb_read) begin             
                      prdata_o[7:0]     <= memory[paddr_i];
                      prdata_o[15:8]    <= memory[paddr_i + 'h1];
                      prdata_o[23:16]   <= memory[paddr_i + 'h2];
                      prdata_o[31:24]   <= memory[paddr_i + 'h3];
                end
            end       
      end   
endmodule
