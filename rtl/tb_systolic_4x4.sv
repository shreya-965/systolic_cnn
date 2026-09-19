`timescale 1ns/1ps

module tb_systolic_4x4;

    localparam integer IMAGE_VALUES = 3072;
    localparam integer IMAGE_PIXELS = 1024;
    localparam integer FILTER_VALUES = 108;
    localparam integer EXPECTED_VALUES = 3600;

    logic clk;
    logic reset;
    logic clk_enable;
    logic reset_1;

    logic [7:0] pixel_0;
    logic [7:0] pixel_1;
    logic [7:0] pixel_2;

    logic signed [2:0] filter0_0, filter0_1, filter0_2, filter0_3, filter0_4, filter0_5, filter0_6, filter0_7, filter0_8;
    logic signed [2:0] filter0_9, filter0_10, filter0_11, filter0_12, filter0_13, filter0_14, filter0_15, filter0_16, filter0_17;
    logic signed [2:0] filter0_18, filter0_19, filter0_20, filter0_21, filter0_22, filter0_23, filter0_24, filter0_25, filter0_26;
    logic signed [2:0] filter1_0, filter1_1, filter1_2, filter1_3, filter1_4, filter1_5, filter1_6, filter1_7, filter1_8;
    logic signed [2:0] filter1_9, filter1_10, filter1_11, filter1_12, filter1_13, filter1_14, filter1_15, filter1_16, filter1_17;
    logic signed [2:0] filter1_18, filter1_19, filter1_20, filter1_21, filter1_22, filter1_23, filter1_24, filter1_25, filter1_26;
    logic signed [2:0] filter2_0, filter2_1, filter2_2, filter2_3, filter2_4, filter2_5, filter2_6, filter2_7, filter2_8;
    logic signed [2:0] filter2_9, filter2_10, filter2_11, filter2_12, filter2_13, filter2_14, filter2_15, filter2_16, filter2_17;
    logic signed [2:0] filter2_18, filter2_19, filter2_20, filter2_21, filter2_22, filter2_23, filter2_24, filter2_25, filter2_26;
    logic signed [2:0] filter3_0, filter3_1, filter3_2, filter3_3, filter3_4, filter3_5, filter3_6, filter3_7, filter3_8;
    logic signed [2:0] filter3_9, filter3_10, filter3_11, filter3_12, filter3_13, filter3_14, filter3_15, filter3_16, filter3_17;
    logic signed [2:0] filter3_18, filter3_19, filter3_20, filter3_21, filter3_22, filter3_23, filter3_24, filter3_25, filter3_26;

    logic ce_out;
    logic signed [12:0] output_0, output_1, output_2, output_3;
    logic valid;
    logic ready;

    logic [7:0] image_mem [0:IMAGE_VALUES-1];
    logic [7:0] filter_mem [0:FILTER_VALUES-1];
    logic [31:0] expected_mem [0:EXPECTED_VALUES-1];

    integer pixel_count;
    integer output_count;
    integer error_count;
    integer cycle_count;

    integer window_count;
    integer out_row;
    integer out_col;
    integer f;

    integer kr;
    integer kc;
    integer ch;
    integer idx;

    integer expected_value;
    integer actual_value;

    systolic_4x4_fixpt dut (
        .clk(clk),
        .reset(reset),
        .clk_enable(clk_enable),
        .pixel_0(pixel_0),
        .pixel_1(pixel_1),
        .pixel_2(pixel_2),
        .filter0_0(filter0_0),
        .filter0_1(filter0_1),
        .filter0_2(filter0_2),
        .filter0_3(filter0_3),
        .filter0_4(filter0_4),
        .filter0_5(filter0_5),
        .filter0_6(filter0_6),
        .filter0_7(filter0_7),
        .filter0_8(filter0_8),
        .filter0_9(filter0_9),
        .filter0_10(filter0_10),
        .filter0_11(filter0_11),
        .filter0_12(filter0_12),
        .filter0_13(filter0_13),
        .filter0_14(filter0_14),
        .filter0_15(filter0_15),
        .filter0_16(filter0_16),
        .filter0_17(filter0_17),
        .filter0_18(filter0_18),
        .filter0_19(filter0_19),
        .filter0_20(filter0_20),
        .filter0_21(filter0_21),
        .filter0_22(filter0_22),
        .filter0_23(filter0_23),
        .filter0_24(filter0_24),
        .filter0_25(filter0_25),
        .filter0_26(filter0_26),
        .filter1_0(filter1_0),
        .filter1_1(filter1_1),
        .filter1_2(filter1_2),
        .filter1_3(filter1_3),
        .filter1_4(filter1_4),
        .filter1_5(filter1_5),
        .filter1_6(filter1_6),
        .filter1_7(filter1_7),
        .filter1_8(filter1_8),
        .filter1_9(filter1_9),
        .filter1_10(filter1_10),
        .filter1_11(filter1_11),
        .filter1_12(filter1_12),
        .filter1_13(filter1_13),
        .filter1_14(filter1_14),
        .filter1_15(filter1_15),
        .filter1_16(filter1_16),
        .filter1_17(filter1_17),
        .filter1_18(filter1_18),
        .filter1_19(filter1_19),
        .filter1_20(filter1_20),
        .filter1_21(filter1_21),
        .filter1_22(filter1_22),
        .filter1_23(filter1_23),
        .filter1_24(filter1_24),
        .filter1_25(filter1_25),
        .filter1_26(filter1_26),
        .filter2_0(filter2_0),
        .filter2_1(filter2_1),
        .filter2_2(filter2_2),
        .filter2_3(filter2_3),
        .filter2_4(filter2_4),
        .filter2_5(filter2_5),
        .filter2_6(filter2_6),
        .filter2_7(filter2_7),
        .filter2_8(filter2_8),
        .filter2_9(filter2_9),
        .filter2_10(filter2_10),
        .filter2_11(filter2_11),
        .filter2_12(filter2_12),
        .filter2_13(filter2_13),
        .filter2_14(filter2_14),
        .filter2_15(filter2_15),
        .filter2_16(filter2_16),
        .filter2_17(filter2_17),
        .filter2_18(filter2_18),
        .filter2_19(filter2_19),
        .filter2_20(filter2_20),
        .filter2_21(filter2_21),
        .filter2_22(filter2_22),
        .filter2_23(filter2_23),
        .filter2_24(filter2_24),
        .filter2_25(filter2_25),
        .filter2_26(filter2_26),
        .filter3_0(filter3_0),
        .filter3_1(filter3_1),
        .filter3_2(filter3_2),
        .filter3_3(filter3_3),
        .filter3_4(filter3_4),
        .filter3_5(filter3_5),
        .filter3_6(filter3_6),
        .filter3_7(filter3_7),
        .filter3_8(filter3_8),
        .filter3_9(filter3_9),
        .filter3_10(filter3_10),
        .filter3_11(filter3_11),
        .filter3_12(filter3_12),
        .filter3_13(filter3_13),
        .filter3_14(filter3_14),
        .filter3_15(filter3_15),
        .filter3_16(filter3_16),
        .filter3_17(filter3_17),
        .filter3_18(filter3_18),
        .filter3_19(filter3_19),
        .filter3_20(filter3_20),
        .filter3_21(filter3_21),
        .filter3_22(filter3_22),
        .filter3_23(filter3_23),
        .filter3_24(filter3_24),
        .filter3_25(filter3_25),
        .filter3_26(filter3_26),
        .reset_1(reset_1),
        .ce_out(ce_out),
        .output_0(output_0),
        .output_1(output_1),
        .output_2(output_2),
        .output_3(output_3),
        .valid(valid),
        .ready(ready)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 1'b0;
        reset = 1'b1;
        reset_1 = 1'b1;
        clk_enable = 1'b1;

        pixel_0 = 8'd0;
        pixel_1 = 8'd0;
        pixel_2 = 8'd0;

        $readmemh("image.hex", image_mem);
        $readmemh("expected.hex", expected_mem);

        load_filters();

        repeat (5)
            @(posedge clk);

        reset = 1'b0;
        reset_1 = 1'b0;

        pixel_count = 0;
        output_count = 0;
        error_count = 0;
        cycle_count = 0;

        /*
         * Feed exactly one image pixel whenever the DUT is in its
         * input state. A valid convolution window is formed for
         * row>=2 && col>=2, followed by 7 compute cycles.
         */

        @(negedge clk);

        pixel_0 = image_mem[0];
        pixel_1 = image_mem[1];
        pixel_2 = image_mem[2];

        pixel_count = 1;

        forever begin

            @(posedge clk);

            cycle_count = cycle_count + 1;

            if (valid) begin

                window_count = output_count / 4;
                out_row = window_count / 30;
                out_col = window_count % 30;

                for (f = 0; f < 4; f = f + 1) begin

                    expected_value = $signed(expected_mem[output_count + f]);
                    case (f)
                        0: actual_value = $signed(output_0);
                        1: actual_value = $signed(output_1);
                        2: actual_value = $signed(output_2);
                        3: actual_value = $signed(output_3);
                    endcase

                    if (actual_value !== expected_value) begin

                        error_count = error_count + 1;

                        if (error_count <= 20)
                            $display(
                                "ERROR row=%0d col=%0d filter=%0d expected=%0d actual=%0d",
                                out_row, out_col, f, expected_value, actual_value
                            );

                    end
                    else if (output_count < 20) begin

                        $display(
                            "OUTPUT row=%0d col=%0d filter=%0d = %0d",
                            out_row, out_col, f, actual_value
                        );

                    end
                end

                output_count = output_count + 4;
            end

            /*
             * The current image pixel has just been consumed.
             * Determine its image row/column from pixel_count-1.
             */
            if (pixel_count < IMAGE_PIXELS) begin

                if (((pixel_count - 1) / 32 >= 2) &&
                    ((pixel_count - 1) % 32 >= 2)) begin

                    /*
                     * This pixel created a convolution window.
                     * The DUT now spends 7 cycles in compute state.
                     */
                    repeat (7) begin
                        @(negedge clk);

                        pixel_0 = 8'd0;
                        pixel_1 = 8'd0;
                        pixel_2 = 8'd0;

                        @(posedge clk);

                        cycle_count = cycle_count + 1;

                        if (valid) begin

                            window_count = output_count / 4;
                            out_row = window_count / 30;
                            out_col = window_count % 30;

                            for (f = 0; f < 4; f = f + 1) begin

                                expected_value = $signed(expected_mem[output_count + f]);
                                case (f)
                        0: actual_value = $signed(output_0);
                        1: actual_value = $signed(output_1);
                        2: actual_value = $signed(output_2);
                        3: actual_value = $signed(output_3);
                    endcase

                                if (actual_value !== expected_value) begin

                                    error_count = error_count + 1;

                                    if (error_count <= 20)
                                        $display(
                                            "ERROR row=%0d col=%0d filter=%0d expected=%0d actual=%0d",
                                            out_row, out_col, f, expected_value, actual_value
                                        );

                                end
                                else if (output_count < 20) begin

                                    $display(
                                        "OUTPUT row=%0d col=%0d filter=%0d = %0d",
                                        out_row, out_col, f, actual_value
                                    );

                                end
                            end

                            output_count = output_count + 4;
                        end
                    end
                end

                if (pixel_count < IMAGE_PIXELS) begin
                    @(negedge clk);

                    pixel_0 = image_mem[pixel_count*3];
                    pixel_1 = image_mem[pixel_count*3+1];
                    pixel_2 = image_mem[pixel_count*3+2];

                    pixel_count = pixel_count + 1;
                end

            end
            else begin

                repeat (9) begin
                    @(negedge clk);

                    pixel_0 = 8'd0;
                    pixel_1 = 8'd0;
                    pixel_2 = 8'd0;

                    @(posedge clk);

                    cycle_count = cycle_count + 1;

                    if (valid) begin

                        window_count = output_count / 4;
                        out_row = window_count / 30;
                        out_col = window_count % 30;

                        for (f = 0; f < 4; f = f + 1) begin

                            expected_value = $signed(expected_mem[output_count + f]);
                            case (f)
                        0: actual_value = $signed(output_0);
                        1: actual_value = $signed(output_1);
                        2: actual_value = $signed(output_2);
                        3: actual_value = $signed(output_3);
                    endcase

                            if (actual_value !== expected_value) begin

                                error_count = error_count + 1;

                                if (error_count <= 20)
                                    $display(
                                        "ERROR row=%0d col=%0d filter=%0d expected=%0d actual=%0d",
                                        out_row, out_col, f, expected_value, actual_value
                                    );

                            end
                            else if (output_count < 20) begin

                                $display(
                                    "OUTPUT row=%0d col=%0d filter=%0d = %0d",
                                    out_row, out_col, f, actual_value
                                );

                            end
                        end

                        output_count = output_count + 4;
                    end
                end

                break;
            end

            if (cycle_count > 10000) begin
                $display("TIMEOUT");
                $display("Input pixels = %0d", pixel_count);
                $display("Outputs = %0d", output_count);
                $finish;
            end
        end

        $display("");
        $display("Input pixels = %0d", pixel_count);
        $display("Total outputs = %0d", output_count);
        $display("Errors = %0d", error_count);
        $display("Cycles = %0d", cycle_count);

        if (pixel_count != IMAGE_PIXELS)
            $display("TEST FAILED: input count");
        else if (output_count != EXPECTED_VALUES)
            $display("TEST FAILED: output count");
        else if (error_count != 0)
            $display("TEST FAILED");
        else
            $display("TEST PASSED");

        #20;
        $finish;

    end


    task load_filters;
        begin
            filter0_0 = 3'sd3;
            filter0_1 = -3'sd1;
            filter0_2 = 3'sd2;
            filter0_3 = 3'sd2;
            filter0_4 = 3'sd2;
            filter0_5 = -3'sd3;
            filter0_6 = -3'sd2;
            filter0_7 = 3'sd0;
            filter0_8 = 3'sd3;
            filter0_9 = 3'sd2;
            filter0_10 = -3'sd2;
            filter0_11 = -3'sd3;
            filter0_12 = 3'sd1;
            filter0_13 = 3'sd1;
            filter0_14 = 3'sd2;
            filter0_15 = -3'sd3;
            filter0_16 = 3'sd1;
            filter0_17 = -3'sd3;
            filter0_18 = 3'sd0;
            filter0_19 = 3'sd3;
            filter0_20 = 3'sd1;
            filter0_21 = -3'sd2;
            filter0_22 = 3'sd0;
            filter0_23 = -3'sd3;
            filter0_24 = -3'sd2;
            filter0_25 = -3'sd3;
            filter0_26 = 3'sd0;
            filter1_0 = 3'sd1;
            filter1_1 = -3'sd2;
            filter1_2 = 3'sd2;
            filter1_3 = 3'sd2;
            filter1_4 = -3'sd3;
            filter1_5 = 3'sd0;
            filter1_6 = 3'sd1;
            filter1_7 = -3'sd1;
            filter1_8 = -3'sd2;
            filter1_9 = -3'sd1;
            filter1_10 = -3'sd1;
            filter1_11 = 3'sd3;
            filter1_12 = 3'sd0;
            filter1_13 = 3'sd2;
            filter1_14 = 3'sd2;
            filter1_15 = 3'sd3;
            filter1_16 = 3'sd2;
            filter1_17 = 3'sd1;
            filter1_18 = -3'sd1;
            filter1_19 = -3'sd1;
            filter1_20 = -3'sd3;
            filter1_21 = 3'sd1;
            filter1_22 = 3'sd1;
            filter1_23 = 3'sd2;
            filter1_24 = -3'sd3;
            filter1_25 = 3'sd3;
            filter1_26 = 3'sd0;
            filter2_0 = -3'sd2;
            filter2_1 = 3'sd3;
            filter2_2 = 3'sd1;
            filter2_3 = 3'sd3;
            filter2_4 = 3'sd2;
            filter2_5 = 3'sd2;
            filter2_6 = 3'sd1;
            filter2_7 = 3'sd1;
            filter2_8 = -3'sd2;
            filter2_9 = 3'sd0;
            filter2_10 = -3'sd2;
            filter2_11 = -3'sd2;
            filter2_12 = 3'sd0;
            filter2_13 = 3'sd2;
            filter2_14 = 3'sd2;
            filter2_15 = 3'sd3;
            filter2_16 = -3'sd1;
            filter2_17 = 3'sd1;
            filter2_18 = 3'sd0;
            filter2_19 = 3'sd2;
            filter2_20 = -3'sd2;
            filter2_21 = 3'sd3;
            filter2_22 = -3'sd1;
            filter2_23 = 3'sd0;
            filter2_24 = -3'sd1;
            filter2_25 = 3'sd2;
            filter2_26 = -3'sd2;
            filter3_0 = 3'sd0;
            filter3_1 = 3'sd1;
            filter3_2 = 3'sd2;
            filter3_3 = -3'sd1;
            filter3_4 = 3'sd2;
            filter3_5 = -3'sd1;
            filter3_6 = 3'sd0;
            filter3_7 = 3'sd3;
            filter3_8 = 3'sd0;
            filter3_9 = 3'sd1;
            filter3_10 = 3'sd3;
            filter3_11 = 3'sd0;
            filter3_12 = 3'sd1;
            filter3_13 = 3'sd2;
            filter3_14 = 3'sd1;
            filter3_15 = -3'sd3;
            filter3_16 = -3'sd3;
            filter3_17 = 3'sd3;
            filter3_18 = 3'sd3;
            filter3_19 = -3'sd2;
            filter3_20 = 3'sd1;
            filter3_21 = -3'sd2;
            filter3_22 = -3'sd2;
            filter3_23 = 3'sd0;
            filter3_24 = -3'sd1;
            filter3_25 = 3'sd3;
            filter3_26 = 3'sd3;
        end
    endtask

endmodule