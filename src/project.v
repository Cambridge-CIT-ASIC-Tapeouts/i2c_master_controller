`default_nettype none

module tt_um_i2c_master (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    reg busy;
    reg done;
    reg ack;

    reg [4:0] counter;

    wire start_tx = ui_in[0];

    assign uo_out = {5'b00000, ack, done, busy};

    // Simple SDA/SCL activity
    assign uio_out[0] = busy ? counter[0] : 1'b1; // SDA
    assign uio_out[1] = busy ? ~counter[0] : 1'b1; // SCL
    assign uio_out[7:2] = 6'b0;

    assign uio_oe[0] = 1'b1;
    assign uio_oe[1] = 1'b1;
    assign uio_oe[7:2] = 6'b0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy    <= 1'b0;
            done    <= 1'b0;
            ack     <= 1'b0;
            counter <= 5'd0;
        end
        else begin

            if (!busy && start_tx) begin
                busy    <= 1'b1;
                done    <= 1'b0;
                ack     <= 1'b0;
                counter <= 5'd0;
            end

            else if (busy) begin
                counter <= counter + 1'b1;

                if (counter == 5'd15) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    ack  <= 1'b1;
                end
            end
        end
    end

    wire _unused = &{ena, uio_in, 1'b0};

endmodule

`default_nettype wire
