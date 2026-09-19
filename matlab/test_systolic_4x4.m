clear;
clc;

image_file = '../dataset/image.hex';
filter_file = '../dataset/filter.hex';
expected_file = '../dataset/expected.hex';

image_raw = read_hex_file(image_file);
filter_raw = read_hex_file(filter_file);
expected_raw = read_hex_file(expected_file);

fprintf('Image values    = %d\n',numel(image_raw));
fprintf('Filter values   = %d\n',numel(filter_raw));
fprintf('Expected values = %d\n',numel(expected_raw));

assert(numel(image_raw) == 3072);
assert(numel(filter_raw) == 108);
assert(numel(expected_raw) == 3600);

image = uint8(image_raw);
filter_data = uint8(filter_raw);
expected_data = uint32(expected_raw);

image = reshape(image,3,[])';

filters = zeros(3,3,3,4,'int8');

p = 1;

for f = 1:4
    for kr = 1:3
        for kc = 1:3
            for ch = 1:3

                filters(kr,kc,ch,f) = ...
                    typecast(filter_data(p),'int8');

                p = p + 1;
            end
        end
    end
end

expected_signed = typecast(expected_data,'int32');

expected = zeros(30,30,4,'int32');

p = 1;

for row = 1:30
    for col = 1:30
        for f = 1:4

            expected(row,col,f) = expected_signed(p);

            p = p + 1;
        end
    end
end

filter0 = filters(:,:,:,1);
filter1 = filters(:,:,:,2);
filter2 = filters(:,:,:,3);
filter3 = filters(:,:,:,4);

systolic_4x4( ...
    uint8([0 0 0]), ...
    filter0, ...
    filter1, ...
    filter2, ...
    filter3, ...
    true);

pixel_count = 0;
output_count = 0;
error_count = 0;
cycle_count = 0;

total_pixels = 1024;
total_outputs = 3600;

while output_count < total_outputs

    cycle_count = cycle_count + 1;

    if pixel_count < total_pixels
        pixel = image(pixel_count + 1,:);
    else
        pixel = uint8([0 0 0]);
    end

    [output,valid,ready] = systolic_4x4( ...
        pixel, ...
        filter0, ...
        filter1, ...
        filter2, ...
        filter3, ...
        false);

    if ready && pixel_count < total_pixels
        pixel_count = pixel_count + 1;
    end

    if valid

        window_number = floor(output_count / 4);

        row = floor(window_number / 30) + 1;
        col = mod(window_number,30) + 1;

        for f = 1:4

            actual = output(f);
            expected_value = expected(row,col,f);

            if actual ~= expected_value

                error_count = error_count + 1;

                if error_count <= 20
                    fprintf( ...
                        'ERROR row=%d col=%d filter=%d expected=%d actual=%d\n', ...
                        row-1, ...
                        col-1, ...
                        f-1, ...
                        expected_value, ...
                        actual);
                end

            elseif output_count < 20

                fprintf( ...
                    'OUTPUT row=%d col=%d filter=%d = %d\n', ...
                    row-1, ...
                    col-1, ...
                    f-1, ...
                    actual);
            end
        end

        output_count = output_count + 4;
    end

    if cycle_count > 20000
        error('TIMEOUT');
    end
end

fprintf('\n');
fprintf('Input pixels = %d\n',pixel_count);
fprintf('Total outputs = %d\n',output_count);
fprintf('Errors = %d\n',error_count);
fprintf('Cycles = %d\n',cycle_count);

if error_count == 0
    fprintf('TEST PASSED\n');
else
    fprintf('TEST FAILED\n');
end


function data = read_hex_file(filename)

fid = fopen(filename,'r');

if fid == -1
    error('Cannot open %s',filename);
end

data = zeros(0,1);

while true

    line = fgetl(fid);

    if ~ischar(line)
        break;
    end

    line = strtrim(line);

    if isempty(line)
        continue;
    end

    value = sscanf(line,'%x');

    if isempty(value)
        fclose(fid);
        error('Invalid HEX value: %s',line);
    end

    data(end+1,1) = value;
end

fclose(fid);

end