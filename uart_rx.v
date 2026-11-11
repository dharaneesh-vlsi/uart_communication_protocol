`timescale 1ns / 1ps

module uart_rx(

    input clk,
    input rst,
    input rx,
    input baud_tick_16x,

    output reg [7:0] data_out,
    output reg rx_done,
    output reg rx_busy,
    output reg framing_error

);

    // FSM States

    localparam idle_state  = 2'b00;
    localparam start_state = 2'b01;
    localparam data_state  = 2'b10;
    localparam stop_state  = 2'b11;


    // Internal Registers

    reg [1:0] state;

    reg [7:0] rx_data;
    reg [2:0] index;

    reg [3:0] sample_count;


    // Synchronizer Registers

    reg rx_sync1;
    reg rx_sync2;
    reg rx_previous;


    // UART RX FSM

    always @(posedge clk or posedge rst)
    begin

        if (rst) begin

            state         <= idle_state;

            data_out      <= 8'b0;
            rx_data       <= 8'b0;

            index         <= 3'b0;
            sample_count  <= 4'b0;

            rx_done       <= 1'b0;
            rx_busy       <= 1'b0;
            framing_error <= 1'b0;

            rx_sync1      <= 1'b1;
            rx_sync2      <= 1'b1;
            rx_previous   <= 1'b1;

        end

        else begin

            // Synchronization

            rx_sync1    <= rx;
            rx_sync2    <= rx_sync1;
            rx_previous <= rx_sync2;


            // Default Output Pulses

            rx_done       <= 1'b0;
            framing_error <= 1'b0;


            // FSM Operation

            case (state)


                // IDLE STATE

                idle_state: begin

                    rx_busy <= 1'b0;

                    sample_count <= 0;

                    if (rx_previous && !rx_sync2) begin

                        state <= start_state;

                        rx_busy <= 1'b1;

                        sample_count <= 0;
                        index <= 0;

                    end

                end


                // START STATE

                start_state: begin

                    if (baud_tick_16x) begin

                        if (sample_count == 7) begin

                            sample_count <= 0;

                            // Check START bit

                            if (!rx_sync2) begin

                                state <= data_state;

                            end

                            else begin

                                state <= idle_state;
                                rx_busy <= 0;

                            end

                        end

                        else begin

                            sample_count <= sample_count + 1'b1;

                        end

                    end

                end


                // DATA STATE

                data_state: begin

                    if (baud_tick_16x) begin

                        if (sample_count == 15) begin

                            sample_count <= 0;

                            // Receive LSB First

                            rx_data <= {rx_sync2, rx_data[7:1]};

                            if (index == 7) begin

                                state <= stop_state;

                            end

                            else begin

                                index <= index + 1'b1;

                            end

                        end

                        else begin

                            sample_count <= sample_count + 1'b1;

                        end

                    end

                end


                // STOP STATE

                stop_state: begin

                    if (baud_tick_16x) begin

                        if (sample_count == 15) begin

                            sample_count <= 0;

                            // Check STOP bit

                            if (rx_sync2) begin

                                data_out <= rx_data;
                                rx_done <= 1'b1;

                            end

                            else begin

                                framing_error <= 1'b1;

                            end

                            state <= idle_state;
                            rx_busy <= 1'b0;

                        end

                        else begin

                            sample_count <= sample_count + 1'b1;

                        end

                    end

                end


                default: begin

                    state <= idle_state;
                    rx_busy <= 1'b0;

                end


            endcase

        end

    end

endmodule
