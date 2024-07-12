module tswitch(
    input           rst_n,
    input           clk_system,
    input           clk_e1_base,
    input           clk_pcm_8k,

    //user terminal data interface
    input [7:0]     ui_pcm_rx_ch[30],
    output reg [7:0]    ui_pcm_tx_ch[30],

    //signaling upstream and downstream
    input [7:0]     signaling_rx,
    output [7:0]    signaling_tx,

    //E1 main interface
    output reg          e1_tx,
    input          e1_rx,

    //register interface, sync with clk_system
    output reg [7:0]    ctrl_reg_rdata,
    input [7:0]     ctrl_reg_wdata,
    input [7:0]     ctrl_reg_addr,
    input           ctrl_reg_rd,            //when ctrl_reg_rd = 1: read session, ctrl_reg_rd=0: write session
    input           ctrl_reg_en             //when ctrl_reg_en = 1: session enable
);


//time slot number:0:none, 1~30 time slot number, 31:signaling slot

/**
register definition
addr    |  bit definition       | function
---------------------------------------------------------------------------------------
0x00    |                       | control register(reserved, do not need implement)
0x01    |- - - a4 a3 a2 a1 a0   | user channel1(ui_pcm_xx_ch[0]) time slot selection
0x02    |- - - a4 a3 a2 a1 a0   | user channel2(ui_pcm_xx_ch[1]) time slot selection
.
.
.
0x1E    |- - - a4 a3 a2 a1 a0   | user channel30(ui_pcm_xx_ch[29]) time slot selection
0x1F    |                       | signaling register(reserved, do not need implement)
0x20    |                       | reserved
.
.
.
0xFF    |                       | reserved
*/
//EXAMPLE: implement ctrl register bank
reg [7:0] channel_sel_reg[30];                 //declare a register bank of 30 units for user channel(timeslot) select


integer i;
always @(clk_system) begin
    if (!rst_n) begin
        for(i=0;i<30;i=i+1) begin
            channel_sel_reg[i] <= 8'b00000000;
        end
    end
    else begin
        if(ctrl_reg_en && ctrl_reg_rd) begin    //read session
            case (ctrl_reg_addr)
                8'h01:  ctrl_reg_rdata <= channel_sel_reg[0];
                8'h02:  ctrl_reg_rdata <= channel_sel_reg[1];
                8'h03:  ctrl_reg_rdata <= channel_sel_reg[2] ;
                8'h04:  ctrl_reg_rdata <= channel_sel_reg[3] ;
                8'h05:  ctrl_reg_rdata <= channel_sel_reg[4] ;
                8'h06:  ctrl_reg_rdata <= channel_sel_reg[5] ;
                8'h07:  ctrl_reg_rdata <= channel_sel_reg[6] ;
                8'h08:  ctrl_reg_rdata <= channel_sel_reg[7] ;
                8'h09:  ctrl_reg_rdata <= channel_sel_reg[8] ;
                8'h0a:  ctrl_reg_rdata <= channel_sel_reg[9] ;
                8'h0b:  ctrl_reg_rdata <= channel_sel_reg[10] ;
                8'h0c:  ctrl_reg_rdata <= channel_sel_reg[11] ;
                8'h0d:  ctrl_reg_rdata <= channel_sel_reg[12] ;
                8'h0e:  ctrl_reg_rdata <= channel_sel_reg[13] ;
                8'h0f:  ctrl_reg_rdata <= channel_sel_reg[14] ;
                8'h10:  ctrl_reg_rdata <= channel_sel_reg[15] ;
                8'h11:  ctrl_reg_rdata <= channel_sel_reg[16] ;
                8'h12:  ctrl_reg_rdata <= channel_sel_reg[17] ;
                8'h13:  ctrl_reg_rdata <= channel_sel_reg[18] ;
                8'h14:  ctrl_reg_rdata <= channel_sel_reg[19] ;
                8'h15:  ctrl_reg_rdata <= channel_sel_reg[20] ;
                8'h16:  ctrl_reg_rdata <= channel_sel_reg[21] ;
                8'h17:  ctrl_reg_rdata <= channel_sel_reg[22] ;
                8'h18:  ctrl_reg_rdata <= channel_sel_reg[23] ;
                8'h19:  ctrl_reg_rdata <= channel_sel_reg[24] ;
                8'h1a:  ctrl_reg_rdata <= channel_sel_reg[25] ;
                8'h1b:  ctrl_reg_rdata <= channel_sel_reg[26] ;
                8'h1c:  ctrl_reg_rdata <= channel_sel_reg[27] ;
                8'h1d:  ctrl_reg_rdata <= channel_sel_reg[28];
                8'h1e:  ctrl_reg_rdata <= channel_sel_reg[29];
                default: assign ctrl_reg_rdata = 8'h00;
            endcase
        end
        else if (ctrl_reg_en && !ctrl_reg_rd) begin    //write session
            case (ctrl_reg_addr)
                8'h01:  channel_sel_reg[0] <= ctrl_reg_wdata;
                8'h02:  channel_sel_reg[1] <= ctrl_reg_wdata;
                8'h03:  channel_sel_reg[2] <= ctrl_reg_wdata;
                8'h04:  channel_sel_reg[3] <= ctrl_reg_wdata;
                8'h05:  channel_sel_reg[4] <= ctrl_reg_wdata;
                8'h06:  channel_sel_reg[5] <= ctrl_reg_wdata;
                8'h07:  channel_sel_reg[6] <= ctrl_reg_wdata;
                8'h08:  channel_sel_reg[7] <= ctrl_reg_wdata;
                8'h09:  channel_sel_reg[8] <= ctrl_reg_wdata;
                8'h0a:  channel_sel_reg[9] <= ctrl_reg_wdata;
                8'h0b:  channel_sel_reg[10] <= ctrl_reg_wdata;
                8'h0c:  channel_sel_reg[11] <= ctrl_reg_wdata;
                8'h0d:  channel_sel_reg[12] <= ctrl_reg_wdata;
                8'h0e:  channel_sel_reg[13] <= ctrl_reg_wdata;
                8'h0f:  channel_sel_reg[14] <= ctrl_reg_wdata;
                8'h10:  channel_sel_reg[15] <= ctrl_reg_wdata;
                8'h11:  channel_sel_reg[16] <= ctrl_reg_wdata;
                8'h12:  channel_sel_reg[17] <= ctrl_reg_wdata;
                8'h13:  channel_sel_reg[18] <= ctrl_reg_wdata;
                8'h14:  channel_sel_reg[19] <= ctrl_reg_wdata;
                8'h15:  channel_sel_reg[20] <= ctrl_reg_wdata;
                8'h16:  channel_sel_reg[21] <= ctrl_reg_wdata;
                8'h17:  channel_sel_reg[22] <= ctrl_reg_wdata;
                8'h18:  channel_sel_reg[23] <= ctrl_reg_wdata;
                8'h19:  channel_sel_reg[24] <= ctrl_reg_wdata;
                8'h1a:  channel_sel_reg[25] <= ctrl_reg_wdata;
                8'h1b:  channel_sel_reg[26] <= ctrl_reg_wdata;
                8'h1c:  channel_sel_reg[27] <= ctrl_reg_wdata;
                8'h1d:  channel_sel_reg[28] <= ctrl_reg_wdata;
                8'h1e:  channel_sel_reg[29] <= ctrl_reg_wdata;
            endcase
        end

    end
end


//TODO: implement exchange memory table
reg[7:0] SM_tx[32];     //  发送
reg[7:0] SM_rx[32];     //  接收

always@(posedge clk_pcm_8k) begin
    if(!rst_n) begin
        for(integer j = 0; j < 32; j = j + 1) begin
            SM_tx[j] <= 8'b00000000;
        end
    end
    else begin
        for(integer j = 0; j < 30; j = j + 1) begin
            SM_tx[channel_sel_reg[j]] <= ui_pcm_rx_ch[j];
            ui_pcm_tx_ch[j] <= SM_rx[j + 1];
        end
    end
end


//TODO: implement frame weaver(MUX) for E1 tx
integer tx_sel;
reg[7:0] e1_tx_parallel;
always@(*) begin
    if(!rst_n) begin
        e1_tx_parallel = 8'b00000000;
    end
    else begin
        e1_tx_parallel = SM_tx[tx_sel];
    end
end


//TODO: implement frame spliter(DEMUX) for E1 rx
reg rx_done;
integer rx_sel;
reg[7:0] e1_rx_parallel;
reg[7:0] e1_rx_parallel_tmp;
always@(*) begin
    if(!rst_n) begin
        for(integer j = 0; j < 32; j = j + 1) begin
            SM_rx[j] = 8'b00000000;
        end
    end
    else begin
        if(rx_done && rx_sel > 0 && rx_sel < 31) begin
            SM_rx[channel_sel_reg[rx_sel - 1]] = e1_rx_parallel_tmp;
            // $display("%d %d %d",rx_sel - 1,channel_sel_reg[rx_sel - 1], e1_rx_parallel_tmp);
        end
        else begin
            SM_rx[channel_sel_reg[rx_sel]] = SM_rx[channel_sel_reg[rx_sel]];
        end
    end
end

//TODO: implement E1 tx interface with parallel-to-serial converter
//Note: E1 use clk_e1_base clock @2.048MHz
integer tx_cnt;     //  发送bit计数
always@(posedge clk_e1_base) begin
    if(!rst_n) begin
        tx_sel <= 0;
        tx_cnt <= 0;
    end
    else begin
        if(tx_cnt == 7) begin
            if(tx_sel == 31) begin
                tx_sel <= 0;
            end
            else begin
                tx_sel <= tx_sel + 1;
            end
            tx_cnt <= 0;
        end
        else begin
            tx_cnt <= tx_cnt + 1;
            tx_sel <= tx_sel; 
        end
    end
end
assign e1_tx = e1_tx_parallel[tx_cnt];

//TODO: implement E1 rx interface with serial-to-parallel converter
integer rx_cnt;

//  移位寄存器
always@(posedge clk_e1_base)  begin 
    if(!rst_n) e1_rx_parallel = 8'b00000000;
    else e1_rx_parallel = {e1_rx, e1_rx_parallel[7:1]};
end

integer rx_byte_cnt;
always@(posedge clk_e1_base) begin
    if(!rst_n) begin
        rx_cnt <= 0;
        rx_sel <= 0;
        rx_done <= 0;
        rx_byte_cnt <= 0;
    end
    else begin
        if(rx_cnt == 7) begin
            if(rx_byte_cnt == 31) begin
                rx_byte_cnt <= 0;
            end
            else begin
                rx_byte_cnt <= rx_byte_cnt + 1;
            end
            rx_cnt <= 0;
            
            rx_done <= 1;
            //  每移位到8位时读出
            rx_sel <= rx_byte_cnt;
            e1_rx_parallel_tmp <= e1_rx_parallel;
        end
        else begin
            rx_done <= 0;
            rx_cnt <= rx_cnt + 1;
            rx_byte_cnt <= rx_byte_cnt;
            rx_sel <= rx_sel;
        end
    end
end


endmodule

