img = imread('../dataset/open_seam/open_seam_1.jpg');
E = entropyfilt(img);
Eimg = rescale(E);

binary = im2bw(Eimg, 0.5);
BWao = bwareaopen(binary, 2000);

nhood = ones(9);
closeBWao = imclose(BWao, nhood);

% Create the cloth mask
clothmask = imfill(closeBWao, 'holes');

% Convert the mask to an appropriate data type for blurring
numericMask = double(clothmask);

% Apply Gaussian blurring to the mask to smoothen the edges
sigma = 5;
blurredMask = imgaussfilt(numericMask, sigma);

% Threshold the blurred mask to obtain a binary mask
threshold = 0.3;
binaryMask = blurredMask > threshold;

% Apply the binary mask to the original image
% detectedRegion = bsxfun(@times, img, cast(clothmask, 'like', img));

% Visualize the detected and blurred region
% subplot(1, 2, 1), imshow(clothmask), title('Original Mask');
% subplot(1, 2, 2), imshow(detectedRegion), title('Detected Region');

numcloth = nnz(clothmask);

% Calculate the percentage of the image that is white cloth
clothcover = numcloth / numel(clothmask) * 100;

% Display the result
disp(['Percentage of cloth in glove image: ' num2str(clothcover) '%'])