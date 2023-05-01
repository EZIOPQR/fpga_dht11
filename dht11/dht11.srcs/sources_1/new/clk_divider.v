`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/01 00:05:21
// Design Name: 
// Module Name: clk_divider
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


module clk_divider(
    input sysclk,
    output reg clk
    );
    parameter[15:0] div = 99;
    
    reg[15:0] cnt = 0;
    
    always@(posedge sysclk)begin
        if(cnt >= div) begin
            cnt <= 0;
            clk <= 1;
        end else begin
            cnt <= cnt + 1;
            clk <= 0;
        end
    end
endmodule
