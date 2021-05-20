`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/18 08:38:52
// Design Name: 
// Module Name: mips
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mips(
    input  logic        clk, reset,
    output logic        memwrite,
    input  logic [31:0] readdata,
    output logic [31:0] adr, b
    );

    logic zero, pcwrite, irwrite, regwrite, alusrca, branch, iord;
    logic [1:0] alusrcb, pcsrc, regdst, memtoreg;
    logic [2:0] alucontrol;
    logic [31:0] instr;

    controller c(
        clk,
        reset,
        instr[31:26],
        instr[5:0],
        zero,
        pcwrite,
        memwrite,
        irwrite,
        regwrite,
        alusrca,
        branch,
        iord,
        memtoreg,
        regdst,
        alusrcb,
        pcsrc,
        alucontrol
    );
    
    datapath dp(
        clk,
        reset,
        pcwrite,
        memwrite,
        irwrite,
        regwrite,
        alusrca,
        branch,
        iord,
        memtoreg,
        regdst,
        alusrcb,
        pcsrc,
        alucontrol,
        zero,
        pc,
        instr,
        readdata,
        adr,
        b
    );
endmodule
