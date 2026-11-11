`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2026 04:58:24 PM
// Design Name: 
// Module Name: uart_baud
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


module uart_baud #(parameter clk_frq = 50000000,
baud_rate = 9600)(input clk , rst , output reg baud_tick , baud_tick_16x

    );
  reg [31:0]tx_count ;
  reg [31:0]rx_count ;
  
    
    localparam div = clk_frq/baud_rate;
    localparam div_16x = div/16;
    
    always @(posedge clk or posedge rst )
    begin
    if (rst )begin
    tx_count <= 32'b0;
    baud_tick <= 1'b0;
    end
    else begin
    baud_tick <= 0;
    if(tx_count == div - 1 )begin
    baud_tick <= 1'b1;
    tx_count <= 32'b0;
    end
    else begin
    tx_count <= tx_count + 1 ;
    
    end
    end
    end
    
    
    
    always @(posedge clk or posedge rst )
    begin
    if (rst )begin
    rx_count <= 32'b0;
    baud_tick_16x <= 1'b0;
    end
    else begin
    baud_tick_16x <= 0;
    if(rx_count == div_16x - 1 )begin
    baud_tick_16x <= 1'b1;
    rx_count <= 32'b0;
    end
    else begin
    rx_count <= rx_count + 1 ;
    
    end
    end
    end
    
endmodule
