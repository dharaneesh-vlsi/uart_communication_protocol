
`timescale 1ns / 1ps
module uart_top #(
    parameter clk_frq  = 50000000,
    parameter baud_rate = 9600
)(
    input clk,
    input rst,

    // Transmitter interface
    input [7:0] tx_data,
    input tx_start,
    output tx,
    output tx_busy,
    output tx_done,

    // Receiver interface
    input rx,
    output [7:0] rx_data,
    output rx_done,
    output rx_busy,
    output framing_error
);

    // Internal baud signals
    wire baud_tick;
    wire baud_tick_16x;


    // 1. Baud Rate Generator
    uart_baud #(
        .clk_frq(clk_frq),
        .baud_rate(baud_rate)
    ) baud_inst (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .baud_tick_16x(baud_tick_16x)
    );


    // 2. UART Transmitter
    uart_tx tx_inst (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .data_in(tx_data),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );


    // 3. UART Receiver
    uart_rx rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .baud_tick_16x(baud_tick_16x),
        .data_out(rx_data),
        .rx_done(rx_done),
        .rx_busy(rx_busy),
        .framing_error(framing_error)
    );

endmodule
