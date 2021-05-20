`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/18 08:53:07
// Design Name: 
// Module Name: controller
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


module controller(
    input  logic        clk, reset,
    input  logic [5:0]  op,
    input  logic [5:0]  funct,
    input  logic        zero,
    output logic        pcwrite, memwrite, irwrite, regwrite,
    output logic        alusrca,
    output logic        branch,
    output logic        iord,
    output logic        memtoreg, regdst,
    output logic [1:0]  alusrcb, pcsrc,
    output logic [2:0]  alucontrol
    );

    logic [2:0] aluop;
    logic       branch, nbranch;

    maindec md(clk, reset, op, pcwrite, memwrite, irwrite, regwrite, alusrca, branch, iord, memtoreg, regdst, alusrcb, pcsrc, aluop);
    aludec  ad(funct, aluop, alucontrol);
endmodule

module maindec(
    input  logic        clk, reset,
    input  logic [5:0]  op,
    output logic        pcwrite, memwrite, irwrite, regwrite,
    output logic        alusrca,
    output logic        branch,
    output logic        iord,
    output logic        memtoreg,
    output logic        regdst,
    output logic [1:0]  alusrcb,
    output logic [1:0]  pcsrc,
    output logic [2:0]  aluop
    );

    logic [3:0]  state, next_state;
    logic [15:0] controls;
    
    // reset logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= 4'b0000;       // reset current state to FETCH
        else
            state <= next_state;    // set state to next state
    end

    // next state logic
    always_comb begin
        case(state)
            4'b0000: next_state = 4'b0001;              // FETCH -> DECODE
            4'b0001: begin                              // DECODE
                case (op)
                    6'b100011: next_state = 4'b0010;    // OP: LW; DECODE -> MEMADR
                    6'b101011: next_state = 4'b0010;    // OP: SW; DECODE -> MEMADR
                    6'b000000: next_state = 4'b0110;    // OP: RTYPE; DECODE -> RTYPEEX
                    6'b000100: next_state = 4'b1000;    // OP: BEQ; DECODE -> BEQEX
                    6'b001000: next_state = 4'b1001;    // OP: ADDI; DECODE -> ADDIEX
                    6'b000010: next_state = 4'b1011;    // OP: J; DECODE -> JEX
                    6'b001100: next_state = 4'b1100;    // OP: ANDI; DECODE -> ANDIEX
                    default:   next_state = 4'bxxxx;
                endcase
            end
            4'b0010: begin                              // MEMADR
                case (op)
                    6'b100011: next_state = 4'b0011;    // OP: LW; DECODE -> MEMRD
                    6'b101011: next_state = 4'b0101;    // OP: SW; DECODE -> MEMWR 
                    default:   next_state = 4'bxxxx;
                endcase
            end
            4'b0011: next_state = 4'b0100;              // MEMRD -> MEMWB
            4'b0100: next_state = 4'b0000;              // MEMWB -> FETCH
            4'b0101: next_state = 4'b0000;              // MEMWR -> FETCH
            4'b0110: next_state = 4'b0111;              // RTYPEEX -> RTYPEWB
            4'b0111: next_state = 4'b0000;              // RTYPEWB -> FETCH
            4'b1000: next_state = 4'b0000;              // BEQEX -> FETCH
            4'b1001: next_state = 4'b1010;              // ADDIEX -> ADDIWB
            4'b1010: next_state = 4'b0000;              // ADDIWB -> FETCH
            4'b1011: next_state = 4'b0000;              // JEX -> FETCH
            4'b1100: next_state = 4'b1101;              // ANDIEX -> ANDIWB
            4'b1101: next_state = 4'b0000;              // ANDIWB -> FETCH
            default: next_state = 4'bxxxx;
        endcase
    end

    // assign output to controls
    assign {pcwrite,
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
            aluop} = controls;

    // output logic
    always_comb begin
        case (state)
            4'b0000: controls = 16'b1010000000100000;  // FETCH
            4'b0001: controls = 16'b0000000001100000;  // DECODE
            4'b0010: controls = 16'b0000100001000000;  // MEMADR
            4'b0011: controls = 16'b0000001000000000;  // MEMRD
            4'b0100: controls = 16'b0001000100000000;  // MEMWB
            4'b0101: controls = 16'b0100001000000000;  // MEMWR
            4'b0110: controls = 16'b0000100000000010;  // RTYPEEX
            4'b0111: controls = 16'b0001000010000000;  // RTYPEWB
            4'b1000: controls = 16'b0000110000001001;  // BEQEX
            4'b1001: controls = 16'b0000100001000000;  // ADDIEX
            4'b1010: controls = 16'b0001000000000000;  // ADDIWB
            4'b1011: controls = 16'b1000000000010000;  // JEX
            4'b1100: controls = 16'b0000100001000100;  // ANDIEX
            4'b1101: controls = 16'b0001000000000000;  // ANDIWB
            default: controls = 16'hxxxx;
        endcase
    end
endmodule

module aludec(
    input  logic [5:0] funct,
    input  logic [2:0] aluop,
    output logic [2:0] alucontrol
);
    always_comb begin
        case (aluop)
            3'b000: alucontrol <= 3'b010; // ADD
            3'b001: alucontrol <= 3'b110; // SUB
            // 3'b010;  occupied by RTYPE
            3'b011: alucontrol <= 3'b001; // OR
            3'b100: alucontrol <= 3'b000; // AND
            3'b101: alucontrol <= 3'b111; // SLT
            default: case (funct)
                6'b100000: alucontrol <= 3'b010;    // ADD
                6'b100010: alucontrol <= 3'b110;    // SUB
                6'b100100: alucontrol <= 3'b000;    // AND
                6'b100101: alucontrol <= 3'b001;    // OR
                6'b101010: alucontrol <= 3'b111;    // SLT
                default:   alucontrol <= 3'bxxx;
            endcase
        endcase
    end
endmodule
