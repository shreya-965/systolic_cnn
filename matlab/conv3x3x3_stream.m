function [output, valid] = conv3x3x3_stream(pixel, filter, reset)
%#codegen

persistent line1 line2 window row col output_reg valid_reg

if isempty(line1)
    line1 = zeros(32,1,'uint32');
    line2 = zeros(32,1,'uint32');
    window = zeros(3,3,3,'uint8');
    row = int32(0);
    col = int32(0);
    output_reg = int32(0);
    valid_reg = false;
end

if reset
    line1(:) = uint32(0);
    line2(:) = uint32(0);
    window(:) = uint8(0);
    row = int32(0);
    col = int32(0);
    output_reg = int32(0);
    valid_reg = false;
else
    top_word = line2(col+1);
    middle_word = line1(col+1);

    top = zeros(1,3,'uint8');
    middle = zeros(1,3,'uint8');

    top(1) = uint8(bitand(top_word,uint32(255)));
    top(2) = uint8(bitand(bitshift(top_word,-8),uint32(255)));
    top(3) = uint8(bitand(bitshift(top_word,-16),uint32(255)));

    middle(1) = uint8(bitand(middle_word,uint32(255)));
    middle(2) = uint8(bitand(bitshift(middle_word,-8),uint32(255)));
    middle(3) = uint8(bitand(bitshift(middle_word,-16),uint32(255)));

    next_window = window;

    for ch = 1:3
        next_window(1,1:2,ch) = window(1,2:3,ch);
        next_window(2,1:2,ch) = window(2,2:3,ch);
        next_window(3,1:2,ch) = window(3,2:3,ch);

        next_window(1,3,ch) = top(ch);
        next_window(2,3,ch) = middle(ch);
        next_window(3,3,ch) = pixel(ch);
    end

    if row >= 2 && col >= 2
        acc = int32(0);

        for kr = 1:3
            for kc = 1:3
                for ch = 1:3
                    acc = acc + int32(next_window(kr,kc,ch)) * ...
                        int32(filter(kr,kc,ch));
                end
            end
        end

        output_reg = acc;
        valid_reg = true;
    else
        output_reg = int32(0);
        valid_reg = false;
    end

    line2(col+1) = middle_word;

    line1(col+1) = ...
        uint32(pixel(1)) + ...
        bitshift(uint32(pixel(2)),8) + ...
        bitshift(uint32(pixel(3)),16);

    window = next_window;

    if col == 31
        col = int32(0);
        row = row + 1;
    else
        col = col + 1;
    end
end

output = output_reg;
valid = valid_reg;
end