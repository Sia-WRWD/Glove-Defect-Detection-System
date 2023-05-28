% Convert the image to the HSV color space
% img = imread('..\dataset\dirty_and_stain\dirty_and_stain_5.jpeg');
Ihsv = rgb2hsv(img);

% Extract the hue, saturation, and value channels
hue = Ihsv(:, :, 1);
saturation = Ihsv(:, :, 2);
value = Ihsv(:, :, 3);

% Create the pink mask
pinkmask = (hue >= 0.85 | hue <= 0.04) & saturation >= 0.15 & value >= 0.2; %Saturation >= 0.4, Value >= 0.2, best.

% Convert the mask to an appropriate data type for blurring
numericMask = double(pinkmask);

% Apply Gaussian blurring to the mask to smoothen the edges
sigma = 10; % Adjust the value of sigma as needed
blurredMask = imgaussfilt(numericMask, sigma);

% Threshold the blurred mask to obtain a binary mask
threshold = 0.6; % Adjust the threshold value as needed
binaryMask = blurredMask > threshold;

% Apply the binary mask to the original image
detectedRegion = bsxfun(@times, img, cast(binaryMask, 'like', img));

% Visualize the detected and blurred region
subplot(1, 3, 1), imshow(pinkmask), title('Original Mask');
subplot(1, 3, 2), imshow(binaryMask), title('Blurred Mask');
subplot(1, 3, 3), imshow(detectedRegion), title('Detected Region');

% Count the number of pink pixels with color removal
numpink = nnz(binaryMask);

% Calculate the percentage of the image that is pink with color removal
percentpink = numpink / numel(binaryMask) * 100;

% Display the result
disp(['Percentage of pink in glove image (with color removal): ' num2str(percentpink) '%'])
