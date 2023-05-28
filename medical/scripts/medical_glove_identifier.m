function percentblue = medical_glove_identifier(img)

% Convert the image to the HSV color space
% img = imread('..\dataset\dirty_and_stain\dirty_and_stain_5.jpeg');
Ihsv = rgb2hsv(img);

% Extract the hue, saturation, and value channels
hue = Ihsv(:, :, 1);
saturation = Ihsv(:, :, 2);
value = Ihsv(:, :, 3);

% Create the blue mask
bluemask = hue >= 0.55 & hue <= 0.67 & saturation >=0.2 & value >=0.2;

% Apply the binary mask to the original image
% detectedRegion = bsxfun(@times, img, cast(bluemask, 'like', img));

% Visualize the detected and blurred region
% subplot(1, 2, 1), imshow(bluemask), title('Original Mask');
% subplot(1, 2, 2), imshow(detectedRegion), title('Detected Region');

% Count the number of pink pixels with color removal
numblue = nnz(bluemask);

% Calculate the percentage of the image that is pink with color removal
percentblue = numblue / numel(bluemask) * 100;

% Display the result
disp(['Percentage of blue in glove image (with color removal): ' num2str(percentblue) '%'])

end