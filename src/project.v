`default_nettype none

module tt_um_i2c_master (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    localparam IDLE      = 3'd0;
    localparam START     = 3'd1;
    localparam SEND_ADDR = 3'd2;
    localparam SEND_DATA = 3'd3;
    localparam STOP      = 3'd4;
    localparam DONE      = 3'd5;

    reg [2:0] state;

    reg scl;
    reg sda;

    reg busy;
    reg done;
    reg ack;

    reg [7:0] shift_reg;
    reg [3:0] bit_cnt;

    wire start_tx = ui_in[0];

    assign uo_out = {5'b0, ack, done, busy};

    assign uio_out[0] = sda;
    assign uio_out[1] = scl;
    assign uio_out[7:2] = 6'b0;

    assign uio_oe[0] = 1'b1;
    assign uio_oe[1] = 1'b1;
    assign uio_oe[7:2] = 6'b0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;

            scl <= 1'b1;
            sda <= 1'b1;

            busy <= 1'b0;
            done <= 1'b0;
            ack  <= 1'b0;

            shift_reg <= 8'h00;
            bit_cnt <= 4'd0;
        end
        else begin
            case(state)

                IDLE: begin
                    scl <= 1'b1;
                    sda <= 1'b1;

                    busy <= 1'b0;
                    done <= 1'b0;
                    ack  <= 1'b0;

                    if(start_tx) begin
                        busy <= 1'b1;
                        state <= START;
                    end
                end

                START: begin
                    sda <= 1'b0;
                    scl <= 1'b1;

                    shift_reg <= {7'h50,1'b0}; // address + write
                    bit_cnt <= 4'd7;

                    state <= SEND_ADDR;
                end

                SEND_ADDR: begin
                    scl <= ~scl;

                    if(scl == 1'b0) begin
                        sda <= shift_reg[bit_cnt];

                        if(bit_cnt == 0) begin
                            shift_reg <= ui_in;
                            bit_cnt <= 4'd7;
                            state <= SEND_DATA;
                        end
                        else begin
                            bit_cnt <= bit_cnt - 1'b1;
                        end
                    end
                end

                SEND_DATA: begin
                    scl <= ~scl;

                    if(scl == 1'b0) begin
                        sda <= shift_reg[bit_cnt];

                        if(bit_cnt == 0) begin
                            ack <= 1'b1;
                            state <= STOP;
                        end
                        else begin
                            bit_cnt <= bit_cnt - 1'b1;
                        end
                    end
                end

                STOP: begin
                    scl <= 1'b1;
                    sda <= 1'b1;

                    busy <= 1'b0;
                    done <= 1'b1;

                    state <= DONE;
                end

                DONE: begin
                    if(!start_tx)
                        state <= IDLE;
                end

                default:
                    state <= IDLE;

            endcase
        end
    end

    wire _unused = &{ena, uio_in, 1'b0};

endmodule

`default_nettype wire
