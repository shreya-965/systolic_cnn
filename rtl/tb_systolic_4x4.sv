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

    logic [7:0] pixel [0:2];

    logic signed [2:0] filter0 [0:2][0:2][0:2];
    logic signed [2:0] filter1 [0:2][0:2][0:2];
    logic signed [2:0] filter2 [0:2][0:2][0:2];
    logic signed [2:0] filter3 [0:2][0:2][0:2];

    logic ce_out;
    logic signed [12:0] output_rsvd [0:3];
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
        .pixel(pixel),
        .filter0(filter0),
        .filter1(filter1),
        .filter2(filter2),
        .filter3(filter3),
        .reset_1(reset_1),
        .ce_out(ce_out),
        .output_rsvd(output_rsvd),
        .valid(valid),
        .ready(ready)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 1'b0;
        reset = 1'b1;
        reset_1 = 1'b1;
        clk_enable = 1'b1;

        pixel[0] = 8'd0;
        pixel[1] = 8'd0;
        pixel[2] = 8'd0;

        for (kr = 0; kr < 3; kr = kr + 1)
            for (kc = 0; kc < 3; kc = kc + 1)
                for (ch = 0; ch < 3; ch = ch + 1) begin
                    filter0[kr][kc][ch] = 3'sd0;
                    filter1[kr][kc][ch] = 3'sd0;
                    filter2[kr][kc][ch] = 3'sd0;
                    filter3[kr][kc][ch] = 3'sd0;
                end

        $readmemh("image.hex", image_mem);
        $readmemh("filter.hex", filter_mem);
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

        pixel[0] = image_mem[0];
        pixel[1] = image_mem[1];
        pixel[2] = image_mem[2];

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
                    actual_value = $signed(output_rsvd[f]);

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

                        pixel[0] = 8'd0;
                        pixel[1] = 8'd0;
                        pixel[2] = 8'd0;

                        @(posedge clk);

                        cycle_count = cycle_count + 1;

                        if (valid) begin

                            window_count = output_count / 4;
                            out_row = window_count / 30;
                            out_col = window_count % 30;

                            for (f = 0; f < 4; f = f + 1) begin

                                expected_value = $signed(expected_mem[output_count + f]);
                                actual_value = $signed(output_rsvd[f]);

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

                    pixel[0] = image_mem[pixel_count*3];
                    pixel[1] = image_mem[pixel_count*3+1];
                    pixel[2] = image_mem[pixel_count*3+2];

                    pixel_count = pixel_count + 1;
                end

            end
            else begin

                repeat (9) begin
                    @(negedge clk);

                    pixel[0] = 8'd0;
                    pixel[1] = 8'd0;
                    pixel[2] = 8'd0;

                    @(posedge clk);

                    cycle_count = cycle_count + 1;

                    if (valid) begin

                        window_count = output_count / 4;
                        out_row = window_count / 30;
                        out_col = window_count % 30;

                        for (f = 0; f < 4; f = f + 1) begin

                            expected_value = $signed(expected_mem[output_count + f]);
                            actual_value = $signed(output_rsvd[f]);

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

            idx = 0;

            for (kr = 0; kr < 3; kr = kr + 1)
                for (kc = 0; kc < 3; kc = kc + 1)
                    for (ch = 0; ch < 3; ch = ch + 1) begin
                        filter0[kr][kc][ch] =
                            $signed(filter_mem[idx]);
                        idx = idx + 1;
                    end

            for (kr = 0; kr < 3; kr = kr + 1)
                for (kc = 0; kc < 3; kc = kc + 1)
                    for (ch = 0; ch < 3; ch = ch + 1) begin
                        filter1[kr][kc][ch] =
                            $signed(filter_mem[idx]);
                        idx = idx + 1;
                    end

            for (kr = 0; kr < 3; kr = kr + 1)
                for (kc = 0; kc < 3; kc = kc + 1)
                    for (ch = 0; ch < 3; ch = ch + 1) begin
                        filter2[kr][kc][ch] =
                            $signed(filter_mem[idx]);
                        idx = idx + 1;
                    end

            for (kr = 0; kr < 3; kr = kr + 1)
                for (kc = 0; kc < 3; kc = kc + 1)
                    for (ch = 0; ch < 3; ch = ch + 1) begin
                        filter3[kr][kc][ch] =
                            $signed(filter_mem[idx]);
                        idx = idx + 1;
                    end

        end

    endtask

endmodule