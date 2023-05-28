function silicone_dirty_stain = silicone_dirty_stain_detection(img)

% read the image
% img = imread('../dataset/dirty_and_stain/dirty_and_stain_2.jpeg');
Ihsv = rgb2hsv(img);

% Extract the hue, saturation, and value channels
hue = Ihsv(:, :, 1);
saturation = Ihsv(:, :, 2);
value = Ihsv(:, :, 3);

% Create the pink mask
pinkmask = (hue >= 0.85 | hue <= 0.04) & saturation >= 0.15 & value >= 0.2;

% Convert the mask to an appropriate data type for blurring
numericMask = double(pinkmask);

% Apply Gaussian blurring to the mask to smoothen the edges
sigma = 5;
blurredMask = imgaussfilt(numericMask, sigma);

% Threshold the blurred mask to obtain a binary mask
threshold = 0.5;
binaryMask = blurredMask > threshold;

% Perform morphological operations to enhance the black dots
se = strel('disk', 3);
blackDotsMask = imopen(binaryMask, se);

% Invert the black dots mask to obtain the black dots on a white background
blackDotsMask = ~blackDotsMask;

% Perform connected component analysis to identify individual black dots
cc = bwconncomp(blackDotsMask);

% Filter out small connected components (background) based on a threshold area
maxArea = 500;
numPixels = cellfun(@numel, cc.PixelIdxList);
idxStain = find(numPixels <= maxArea);

% Create a mask for only the detected stain
stainMask = false(size(blackDotsMask));
for i = 1:numel(idxStain)
    stainMask(cc.PixelIdxList{idxStain(i)}) = true;
end

% Perform connected component analysis again on the stain mask
ccStain = bwconncomp(stainMask);
numStain = ccStain.NumObjects;

% Loop through each stain and perform further analysis if needed
for i = 1:numStain
    stainPixels = ccStain.PixelIdxList{i};
    
    % Calculate the bounding box of the stain
    [rows, cols] = ind2sub(size(stainMask), stainPixels);
    xmin = min(cols);
    xmax = max(cols);
    ymin = min(rows);
    ymax = max(rows);
    
    % Increase the size of the bounding box
    expansionPixels = 18;
    xmin = max(1, xmin - expansionPixels);
    xmax = min(size(img, 2), xmax + expansionPixels);
    ymin = max(1, ymin - expansionPixels);
    ymax = min(size(img, 1), ymax + expansionPixels);
    
    % Draw the expanded bounding box on the original image
    shape = 'Rectangle'; % Shape type for the bounding box
    position = [xmin, ymin, xmax-xmin, ymax-ymin]; % Bounding box position [x, y, width, height]
    img = insertShape(img, shape, position, 'Color', 'red', 'LineWidth', 2);
    
    % Add text to the bounding box
    textPosition = [xmin, ymin-25]; % Adjust the text position as needed
    textString = sprintf('Stain %d', i); % Customize the text string as needed
    img = insertText(img, textPosition, textString, 'FontSize', 12, 'TextColor', 'red');
end

% Display the original image with the expanded bounding boxes and text
% figure, imshow(img);

axes1 = findobj(0, 'tag', 'axes1');
axes(axes1);
imshow(img);
silicone_dirty_stain= img;

save('variables');

end