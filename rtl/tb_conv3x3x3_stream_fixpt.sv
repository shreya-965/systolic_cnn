`timescale 1ns/1ps

module tb_conv3x3x3_stream;

    logic clk;
    logic reset;
    logic clk_enable;
    logic [7:0] pixel [0:2];
    logic signed [2:0] filter [0:2][0:2][0:2];
    logic reset_1;

    logic ce_out;
    logic [11:0] output_rsvd;
    logic valid;

    logic [7:0] image_mem [0:3071];
    logic signed [7:0] filter_mem [0:26];
    logic [31:0] expected_mem [0:899];

    integer row;
    integer col;
    integer ch;
    integer kr;
    integer kc;
    integer i;
    integer expected_index;
    integer valid_count;
    integer errors;

    conv3x3x3_stream_fixpt dut (
        .clk(clk),
        .reset(reset),
        .clk_enable(clk_enable),
        .pixel(pixel),
        .filter(filter),
        .reset_1(reset_1),
        .ce_out(ce_out),
        .output_rsvd(output_rsvd),
        .valid(valid)
    );

    always #5 clk = ~clk;

    function automatic signed [31:0] signed_expected(input [31:0] value);
        signed_expected = $signed(value);
    endfunction

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        clk_enable = 1'b1;
        reset_1 = 1'b1;

        for (ch = 0; ch < 3; ch = ch + 1)
            pixel[ch] = 8'd0;

        for (kr = 0; kr < 3; kr = kr + 1)
            for (kc = 0; kc < 3; kc = kc + 1)
                for (ch = 0; ch < 3; ch = ch + 1)
                    filter[kr][kc][ch] = 3'sd0;

        $readmemh("image.hex", image_mem);
        $readmemh("filter.hex", filter_mem);
        $readmemh("expected.hex", expected_mem);

        for (kr = 0; kr < 3; kr = kr + 1)
            for (kc = 0; kc < 3; kc = kc + 1)
                for (ch = 0; ch < 3; ch = ch + 1)
                    filter[kr][kc][ch] =
                        filter_mem[(kr * 3 + kc) * 3 + ch][2:0];

        valid_count = 0;
        errors = 0;

        repeat (3) @(posedge clk);
        reset = 1'b0;
        reset_1 = 1'b0;

        for (row = 0; row < 32; row = row + 1) begin
            for (col = 0; col < 32; col = col + 1) begin

                pixel[0] = image_mem[(row * 32 + col) * 3 + 0];
                pixel[1] = image_mem[(row * 32 + col) * 3 + 1];
                pixel[2] = image_mem[(row * 32 + col) * 3 + 2];

                @(posedge clk);
                #1;

                if (valid) begin

                    if ($isunknown(output_rsvd)) begin
                        $display("ERROR: output is X at valid_count=%0d",
                                 valid_count);
                        errors = errors + 1;
                    end
                    else begin
                        expected_index = valid_count;

                        if (output_rsvd !== expected_mem[expected_index][11:0]) begin
                            $display("MISMATCH %0d: DUT=%0d EXPECTED=%0d",
                                     valid_count,
                                     output_rsvd,
                                     expected_mem[expected_index][11:0]);
                            errors = errors + 1;
                        end
                        else if (valid_count < 5) begin
                            $display("OUTPUT %0d: %0d",
                                     valid_count,
                                     output_rsvd);
                        end
                    end

                    valid_count = valid_count + 1;
                end
            end
        end

        repeat (5) begin
        @(posedge clk);
        #1;

        if (valid && valid_count < 900) begin
                if ($isunknown(output_rsvd)) begin
                $display("ERROR: output is X at valid_count=%0d",
                        valid_count);
                errors = errors + 1;
                end
                else if (output_rsvd !== expected_mem[valid_count][11:0]) begin
                $display("MISMATCH %0d: DUT=%0d EXPECTED=%0d",
                        valid_count,
                        output_rsvd,
                        expected_mem[valid_count][11:0]);
                errors = errors + 1;
                end

                valid_count = valid_count + 1;
        end
        end

        $display("");
        $display("VALID OUTPUTS = %0d", valid_count);
        $display("ERRORS        = %0d", errors);
        
        if (valid_count != 900) begin
        $display("TEST FAILED: expected 900 valid outputs.");
        end
        else if (errors != 0) begin
        $display("TEST FAILED.");
        end
        else begin
        $display("TEST PASSED.");
        end

        $finish;
    end

endmodule