//define task for writing registers

task write_t1_ctrl_reg(input bit [7:0] addr, input bit [7:0] data);
    @(negedge tb_top.clk_system);
    tb_top.t1_ctrl_reg_rd <= 0;
    tb_top.t1_ctrl_reg_en <= 1;
    tb_top.t1_ctrl_reg_addr <= addr;
    tb_top.t1_ctrl_reg_wdata <= data;

    @(negedge tb_top.clk_system);
    tb_top.t1_ctrl_reg_en <= 0;

endtask


task write_t2_ctrl_reg(input bit [7:0] addr, input bit [7:0] data);
    @(negedge tb_top.clk_system);
    tb_top.t2_ctrl_reg_rd <= 0;
    tb_top.t2_ctrl_reg_en <= 1;
    tb_top.t2_ctrl_reg_addr <= addr;
    tb_top.t2_ctrl_reg_wdata <= data;

    @(negedge tb_top.clk_system);
    tb_top.t2_ctrl_reg_en <= 0;

endtask
