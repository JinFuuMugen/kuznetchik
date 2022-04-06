`define IDDLE_phase 'd1
`define KEY_phase 'd2
`define S_phase 'd3
`define L_phase 'd4
`define FINISH_phase 'd5

module kuznechik_cipher(
    input               clk_i,      // Тактовый сигнал
                        resetn_i,   // Синхронный сигнал сброса с активным уровнем LOW
                        request_i,  // Сигнал запроса на начало шифрования
                        ack_i,      // Сигнал подтверждения приема зашифрованных данных
                [127:0] data_i,     // Шифруемые данные

    output              busy_o,     // Сигнал, сообщающий о невозможности приёма
                                    // очередного запроса на шифрование, поскольку
                                    // модуль в процессе шифрования предыдущего
                                    // запроса
           reg          valid_o,    // Сигнал готовности зашифрованных данных
           reg  [127:0] data_o      // Зашифрованные данные
);

reg [127:0] key_mem [0:9];

reg [7:0] S_box_mem [0:255];

reg [7:0] L_mul_16_mem  [0:255];
reg [7:0] L_mul_32_mem  [0:255];
reg [7:0] L_mul_133_mem [0:255];
reg [7:0] L_mul_148_mem [0:255];
reg [7:0] L_mul_192_mem [0:255];
reg [7:0] L_mul_194_mem [0:255];
reg [7:0] L_mul_251_mem [0:255];


reg [2:0] STATE;
assign busy_o = !(STATE == `IDDLE_phase || STATE == `FINISH_phase) || ((request_i == 1) && (STATE == `IDDLE_phase || STATE == `FINISH_phase));
reg [3:0] keyIndex;

reg [7:0] lShiftByte;
reg [3:0] lPhaseFlag;


initial begin
    $readmemh("keys.mem",key_mem );
    $readmemh("S_box.mem",S_box_mem );

    $readmemh("L_16.mem", L_mul_16_mem );
    $readmemh("L_32.mem", L_mul_32_mem );
    $readmemh("L_133.mem",L_mul_133_mem);
    $readmemh("L_148.mem",L_mul_148_mem);
    $readmemh("L_192.mem",L_mul_192_mem);
    $readmemh("L_194.mem",L_mul_194_mem);
    $readmemh("L_251.mem",L_mul_251_mem);
    
    STATE<= `IDDLE_phase;
end

always @(posedge clk_i)
begin
    if(!resetn_i)                           //rst check
    begin
        lPhaseFlag <= 'd0;
        keyIndex <= 'd0;
        lShiftByte <= 'h0;
        data_o  <= 'h0;
        valid_o <= 'b0;
        STATE<=`IDDLE_phase;
    end
        end
  always @(posedge clk_i) begin
  if (resetn_i) begin
        case(STATE)
            `IDDLE_phase: begin 
                            if(request_i) begin
                                data_o<=data_i;
                                STATE<=`KEY_phase;
                            end
                          end
            `KEY_phase: begin
                          data_o<=key_mem[keyIndex]^data_o;   //each bit xor for 9 rounds 
                          if(keyIndex=='d9) begin                    //jump to finish after 9 full itterations
                            valid_o<='b1;                           //and 1 short    
                            STATE<=`FINISH_phase;
                            keyIndex <='d0;
                          end
                          else STATE<=`S_phase;
                        end
            `S_phase: begin                                         //byte changes
                       
                        data_o[127:120] <= S_box_mem[data_o[127:120]];
                        data_o[119:112] <= S_box_mem [data_o[119:112]];
                        data_o[111:104] <= S_box_mem[data_o[111:104]];
                        data_o[103:96]  <= S_box_mem[data_o[103:96]];
                        data_o[95:88]   <= S_box_mem[data_o[95:88]];
                        data_o[87:80]   <= S_box_mem[data_o[87:80]];
                        data_o[79:72]   <= S_box_mem[data_o[79:72]];
                        data_o[71:64]   <= S_box_mem[data_o[71:64]];
                        data_o[63:56]   <= S_box_mem[data_o[63:56]];
                        data_o[55:48]   <= S_box_mem[data_o[55:48]];
                        data_o[47:40]   <= S_box_mem[data_o[47:40]];
                        data_o[39:32]   <= S_box_mem[data_o[39:32]];
                        data_o[31:24]   <= S_box_mem[data_o[31:24]];
                        data_o[23:16]   <= S_box_mem[data_o[23:16]];
                        data_o[15:8]    <= S_box_mem[data_o[15:8]];
                        data_o[7:0]     <= S_box_mem[data_o[7:0]];
                        STATE<=`L_phase;
                      end
            `L_phase: begin 
                        if(lPhaseFlag=='d15) begin
                            lPhaseFlag<='d0;
                            STATE <=`KEY_phase;
                            keyIndex<=keyIndex+'d1;
                            lShiftByte<='h0;
                         end
                         else                                 
                                  lPhaseFlag<=lPhaseFlag+'d1;
                                 
                                         //linear changes 16 times
                                  lShiftByte = lShiftByte ^ L_mul_148_mem[data_o[127:120]]
                                  ^ L_mul_32_mem [data_o[119:112]]
                                  ^ L_mul_133_mem[data_o[111:104]]
                                  ^ L_mul_16_mem [data_o[103:96]]
                                  ^ L_mul_194_mem[data_o[95:88]]
                                  ^ L_mul_192_mem[data_o[87:80]]
                                  ^ data_o[79:72]
                                  ^ L_mul_251_mem[data_o[71:64]]
                                  ^ data_o[63:56]
                                  ^ L_mul_192_mem[data_o[55:48]]
                                  ^ L_mul_194_mem[data_o[47:40]]
                                  ^ L_mul_16_mem [data_o[39:32]]
                                  ^ L_mul_133_mem[data_o[31:24]]
                                  ^ L_mul_32_mem [data_o[23:16]]
                                  ^ L_mul_148_mem[data_o[15:8]]
                                  ^ data_o[7:0];
                        data_o <= data_o >> 8;
                        data_o[127:120] <= lShiftByte;
                        lShiftByte <='h0;
                       end
            `FINISH_phase: begin
                             if (request_i) begin
                                STATE <= `KEY_phase;
                                data_o <= data_i;
                                valid_o <= 1'b0;
                             end
                             else begin
                                if (ack_i) begin
                                    STATE <= `IDDLE_phase;
                                    valid_o <= 1'b0;
                                end
                            end
                          end
        endcase
    end
end
endmodule
