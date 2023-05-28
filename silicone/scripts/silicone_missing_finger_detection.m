function [silicone_missing_finger, missing_fingers_value] = silicone_missing_finger_detection(img)

% read the image
% img = imread('../dataset/missing_finger/missing_finger_1.jpeg');
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

% Get the palm from binary mask.
open = strel('disk', 50);
palm_img = imopen(binaryMask, open);

% Get only the fingers.
open = strel('disk', 4); % To remove noise or small useless pixels.
fingers = imopen(binaryMask - palm_img, open); % Get the fingers.
fingers = imbinarize(fingers);
sizeThreshold = 5000; % Accept size of fingers that are greater or equal to 5000 pixels (finger size)
finger = bwpropfilt(fingers, 'Area', [sizeThreshold Inf]);

% Perform connected component analysis on the finger mask to count the number of fingers
cc = bwconncomp(finger);
numFingers = cc.NumObjects;

% fprintf('Number of fingers: %d',fingernum);
 if (numFingers ~= 5)
    disp('-> Finger not enough');
 else
    disp('-> Not finger not enough');
 end

% Display the finger mask and the number of fingers
% figure, imshow(finger), title(sprintf('Detected Fingers: %d', numFingers));

axes1 = findobj(0, 'tag', 'axes1');
axes(axes1);
imshow(finger);
silicone_missing_finger= finger;

missing_fingers_value = 5- numFingers;
save('variables');

end