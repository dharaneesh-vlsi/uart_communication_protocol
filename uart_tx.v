`timescale 1ns / 1ps

module uart_tx(
    input clk,
    input rst,
    input tx_start,
    input baud_tick,
    input [7:0] data_in,

    output reg tx,
    output reg tx_busy,
    output reg tx_done
);

    // FSM states
    localparam idle_state  = 2'b00;
    localparam start_state = 2'b01;
    localparam data_state  = 2'b10;
    localparam stop_state  = 2'b11;

    reg [1:0] state;

    // Internal registers
    reg [7:0] data;
    reg [2:0] index;
    reg stop_phase;

    // FSM
    always @(posedge clk or posedge rst)
    begin
        if (rst) begin

            tx         <= 1'b1;
            tx_busy    <= 1'b0;
            tx_done    <= 1'b0;

            state      <= idle_state;
            data       <= 8'b0;
            index      <= 3'b0;
            stop_phase <= 1'b0;

        end

        else begin

            // Default pulse
            tx_done <= 1'b0;

            case(state)

                // IDLE STATE
                idle_state: begin

                    tx      <= 1'b1;
                    tx_busy <= 1'b0;

                    if (tx_start) begin

                        data  <= data_in;
                        index <= 3'b0;

                        tx_busy <= 1'b1;

                        state <= start_state;

                    end

                end


                // START STATE
                start_state: begin

                    if (baud_tick) begin

                        tx <= 1'b0;

                        state <= data_state;

                    end

                end


                // DATA STATE
                data_state: begin

                    if (baud_tick) begin

                        tx <= data[index];

                        if (index == 7) begin

                            state <= stop_state;
                            stop_phase <= 1'b0;

                        end

                        else begin

                            index <= index + 1'b1;

                        end

                    end

                end


                // STOP STATE
                stop_state: begin

                    if (baud_tick) begin

                        if (!stop_phase) begin

                            tx <= 1'b1;
                            stop_phase <= 1'b1;

                        end

                        else begin

                            state <= idle_state;
                            tx_busy <= 1'b0;
                            tx_done <= 1'b1;

                            stop_phase <= 1'b0;

                        end

                    end

                end

                default: begin

                    state <= idle_state;
                    tx <= 1'b1;

                end

            endcase

        end

    end

endmodule
