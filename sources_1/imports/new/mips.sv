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
    output logic [31:0] pc,
    input  logic [31:0] instr,
    output logic        memwrite,
    output logic [31:0] aluout, writedata,
    input  logic [31:0] readdata,
    output logic [31:0] adr, rfrd2
    );

    // logic       memtoreg, alusrc, regdst, regwrite, pcsrc, zero, immext;
    // logic [2:0] alucontrol;
    // logic [2:0] jump;

    // controller  c(instr[31:26], instr[5:0], zero, memtoreg, memwrite, pcsrc, alusrc, regdst, regwrite, jump, alucontrol, immext);
    // datapath    dp(clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, jump, alucontrol, zero, pc, instr, aluout, writedata, readdata);

    logic zero, pcwrite, irwrite, regwrite, alusrca, branch, iord, memtoreg, regdst;
    logic [1:0] alusrcb, pcsrc, aluop;
    logic [2:0] alucontrol;

    controller c(
        clk,
        reset,
        instr[31:26],
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
        aluop,
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
        aluout,
        readdata,
        adr,
        rfrd2
    );
    
endmodule
