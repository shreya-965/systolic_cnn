`timescale 1ns/1ps

import conv3x3x3_pixel_fixpt_pkg::*;

module tb_conv3x3x3_pixel_fixpt;

        logic [5:0] image_window [0:2][0:2][0:2];
        logic signed [2:0] filter [0:2][0:2][0:2];
        logic [7:0] output_rsvd;

        logic [7:0] image_mem [0:3071];
        logic [7:0] filter_mem [0:26];
        logic [31:0] expected_mem [0:899];

        integer kr;
        integer kc;
        integer ch;
        integer index;
        integer image_index;
        integer expected_value;

        conv3x3x3_pixel_fixpt dut (
                .image_window(image_window),
                .filter(filter),
                .output_rsvd(output_rsvd)
        );

        initial begin
                $readmemh("C:/Users/user/Desktop/SHREYASHREE/files/systolic_cnn/dataset/image.hex", image_mem);
                $readmemh("C:/Users/user/Desktop/SHREYASHREE/files/systolic_cnn/dataset/filter.hex", filter_mem);
                $readmemh("C:/Users/user/Desktop/SHREYASHREE/files/systolic_cnn/dataset/expected.hex", expected_mem);

                if ($isunknown(image_mem[0])) begin
                        $display("ERROR: image.hex was not loaded");
                        $finish;
                end

                if ($isunknown(filter_mem[0])) begin
                        $display("ERROR: filter.hex was not loaded");
                        $finish;
                end

                if ($isunknown(expected_mem[0])) begin
                        $display("ERROR: expected.hex was not loaded");
                        $finish;
                end

                $display("image_mem[0]    = %02h", image_mem[0]);
                $display("filter_mem[0]   = %02h", filter_mem[0]);
                $display("expected_mem[0] = %08h", expected_mem[0]);

                for (kr = 0; kr < 3; kr = kr + 1) begin
                        for (kc = 0; kc < 3; kc = kc + 1) begin
                                for (ch = 0; ch < 3; ch = ch + 1) begin
                                        image_index = ((kr * 32) + kc) * 3 + ch;
                                        image_window[kr][kc][ch] = image_mem[image_index][5:0];
                                end
                        end
                end

                index = 0;

                for (kr = 0; kr < 3; kr = kr + 1) begin
                        for (kc = 0; kc < 3; kc = kc + 1) begin
                                for (ch = 0; ch < 3; ch = ch + 1) begin
                                        filter[kr][kc][ch] = $signed(filter_mem[index][2:0]);
                                        index = index + 1;
                                end
                        end
                end

                #1;

                expected_value = expected_mem[0];

                $display("DUT output     : %0d", output_rsvd);
                $display("Expected output: %0d", expected_value);

                if (output_rsvd == expected_value[7:0]) begin
                        $display("TEST PASSED");
                end
                else begin
                        $display("TEST FAILED");
                        $display("Expected hex: %08h", expected_value);
                        $display("Actual hex  : %02h", output_rsvd);
                end

                $finish;
        end

endmodule