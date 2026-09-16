`timescale 1ns/1ps

module tb_conv3x3x3_pixel_fixpt;

logic [7:0] image_window [0:2][0:2][0:2];
logic signed [2:0] filter [0:2][0:2][0:2];
logic [11:0] output_rsvd;

logic [7:0] image_mem [0:3071];
logic signed [7:0] filter_mem [0:26];
logic [31:0] expected_mem [0:899];

integer row;
integer col;
integer kr;
integer kc;
integer ch;
integer index;
integer errors;
integer expected_value;

conv3x3x3_pixel_fixpt dut (
        .image_window(image_window),
        .filter(filter),
        .output_rsvd(output_rsvd)
);

initial begin
$readmemh("image.hex",image_mem);
$readmemh("filter.hex",filter_mem);
$readmemh("expected.hex",expected_mem);
        errors = 0;

        for(kr = 0; kr < 3; kr = kr + 1) begin
                for(kc = 0; kc < 3; kc = kc + 1) begin
                        for(ch = 0; ch < 3; ch = ch + 1) begin
                                index = (kr * 3 + kc) * 3 + ch;
                                filter[kr][kc][ch] = filter_mem[index];
                        end
                end
        end

        for(row = 0; row < 30; row = row + 1) begin
                for(col = 0; col < 30; col = col + 1) begin

                        for(kr = 0; kr < 3; kr = kr + 1) begin
                                for(kc = 0; kc < 3; kc = kc + 1) begin
                                        for(ch = 0; ch < 3; ch = ch + 1) begin
                                                index = ((row + kr) * 32 + (col + kc)) * 3 + ch;
                                                image_window[kr][kc][ch] = image_mem[index];
                                        end
                                end
                        end

                        #1;

                        expected_value = expected_mem[row * 30 + col];

                        if(output_rsvd !== expected_value[11:0]) begin
                                errors = errors + 1;
                                $display("ERROR row=%0d col=%0d DUT=%0d EXPECTED=%0d",row,col,output_rsvd,expected_value);
                        end

                        if((row == 0) && (col < 5)) begin
                                $display("row=%0d col=%0d DUT=%0d EXPECTED=%0d",row,col,output_rsvd,expected_value);
                        end
                end
        end

        if(errors == 0)
                $display("TEST PASSED");
        else
                $display("TEST FAILED: %0d errors",errors);

        $finish;
end

endmodule