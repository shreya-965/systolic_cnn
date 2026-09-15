clc;
clear;
clear functions;

image_hex = "../dataset/image.hex";
filter_hex = "../dataset/filter.hex";
expected_hex = "../dataset/expected.hex";

image_data = read_hex_file(image_hex, 8, 3072, false);
filter_data = read_hex_file(filter_hex, 8, 27, true);
expected_data = read_hex_file(expected_hex, 32, 900, true);

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

expected = zeros(30, 30, "int32");
index = 1;

for row = 1:30
    for col = 1:30
        expected(row, col) = int32(expected_data(index));
        index = index + 1;
    end
end

manual = int32(0);

for kr = 1:3
    for kc = 1:3
        for ch = 1:3
            manual = manual + int32(image(kr, kc, ch)) * int32(filter(kr, kc, ch));
        end
    end
end

fprintf("Manual first output: %d\n", manual);

output = conv3x3x3(image, filter);

fprintf("MATLAB first output: %d\n", output(1, 1));

difference = int32(output) - int32(expected);

fprintf("Maximum absolute error: %d\n", max(abs(difference(:))));

if isequal(output, expected)
    fprintf("TEST PASSED\n");
else
    fprintf("TEST FAILED\n");
    [row, col] = find(output ~= expected, 1);
    fprintf("First mismatch at row %d, column %d\n", row, col);
    fprintf("MATLAB: %d\n", output(row, col));
    fprintf("Expected: %d\n", expected(row, col));
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