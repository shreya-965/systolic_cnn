`timescale 1ns / 1ps

module tb_conv3x3x3_4filters;

    logic [7:0] image_mem [0:3071];
    logic signed [7:0] filter_mem [0:107];
    logic [31:0] expected_mem [0:3599];

    logic [7:0] image_window [0:2][0:2][0:2];

    logic signed [2:0] filter0 [0:2][0:2][0:2];
    logic signed [2:0] filter1 [0:2][0:2][0:2];
    logic signed [2:0] filter2 [0:2][0:2][0:2];
    logic signed [2:0] filter3 [0:2][0:2][0:2];

    logic signed [12:0] output_rsvd [0:3];

    integer row;
    integer col;
    integer ch;
    integer kr;
    integer kc;
    integer f;
    integer idx;
    integer errors;
    integer output_count;

    integer signed expected_value;
    integer signed dut_value;

    conv3x3x3_4filters_fixpt dut (
        .image_window(image_window),
        .filter0(filter0),
        .filter1(filter1),
        .filter2(filter2),
        .filter3(filter3),
        .output_rsvd(output_rsvd)
    );

    initial begin

        $readmemh("image.hex", image_mem);
        $readmemh("filter.hex", filter_mem);
        $readmemh("expected.hex", expected_mem);

        if ($isunknown(image_mem[0])) begin
            $display("ERROR: image.hex was not loaded correctly.");
            $finish;
        end

        if ($isunknown(filter_mem[0])) begin
            $display("ERROR: filter.hex was not loaded correctly.");
            $finish;
        end

        if ($isunknown(expected_mem[0])) begin
            $display("ERROR: expected.hex was not loaded correctly.");
            $finish;
        end

        errors = 0;
        output_count = 0;

        for (row = 0; row < 30; row = row + 1) begin
            for (col = 0; col < 30; col = col + 1) begin

                for (kr = 0; kr < 3; kr = kr + 1) begin
                    for (kc = 0; kc < 3; kc = kc + 1) begin
                        for (ch = 0; ch < 3; ch = ch + 1) begin

                            idx = ((row + kr) * 32 * 3)
                                + ((col + kc) * 3)
                                + ch;

                            image_window[kr][kc][ch] = image_mem[idx];

                        end
                    end
                end

                idx = 0;

                for (kr = 0; kr < 3; kr = kr + 1) begin
                    for (kc = 0; kc < 3; kc = kc + 1) begin
                        for (ch = 0; ch < 3; ch = ch + 1) begin

                            filter0[kr][kc][ch] = filter_mem[idx];
                            filter1[kr][kc][ch] = filter_mem[27 + idx];
                            filter2[kr][kc][ch] = filter_mem[54 + idx];
                            filter3[kr][kc][ch] = filter_mem[81 + idx];

                            idx = idx + 1;

                        end
                    end
                end

                #1;

                if ($isunknown(output_rsvd[0]) ||
                    $isunknown(output_rsvd[1]) ||
                    $isunknown(output_rsvd[2]) ||
                    $isunknown(output_rsvd[3])) begin

                    $display(
                        "ERROR: Unknown output at row=%0d col=%0d",
                        row, col
                    );

                    errors = errors + 1;

                end
                else begin

                    for (f = 0; f < 4; f = f + 1) begin

                        output_count = output_count + 1;

                        expected_value = $signed(expected_mem[(row * 30 * 4) + (col * 4) + f]);
                        dut_value = $signed(output_rsvd[f]);

                        if (dut_value !== expected_value) begin

                            if (errors < 10) begin
                                $display(
                                    "Mismatch row=%0d col=%0d filter=%0d DUT=%0d EXPECTED=%0d",
                                    row,
                                    col,
                                    f,
                                    dut_value,
                                    expected_value
                                );
                            end

                            errors = errors + 1;
                        end

                        if (row == 0 && col < 5) begin
                            $display(
                                "OUTPUT row=%0d col=%0d filter=%0d = %0d",
                                row,
                                col,
                                f,
                                dut_value
                            );
                        end

                    end

                end

            end
        end

        $display("");
        $display("======================================");
        $display("Total outputs = %0d", output_count);
        $display("Errors        = %0d", errors);
        $display("======================================");

        if (errors == 0 && output_count == 3600) begin
            $display("TEST PASSED");
        end
        else begin
            $display("TEST FAILED");
        end

        $finish;

    end

endmodule