`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/10 12:36:32
// Design Name: 
// Module Name: bcd
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


module bcd(
    input clk,
    input [31:0] data,
    input en,
    output [7:0] bcds,
    output [7:0] bcds1,
    output [7:0] select
    );
    wire [6:0] decoded;
    
    wire [3:0] dispNum1, dispNum2;
    reg [7:0] an = 8'b00010001;
    assign select = en ? an : 0;
    assign dispNum1 = an[3:0] == 4'b0001 ? data[3:0]:
                      an[3:0] == 4'b0010 ? data[7:4]:
                      an[3:0] == 4'b0100 ? data[11:8]:
                      data[15:12];
    assign dispNum2 = an[7:4] == 4'b0001 ? data[19:16]:
                      an[7:4] == 4'b0010 ? data[23:20]:
                      an[7:4] == 4'b0100 ? data[27:24]:
                      data[31:28];
    
    BCD7 b1(dispNum1, bcds[6: 0]);
    BCD7 b2(dispNum2, bcds1[6: 0]);
    assign bcds[7] = an[3:0] == 4'b0010;
    assign bcds1[7] = an[7:4] == 4'b0010;
    
    always @(posedge clk)begin
        an <= {an[6:0], an[7]};
    end
endmodule
