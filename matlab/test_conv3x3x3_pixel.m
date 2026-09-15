clc;
clear;
clear functions;

image_data = read_hex_file("../dataset/image.hex", 8, 3072, false);
filter_data = read_hex_file("../dataset/filter.hex", 8, 27, true);

image = zeros(32, 32, 3, "uint8");
index = 1;

for row = 1:32
        for col = 1:32
                for ch = 1:3
                        image(row, col, ch) = uint8(image_data(index));
                        index = index + 1;
                end
        end
end

filter = zeros(3, 3, 3, "int8");
index = 1;

for kr = 1:3
        for kc = 1:3
                for ch = 1:3
                        filter(kr, kc, ch) = int8(filter_data(index));
                        index = index + 1;
                end
        end
end

image_window = image(1:3, 1:3, :);

output = conv3x3x3_pixel(image_window, filter);

expected = read_hex_file("../dataset/expected.hex", 32, 900, true);

fprintf("MATLAB output: %d\n", output);
fprintf("Expected output: %d\n", expected(1));

if output == expected(1)
        fprintf("TEST PASSED\n");
else
        fprintf("TEST FAILED\n");
end

function data = read_hex_file(filename, width, count, is_signed)

fid = fopen(filename, "r");

if fid == -1
        error("Cannot open file: %s", filename);
end

values = textscan(fid, "%s");
fclose(fid);

hex_values = values{1};

if numel(hex_values) ~= count
        error("Expected %d values in %s, found %d", count, filename, numel(hex_values));
end

data = zeros(count, 1, "int32");

for i = 1:count
        value = hex2dec(hex_values{i});

        if is_signed && width == 8 && value >= 128
                value = value - 256;
        elseif is_signed && width == 32 && value >= 2147483648
                value = value - 4294967296;
        end

        data(i) = int32(value);
end

end