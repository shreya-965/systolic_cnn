function output = conv3x3x3_4filters(image_window, filter0, filter1, filter2, filter3)
%#codegen

output = zeros(1,4,'int32');

output(1) = conv_one_filter(image_window, filter0);
output(2) = conv_one_filter(image_window, filter1);
output(3) = conv_one_filter(image_window, filter2);
output(4) = conv_one_filter(image_window, filter3);

end

function output = conv_one_filter(image_window, filter)

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