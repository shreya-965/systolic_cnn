function output = conv3x3x3_pixel(image_window, filter)

acc = int32(0);

for kr = 1:3
        for kc = 1:3
                for ch = 1:3
                        pixel = int32(image_window(kr,kc,ch));
                        weight = int32(filter(kr,kc,ch));
                        acc = acc + pixel * weight;
                end
        end
end

output = acc;

end