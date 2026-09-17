function data = read_hex_file(filename, width, count, signed)

fid = fopen(filename, 'r');

if fid == -1
    error("Cannot open file: %s", filename);
end

data = zeros(count, 1);

for i = 1:count
    line = fgetl(fid);

    if ~ischar(line)
        fclose(fid);
        error("Unexpected end of file: %s", filename);
    end

    % Convert hex to DOUBLE first.
    value = double(hex2dec(strtrim(line)));

    % Convert two's-complement representation.
    if signed && width == 8
        if value >= 128
            value = value - 256;
        end

    elseif signed && width == 32
        if value >= 2147483648
            value = value - 4294967296;
        end
    end

    data(i) = value;
end

fclose(fid);

end