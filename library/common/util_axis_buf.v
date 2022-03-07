`timescale 1ns/100ps

module util_axis_buf #(
    parameter DATA_WIDTH = 1
) (
    input                       clk,
    input                       resetn,

    input                       s_axis_valid,
    output                      s_axis_ready, 
    input   [DATA_WIDTH-1:0]    s_axis_data,
    input                       s_axis_last,

    output                      m_axis_valid,
    input                       m_axis_ready,
    output  [DATA_WIDTH-1:0]    m_axis_data,
    output                      m_axis_last);

    reg     [DATA_WIDTH-1:0]    r_buf_0;
    reg     [DATA_WIDTH-1:0]    r_buf_1;

    reg     [1:0]               r_valid;
    reg     [1:0]               r_last;

    reg                         r_started;

    assign s_axis_ready = r_started & ~&r_valid;
    assign m_axis_valid = r_valid[1];
    assign m_axis_last  = r_last[1];
    assign m_axis_data  = r_buf_1;

    reg                         v_new_data;
    reg                         v_out_data;

    always @(posedge clk) begin
        if (!resetn) begin
            r_buf_0 <= 'h0;
            r_buf_1 <= 'h0;
            r_valid <= 'h0;
            r_last  <= 'h0;
            r_started <= 'h0;
        end else begin
            v_new_data = (s_axis_ready & s_axis_valid);
            v_out_data = (m_axis_ready & m_axis_valid);

            r_started <= 1'h1;

            case ({v_new_data, v_out_data})
                'b00: begin
                    if (!r_valid[1] && r_valid[0]) begin
                        r_valid   <= {r_valid[0], 1'h0};
                        r_buf_1   <= r_buf_0;
                        r_last[1] <= r_last[0];
                    end
                end
                'b01: begin
                    // Output, but no new input -> Deassert valids, shift data
                    r_valid   <= {r_valid[0], 1'h0};
                    r_buf_1   <= r_buf_0;
                    r_last[1] <= r_last[0];
                end
                'b10: begin
                    // New input, no output
                    if (~|r_valid) begin
                        r_valid[1]  <= 1'b1;
                        r_buf_1     <= s_axis_data;
                        r_last[1]   <= s_axis_last;
                    end else if (r_valid[1]) begin
                        r_valid[0] <= 1'b1;
                        r_buf_0    <= s_axis_data;
                        r_last[0]  <= s_axis_last;
                    end else begin
                        r_valid <= {r_valid[0], 1'h1};
                        r_buf_0 <= s_axis_data;
                        r_buf_1 <= r_buf_0;
                        r_last  <= {r_last[0], s_axis_last};
                    end
                end
                'b11: begin
                    // In and out -> Go through buf_1
                    r_valid <= {1'h1, 1'h0};
                    r_buf_1 <= s_axis_data;
                    r_last[1] <= s_axis_last;
                end
            endcase
        end
    end
endmodule

