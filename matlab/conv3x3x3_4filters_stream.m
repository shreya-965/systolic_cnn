function [output, valid] = conv3x3x3_4filters_stream(pixel, filter0, filter1, filter2, filter3, reset)
%#codegen

persistent line1 line2 window row col

if isempty(line1)
    line1 = zeros(32,1,'uint32');
    line2 = zeros(32,1,'uint32');
    window = zeros(3,3,3,'uint8');
    row = int32(0);
    col = int32(0);
end

output = zeros(1,4,'int32');
valid = false;

if reset
    row = int32(0);
    col = int32(0);
    window = zeros(3,3,3,'uint8');
else

    top_word = line2(col+1);
    middle_word = line1(col+1);

    line2(col+1) = middle_word;

    line1(col+1) = ...
        uint32(pixel(1)) + ...
        bitshift(uint32(pixel(2)),8) + ...
        bitshift(uint32(pixel(3)),16);

    top_r = uint8(bitand(top_word,255));
    top_g = uint8(bitand(bitshift(top_word,-8),255));
    top_b = uint8(bitand(bitshift(top_word,-16),255));

    middle_r = uint8(bitand(middle_word,255));
    middle_g = uint8(bitand(bitshift(middle_word,-8),255));
    middle_b = uint8(bitand(bitshift(middle_word,-16),255));

    window(:,1,:) = window(:,2,:);
    window(:,2,:) = window(:,3,:);

    window(1,3,1) = top_r;
    window(1,3,2) = top_g;
    window(1,3,3) = top_b;

    window(2,3,1) = middle_r;
    window(2,3,2) = middle_g;
    window(2,3,3) = middle_b;

    window(3,3,1) = pixel(1);
    window(3,3,2) = pixel(2);
    window(3,3,3) = pixel(3);

    if row >= 2 && col >= 2

        output(1) = conv_one_filter(window,filter0);
        output(2) = conv_one_filter(window,filter1);
        output(3) = conv_one_filter(window,filter2);
        output(4) = conv_one_filter(window,filter3);

        valid = true;
    end

    if col == 31
        col = int32(0);
        if row < 31
            row = row + 1;
        end
    else
        col = col + 1;
    end

end

end

function output = conv_one_filter(image_window,filter)

acc = int32(0);

for kr = 1:3
    for kc = 1:3
        for ch = 1:3
            pixel_value = int32(image_window(kr,kc,ch));
            weight = int32(filter(kr,kc,ch));
            acc = acc + pixel_value * weight;
        end
    end
end

output = acc;

end