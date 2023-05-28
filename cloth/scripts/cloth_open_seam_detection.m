
function cloth_open_seam = cloth_open_seam_detection(img)
% img = imread('../dataset/open_seam/open_seam_7.jpg');
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
detectedRegion = bsxfun(@times, img, cast(binaryMask, 'like', img));

% color image segmentation
hsvImg = rgb2hsv(detectedRegion);
hue = hsvImg(:,:,1);
saturation = hsvImg(:,:,2)*2.5; 
value = hsvImg(:,:,3);

[hue, saturation, value] = rgb2hsv(hue, saturation, value);

binaryMask = (hue > 1) | (hue < 0.5); % Create a binary mask for OSH values outside the range [0.5, 1]
defectMask = imclearborder(binaryMask, 4); % Remove objects touching the image border
defectMaskErosion = imerode(defectMask, strel('disk', 4)); % Perform erosion on the mask
defectMaskDilation = imdilate(defectMaskErosion, strel('disk', 5)); % Perform dilation on the eroded mask
defectMask = imclearborder(defectMaskDilation, 4); % Remove objects touching the image border again

sizeThreshold = 250; % Accept size of fingers that are greater or equal to 5000 pixels (finger size)
openSeam = bwpropfilt(defectMask, 'Area', [sizeThreshold Inf]);

cc = bwconncomp(openSeam);
numOpenSeam = cc.NumObjects;

% Loop through each stain and perform further analysis if needed
for i = 1:numOpenSeam
    openSeamPixels = cc.PixelIdxList{i};
    
    % Calculate the bounding box of the stain
    [rows, cols] = ind2sub(size(openSeam), openSeamPixels);
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
    textString = sprintf('Open Seam %d', i); % Customize the text string as needed
    img = insertText(img, textPosition, textString, 'FontSize', 12, 'TextColor', 'red');
end

% Display the original image with the expanded bounding boxes and text
% figure, imshow(img);

axes1 = findobj(0, 'tag', 'axes1');
axes(axes1);
imshow(img);
cloth_open_seam= img;

save('variables');

end