`default_nettype none

module tt_um_kamales_i2c_master (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;

    reg busy;
    reg scl;
    reg sda;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt   <= 0;
            shift_reg <= 0;
            busy      <= 0;
            scl       <= 1;
            sda       <= 1;
        end
        else begin

            if (!busy && ui_in[0]) begin
                busy      <= 1;
                shift_reg <= ui_in;
                bit_cnt   <= 8;
                sda       <= 0;      // START
            end
            else if (busy) begin

                scl <= ~scl;

                if (scl) begin
                    sda <= shift_reg[7];
                    shift_reg <= {shift_reg[6:0],1'b0};

                    if (bit_cnt != 0)
                        bit_cnt <= bit_cnt - 1;
                    else begin
                        busy <= 0;
                        sda <= 1;
                    end
                end
            end
        end
    end

    assign uo_out[0] = busy;
    assign uo_out[7:1] = 0;

    assign uio_out[0] = sda;
    assign uio_out[1] = scl;
    assign uio_out[7:2] = 0;

    assign uio_oe[0] = 1;
    assign uio_oe[1] = 1;
    assign uio_oe[7:2] = 0;

    wire _unused = &{ena,uio_in,1'b0};

endmodule
