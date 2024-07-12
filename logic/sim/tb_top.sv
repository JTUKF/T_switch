`timescale 1ns/100ps

`include "reg_op.sv"

`define SIMULATION_TIME 100ms
`define MAIN_CLK_PERIOD 244140ps        //main clock frequecy = 4.096MHz
`define RESET_DELAY 1us

`define USER_INTF_SRC_PORT  0           //port to feed pcm data
`define PCM_BUF_LEN 256

module tb_top();

    reg clk_pcm_8k;                //clock for pcm interface @8kHz
    reg clk_e1_base;            //clock for e1 interface @2.048MHz
    reg clk_system;             //clock for system @4.096MHz
    reg rst_n;

    //user interface signals -terminal1
    wire [7:0] ui1_pcm_tx[30];
    reg [7:0] ui1_pcm_rx[30];


    //user interface signals -terminal2
    wire [7:0] ui2_pcm_tx[30];
    reg [7:0] ui2_pcm_rx[30];

    //SDH E1 main line
    wire t1_to_t2;
    wire t2_to_t1;  

    //ctrl register interface
    reg [7:0]   t1_ctrl_reg_addr;
    reg [7:0]   t1_ctrl_reg_wdata;
    wire [7:0]  t1_ctrl_reg_rdata;
    reg         t1_ctrl_reg_rd;
    reg         t1_ctrl_reg_en;

    //ctrl register interface
    reg [7:0]   t2_ctrl_reg_addr;
    reg [7:0]   t2_ctrl_reg_wdata;
    wire [7:0]  t2_ctrl_reg_rdata;
    reg         t2_ctrl_reg_rd;
    reg         t2_ctrl_reg_en;



//system function for dumping signals
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_top,
                 tb_top.ui1_pcm_rx[0], tb_top.ui2_pcm_tx[6],
                 tb_top.ui1_pcm_rx[1], tb_top.ui2_pcm_tx[7]);

end

//simulation time
initial begin
    #`SIMULATION_TIME $finish;
end

//generating initial state and reset signal
initial begin
    clk_system <= 0;
    clk_pcm_8k <= 0;
    clk_e1_base <= 0;
    rst_n <= 0;
    #`RESET_DELAY;
    t1_ctrl_reg_rd <= 0;
    t1_ctrl_reg_en <= 0;
    t1_ctrl_reg_addr <= 8'h00;
    t1_ctrl_reg_wdata <= 8'h00;
    t2_ctrl_reg_rd <= 0;
    t2_ctrl_reg_en <= 0;
    t2_ctrl_reg_addr <= 8'h00;
    t2_ctrl_reg_wdata <= 8'h00;

    rst_n <= 1;   

    #100ns;
    write_t1_ctrl_reg(8'h01, 8'h12);
    #100ns;
    write_t2_ctrl_reg(8'h12, 8'h07);

    #100ns;
    write_t1_ctrl_reg(8'h02, 8'h13);
    #100ns;
    write_t2_ctrl_reg(8'h13, 8'h08);

end

//generating system clock
always 
begin
    #(`MAIN_CLK_PERIOD/2)  clk_system <= ~clk_system;   
end

//generating e1 base clock(2.048MHz)
always @(posedge clk_system) begin
    clk_e1_base <= ~clk_e1_base;
end


//generating time slot clock(8kHz)
reg [7:0]   clk_cnt;

always @(posedge clk_e1_base) begin
    if (rst_n == 0) begin
        clk_cnt <= 8'b00000000;
    end
    else begin
        clk_cnt <= clk_cnt +1; 
        clk_pcm_8k <= clk_cnt[7];
    end

end

//read data from file to send through ui1_pcm_rx
int i;
reg [7:0] pcm_data[`PCM_BUF_LEN];
initial begin
    $readmemh("./input.txt", pcm_data, 0, `PCM_BUF_LEN-1);
    i=0;
    
end

always @(posedge clk_pcm_8k) begin
        ui1_pcm_rx[`USER_INTF_SRC_PORT] <= pcm_data[i];
        ui1_pcm_rx[`USER_INTF_SRC_PORT + 1] <= pcm_data[i] + 1;
        if(i<`PCM_BUF_LEN) begin
            i=i+1;
        end
        else begin
            i=0;
        end
    end

//instance of your t-switch module
tswitch sw1(
    .rst_n          (rst_n),
    .clk_system     (clk_system),
    .clk_e1_base    (clk_e1_base),
    .clk_pcm_8k     (clk_pcm_8k),

    .ui_pcm_rx_ch   (ui1_pcm_rx),         //
    .ui_pcm_tx_ch   (ui1_pcm_tx),

    .signaling_rx   (),
    .signaling_tx   (),

    .e1_tx          (t1_to_t2),
    .e1_rx          (t2_to_t1),

    .ctrl_reg_rdata (t1_ctrl_reg_rdata),
    .ctrl_reg_wdata (t1_ctrl_reg_wdata),
    .ctrl_reg_addr  (t1_ctrl_reg_addr),
    .ctrl_reg_rd    (t1_ctrl_reg_rd),
    .ctrl_reg_en    (t1_ctrl_reg_en)
);


tswitch sw2(
    .rst_n          (rst_n),
    .clk_system     (clk_system),
    .clk_e1_base    (clk_e1_base),
    .clk_pcm_8k     (clk_pcm_8k),

    .ui_pcm_rx_ch   (ui2_pcm_rx),
    .ui_pcm_tx_ch   (ui2_pcm_tx),

    .signaling_rx   (),
    .signaling_tx   (),

    .e1_tx          (t2_to_t1),
    .e1_rx          (t1_to_t2),

    .ctrl_reg_rdata (t2_ctrl_reg_rdata),
    .ctrl_reg_wdata (t2_ctrl_reg_wdata),
    .ctrl_reg_addr  (t2_ctrl_reg_addr),
    .ctrl_reg_rd    (t2_ctrl_reg_rd),
    .ctrl_reg_en    (t2_ctrl_reg_en)
);

endmodule
