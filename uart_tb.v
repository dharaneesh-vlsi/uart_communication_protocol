`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2026 10:12:39 PM
// Design Name: 
// Module Name: uart_tb
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


`timescale 1ns / 1ps

module uart_tb;

    // Clock and reset
    reg clk;
    reg rst;

    // Transmitter signals
    reg [7:0] tx_data;
    reg tx_start;
    wire tx;
    wire tx_busy;
    wire tx_done;

    // Receiver signals
    wire [7:0] rx_data;
    wire rx_done;
    wire rx_busy;
    wire framing_error;


    // Instantiate UART Top Module
    uart_top #(
        .clk_frq(50000000),
        .baud_rate(9600)
    ) dut (
        .clk(clk),
        .rst(rst),

        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done),

        .rx(tx),              // Loopback connection
        .rx_data(rx_data),
        .rx_done(rx_done),
        .rx_busy(rx_busy),
        .framing_error(framing_error)
    );


    // Clock generation: 50 MHz
    always #10 clk = ~clk;


    // Test sequence
    initial begin

        // Initial values
        clk = 0;
        rst = 1;
        tx_data = 8'h00;
        tx_start = 0;

        // Reset
        #100;
        rst = 0;

        // Wait after reset
        #100;

        // Send data A5
        tx_data = 8'hA5;
        tx_start = 1;

        #20;
        tx_start = 0;

        // Wait for transmission and reception
        wait(rx_done == 1);

        // Display received data
        $display("--------------------------------");
        $display("UART TRANSMISSION COMPLETE");
        $display("Transmitted Data : %h", tx_data);
        $display("Received Data    : %h", rx_data);
        $display("Framing Error    : %b", framing_error);
        $display("--------------------------------");

        // Check received data
        if (rx_data == tx_data && framing_error == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        #100;
        $finish;

    end


    // Monitor signals
    initial begin
        $monitor(
            "Time=%0t | TX=%b | TX_BUSY=%b | TX_DONE=%b | RX=%h | RX_DONE=%b | ERROR=%b",
            $time,
            tx,
            tx_busy,
            tx_done,
            rx_data,
            rx_done,
            framing_error
        );
    end


    // Generate waveform dump
    initial begin
        $dumpfile("uart_wave.vcd");
        $dumpvars(0, uart_tb);
    end

endmodule
