clear;
clc;

image_data = read_hex_file("../dataset/image.hex", 8, 3072, false);
filter_data = read_hex_file("../dataset/filter.hex", 8, 27, true);
expected = read_hex_file("../dataset/expected.hex", 32, 900, true);

image = zeros(32,32,3,'uint8');
filter = zeros(3,3,3,'int8');

index = 1;
for row = 1:32
    for col = 1:32
        for ch = 1:3
            image(row,col,ch) = uint8(image_data(index));
            index = index + 1;
        end
    end
end

index = 1;
for kr = 1:3
    for kc = 1:3
        for ch = 1:3
            filter(kr,kc,ch) = int8(filter_data(index));
            index = index + 1;
        end
    end
end

conv3x3x3_stream(zeros(1,3,'uint8'),filter,true);

output_index = 1;
errors = 0;

for row = 1:32
    for col = 1:32
        pixel = image(row,col,:);
        pixel = reshape(pixel,1,3);

        [output,valid] = conv3x3x3_stream(pixel,filter,false);

        if valid
            expected_value = expected(output_index);

            if output ~= expected_value
                errors = errors + 1;
                fprintf("Mismatch at output %d: DUT=%d EXPECTED=%d\n", ...
                    output_index,output,expected_value);
            end

            if output_index <= 5
                fprintf("Output %d: DUT=%d EXPECTED=%d\n", ...
                    output_index,output,expected_value);
            end

            output_index = output_index + 1;
        end
    end
end

fprintf("Valid outputs: %d\n",output_index-1);
fprintf("Errors: %d\n",errors);

if errors == 0 && output_index == 901
    fprintf("TEST PASSED\n");
else
    fprintf("TEST FAILED\n");
end

function data = read_hex_file(filename,width,count,is_signed)
    fid = fopen(filename,'r');
    data = zeros(count,1);

    for i = 1:count
        line = fgetl(fid);
        value = hex2dec(strtrim(line));

        if is_signed && width == 8 && value >= 128
            value = value - 256;
        elseif is_signed && width == 32 && value >= 2147483648
            value = value - 4294967296;
        end

        data(i) = value;
    end

    fclose(fid);
end