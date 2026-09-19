function [output, valid, ready] = systolic_4x4(pixel, filter0, filter1, filter2, filter3, reset)
%#codegen

persistent line1 line2
persistent window weights
persistent pe_acc
persistent row col
persistent state cycle

if isempty(line1)
    line1 = zeros(32,1,'uint32');
    line2 = zeros(32,1,'uint32');

    window = zeros(27,1,'uint8');
    weights = zeros(108,1,'int8');

    pe_acc = zeros(16,1,'int32');

    row = int32(0);
    col = int32(0);
    state = int32(0);
    cycle = int32(0);
end

output = zeros(4,1,'int32');
valid = false;
ready = false;

if reset

    row = int32(0);
    col = int32(0);
    state = int32(0);
    cycle = int32(0);

    window(:) = uint8(0);
    weights(:) = int8(0);
    pe_acc(:) = int32(0);

else

    if state == 0

        ready = true;

        top_word = line2(col + 1);
        middle_word = line1(col + 1);

        line2(col + 1) = middle_word;

        line1(col + 1) = ...
            uint32(pixel(1)) + ...
            bitshift(uint32(pixel(2)),8) + ...
            bitshift(uint32(pixel(3)),16);

        top_r = uint8(bitand(top_word,255));
        top_g = uint8(bitand(bitshift(top_word,-8),255));
        top_b = uint8(bitand(bitshift(top_word,-16),255));

        middle_r = uint8(bitand(middle_word,255));
        middle_g = uint8(bitand(bitshift(middle_word,-8),255));
        middle_b = uint8(bitand(bitshift(middle_word,-16),255));

        new_window = window;

        new_window(1) = window(4);
        new_window(2) = window(5);
        new_window(3) = window(6);
        new_window(4) = window(7);
        new_window(5) = window(8);
        new_window(6) = window(9);
        new_window(7) = top_r;
        new_window(8) = top_g;
        new_window(9) = top_b;

        new_window(10) = window(13);
        new_window(11) = window(14);
        new_window(12) = window(15);
        new_window(13) = window(16);
        new_window(14) = window(17);
        new_window(15) = window(18);
        new_window(16) = middle_r;
        new_window(17) = middle_g;
        new_window(18) = middle_b;

        new_window(19) = window(22);
        new_window(20) = window(23);
        new_window(21) = window(24);
        new_window(22) = window(25);
        new_window(23) = window(26);
        new_window(24) = window(27);
        new_window(25) = pixel(1);
        new_window(26) = pixel(2);
        new_window(27) = pixel(3);

        window = new_window;

        if row >= 2 && col >= 2

            p = 1;

            for kr = 1:3
                for kc = 1:3
                    for ch = 1:3

                        weights(p) = filter0(kr,kc,ch);
                        weights(27+p) = filter1(kr,kc,ch);
                        weights(54+p) = filter2(kr,kc,ch);
                        weights(81+p) = filter3(kr,kc,ch);

                        p = p + 1;
                    end
                end
            end

            pe_acc(:) = int32(0);
            cycle = int32(0);
            state = int32(1);
        end

        if col == 31
            col = int32(0);

            if row < 31
                row = row + 1;
            end
        else
            col = col + 1;
        end

    else

        ready = false;

        next_acc = pe_acc;

        for f = 0:3

            for lane = 0:3

                pe = f * 4 + lane + 1;
                index = cycle * 4 + lane + 1;

                if index <= 27

                    activation = int32(window(index));
                    weight = int32(weights(f * 27 + index));

                    next_acc(pe) = ...
                        pe_acc(pe) + activation * weight;

                end
            end
        end

        pe_acc = next_acc;

        if cycle == 6

            output(1) = ...
                next_acc(1) + ...
                next_acc(2) + ...
                next_acc(3) + ...
                next_acc(4);

            output(2) = ...
                next_acc(5) + ...
                next_acc(6) + ...
                next_acc(7) + ...
                next_acc(8);

            output(3) = ...
                next_acc(9) + ...
                next_acc(10) + ...
                next_acc(11) + ...
                next_acc(12);

            output(4) = ...
                next_acc(13) + ...
                next_acc(14) + ...
                next_acc(15) + ...
                next_acc(16);

            valid = true;

            state = int32(0);
            cycle = int32(0);

        else

            cycle = cycle + 1;

        end
    end
end

end