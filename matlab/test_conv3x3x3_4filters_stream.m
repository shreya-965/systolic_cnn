clear;
clc;

image_data = read_hex_file("../dataset/image.hex",8,3072,false);
filter_data = read_hex_file("../dataset/filter.hex",8,108,true);
expected_data = read_hex_file("../dataset/expected.hex",32,3600,true);

image = zeros(32,32,3,'uint8');

idx = 1;

for row = 1:32
    for col = 1:32
        for ch = 1:3
            image(row,col,ch) = uint8(image_data(idx));
            idx = idx + 1;
        end
    end
end

filters = zeros(3,3,3,4,'int8');

idx = 1;

for f = 1:4
    for kr = 1:3
        for kc = 1:3
            for ch = 1:3
                filters(kr,kc,ch,f) = int8(filter_data(idx));
                idx = idx + 1;
            end
        end
    end
end

expected = zeros(30,30,4,'int32');

idx = 1;

for row = 1:30
    for col = 1:30
        for f = 1:4
            expected(row,col,f) = int32(expected_data(idx));
            idx = idx + 1;
        end
    end
end

filter0 = filters(:,:,:,1);
filter1 = filters(:,:,:,2);
filter2 = filters(:,:,:,3);
filter3 = filters(:,:,:,4);

errors = 0;
output_count = 0;
valid_count = 0;

[~,~] = conv3x3x3_4filters_stream( ...
    uint8([0;0;0]), ...
    filter0,filter1,filter2,filter3,true);

for row = 1:32
    for col = 1:32

        pixel = squeeze(image(row,col,:));

        [output,valid] = conv3x3x3_4filters_stream( ...
            pixel, ...
            filter0, ...
            filter1, ...
            filter2, ...
            filter3, ...
            false);

        if valid

            valid_count = valid_count + 1;

            out_row = row - 2;
            out_col = col - 2;

            for f = 1:4

                output_count = output_count + 1;

                if output(f) ~= expected(out_row,out_col,f)

                    if errors < 10
                        fprintf( ...
                            "Mismatch row=%d col=%d filter=%d DUT=%d EXPECTED=%d\n", ...
                            out_row,out_col,f,output(f),expected(out_row,out_col,f));
                    end

                    errors = errors + 1;
                end

            end
        end
    end
end

fprintf("\nValid windows = %d\n",valid_count);
fprintf("Total outputs = %d\n",output_count);
fprintf("Errors = %d\n",errors);

if errors == 0 && valid_count == 900 && output_count == 3600
    fprintf("TEST PASSED\n");
else
    fprintf("TEST FAILED\n");
end