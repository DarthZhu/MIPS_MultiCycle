`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/18 09:19:15
// Design Name: 
// Module Name: datapath
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


module datapath(
    input  logic        clk, reset, 
    input  logic        pcwrite, memwrite, irwrite, regwrite,
    input  logic        alusrca, branch, iord, memtoreg, regdst,
    // input  logic [2:0]  jump,
    input  logic [1:0]  alusrcb, pcsrc,
    input  logic [2:0]  alucontrol,
    output logic        zero,
    output logic [31:0] pc,
    // input  logic [31:0] instr,
    output logic [31:0] aluout,
    input  logic [31:0] readdata,
    output logic [31:0] adr, rfrd2
    // input  logic        immext
    );

    logic pcen, ifbranch;
    logic [31:0] pcnext, aluout, instr, rfwa3, data, rfwd3, rfrd1, a, b, srca, srcb, signimm, signimmsh, aluresult;
    
    floprenr #(32)  pcreg(clk, reset, pcen, pcnext, pc);
    mux2 #(32)      pcregmux(pc, aluout, iord, adr);
    floprenr #(32)  readdatareg(clk, reset, irwrite, readdata, instr);
    floprenr #(32)  rfwdreg(clk, reset, memtoreg, readdata, data);
    mux2 #(32)      regdstmux(instr[20:16], instr[15:11], regdst, rfwa3);
    mux2 #(32)      mem2regmux(aluout, data, memtoreg, rdwd3);
    regfile         rf(clk, regwrite, instr[25:21], instr[20:16], rfwa3, rfwd3, rfrd1, rfrd2);
    floprdouble     rfreg(clk, reset, rfrd1, rfrd2, a, b);
    signext         se(instr[15:0], signimm);
    sl2             immsh(signimm, signimmsh);
    mux2 #(32)      srcamux(pc, a, alusrca, srca);
    mux4 #(32)      srcbmux(b, 4, signimm, signimmsh, alusrcb, srcb);
    alu             alu(srca, srcb, alucontrol, aluresult, zero);
    flopr #(32)     resreg(clk, reset, aluresult, aluout);
    mux4 #(32)      pcsrcreg(aluresult, aluout, {pc[31:28], instr[25:0], 2'b00}, 'x, pcsrc, pcnext);
    ander           ad(branch, zero, ifbranch);
    orer            oe(pcwrite, ifbranch, pcen);
endmodule
