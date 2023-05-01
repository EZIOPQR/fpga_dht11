`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/30 23:59:04
// Design Name: 
// Module Name: dht11
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


module dht11(
    input sysclk,
    input rst,
    output [7:0] select,
    output [7:0] bcds,
    output [7:0] bcds1,
    inout data,
    output reg[2:0] debugLed
    );
    
    reg dataBuf;
    assign data = dataBuf;
    reg data1, data2;
    wire dataPosEdge, dataNegEdge;
    assign dataPosEdge = data1 & (~data2);
    assign dataNegEdge = (~data1) & data2;
    
    reg[39:0] dataReceive;
    reg[6:0] dataReceiveCnt = 0;
    reg[20:0] startTime;
    reg receiveFlag = 0;
    
    reg[15:0] temp;
    reg[15:0] humi;
    
    wire clk, bcdClk;
    clk_divider #(99) div1(sysclk, clk);
    clk_divider #(9999) div2(sysclk, bcdClk);
    
    reg[20:0] counter = 0;
    
    parameter[2:0] wait2s = 0;
    parameter[2:0] signalStart = 1;
    parameter[2:0] waitingStart = 2;
    parameter[2:0] receiving = 4;
    parameter[2:0] wait1s = 5;
    reg[2:0] state = wait2s;
    //assign debugLed = state;
    reg [31:0] tmpData = 32'b0000_0001_0010_0011_0100_0101_0110_0111;
    reg bcden = 1;
    bcd bcd1(bcdClk, tmpData, bcden, bcds, bcds1, select);
    
    always@(posedge clk) begin
        data1 <= data;
        data2 <= data1;
        
    end
    always@(posedge clk or posedge rst)begin
        if(rst) begin
            state <= wait2s;
            counter <= 0;
            debugLed[0] <= 1;
            debugLed[2] <= 0;
        end else begin
            case(state)
                wait2s:
                    if(counter < 21'd2000000)begin
                        counter <= counter + 1;
                        dataBuf <= 1'bz;
                    end else begin
                        state <= signalStart;
                        counter <= 0;
                    end
                signalStart:
                
                    if(counter < 20_000) begin
                    debugLed[0]<=0;
                        dataBuf <= 1'b0;
                        counter <= counter + 1;
                    end else begin
                        dataBuf <= 1'bz;
                        counter <= counter + 1;
                        if(counter > 20_040) begin
                            if(counter > 40_000) begin
                                counter <= 0;
                                state <= wait2s;
                            end else if(dataPosEdge) begin
                                counter <= 0;
                                state <= waitingStart;
                            end
                        end
                    end
                waitingStart:
                    if(dataNegEdge)begin
                        state <= receiving;
                    end
                receiving:
                    if(counter < 80_000) begin
                        if(dataPosEdge) begin
                            counter <= counter + 1;
                            startTime <= counter;
                        end else if(dataNegEdge) begin
                            if(counter - startTime < 35) begin
                                dataReceive <= {dataReceive[38:0], 1'b0};
                            end else begin
                                dataReceive <= {dataReceive[38:0], 1'b1};
                            end
                            if(dataReceiveCnt < 39) begin
                                counter <= counter + 1;
                                dataReceiveCnt <= dataReceiveCnt + 1;
                            end else begin
                                //666
                                if(dataReceive[39:32] + dataReceive[31:24] + dataReceive[23:16] + dataReceive[15:8] == dataReceive[7:0])begin
                                    debugLed[1] <= ~debugLed[1];
                                end
                                receiveFlag <= 1;
                                
                                debugLed[2] <= ~debugLed[2];
                                state <= wait1s;
                                counter <= 0;
                                dataReceiveCnt <= 0;
                            end
                        end else begin
                            counter <= counter + 1;
                        end
                    end else begin
                        counter <= 0;
                        state <= wait2s;
                    end
                wait1s:begin
                    receiveFlag <= 0;
                    if(counter < 1000_000) begin
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        state <= signalStart;
                    end
                end
            endcase
        end
    end
    
    always@(posedge clk)begin
        if(receiveFlag)begin
            temp = dataReceive[23:8];
            humi = dataReceive[39:24];
            
            tmpData[7:4] = temp[15:8] % 10;
            temp[15:8] = temp[15:8] / 10;
            tmpData[3:0] = temp[15:8] % 10;
            temp[15:8] = temp[15:8] / 10;
            
            tmpData[15:12] = temp[7:0] % 10;
            temp[7:0] = temp[7:0] / 10;
            tmpData[11:8] = temp[7:0] % 10;
            temp[7:0] = temp[7:0] / 10;
            
            tmpData[23:20] = humi[15:8] % 10;
            humi[15:8] = humi[15:8] / 10;
            tmpData[19:16] = humi[15:8] % 10;
            humi[15:8] = humi[15:8] / 10;
                        
            tmpData[31:28] = humi[7:0] % 10;
            humi[7:0] = humi[7:0] / 10;
            tmpData[27:24] = humi[7:0] % 10;
            humi[7:0] = humi[7:0] / 10;
            /*
            tmpData[3:0] <= dataReceive[23];
            tmpData[7:4] <= dataReceive[22];
            tmpData[11:8] <= dataReceive[21];
            tmpData[15:12] <= dataReceive[20];
            tmpData[19:16] <= dataReceive[19];
            tmpData[23:20] <= dataReceive[18];
            tmpData[27:24] <= dataReceive[17];
            tmpData[31:28] <= dataReceive[16];*/
        end
    end
endmodule
