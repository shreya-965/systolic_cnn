function output = conv3x3x3(image, filter)

output = zeros(30, 30, 'int32');

for row = 1:30
    for col = 1:30
        acc = int32(0);
        for kr = 1:3
            for kc = 1:3
                for ch = 1:3
                    pixel = int32(image(row + kr - 1, col + kc - 1, ch));
                    weight = int32(filter(kr, kc, ch));
                    acc = acc + pixel * weight;
                end
            end
        end
        output(row, col) = acc;
    end
end

end