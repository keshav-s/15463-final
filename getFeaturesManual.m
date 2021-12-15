function [puc1,puc2,pvc1,pvc2] = getFeaturesManual(im_on, im_off, bwPatternParams, thresh, do_plot)
num_feats = bwPatternParams.num_feats;
total_num_pts = num_feats+floor(num_feats/4);
im_diff = im_on-im_off;
im_thresh = (im_diff>thresh);
im_thresh = bwmorph(im_thresh, 'clean', 2);
thin = bwmorph(im_thresh, 'thin', 2);
corners = detectMinEigenFeatures(im_thresh);
ptsObj = corners.selectStrongest(total_num_pts);

if do_plot
    figure('Name', 'Corners on Thinned Image');
    imshow(thin)
    hold on
    plot(ptsObj)
    hold off
end

% for every point in pts, search for feature in a neighborhood
% around the point
imW = size(thin,2);
imH = size(thin,1);
figure('Name', "Search Area")
area_len = 8; % arbitrary
% hatch = diag(ones(1, 6));
% hatch = double(hatch | flip(hatch));
% tmatcher = vision.TemplateMatcher;
puc1 = zeros(length(ptsObj), 2);
puc1 = zeros(length(ptsObj), 2);
pvc1 = zeros(length(ptsObj), 2);
pvc2 = zeros(length(ptsObj), 2);
j = 1;

for i=1:length(ptsObj)
    pt = ptsObj.Location(i, :);
    r_idx = [max(floor(pt(2)-area_len), 1), min(ceil(pt(2)+area_len), imH)];
    c_idx = [max(floor(pt(1)-area_len), 1), min(ceil(pt(1)+ area_len), imW)];

    area = im_diff(r_idx(1):r_idx(2), c_idx(1):c_idx(2));

    sprintf(['Click the points according to uc_top, uc_bot, vc_top, vc_bot in order\n' ...
        'Press Backspace to remove a bad input\n' ...
        'If image doesn''t contain a feature, press Return\n' ...
        'When done selecting points press Return'])
    imshow(area, 'InitialMagnification', 'fit');
    [x,y] = getpts;
    if length(x) == 4
        x = x+c_idx(1)-1;
        y = y+r_idx(1)-1;
        puc1(j,:) = [x(1), y(1)];
        puc2(j,:) = [x(2), y(2)];
        pvc1(j,:) = [x(3), y(3)];
        pvc2(j,:) = [x(4), y(4)];
        j=j+1;
    end
end
puc1 = puc1(1:j-1,:);
puc2 = puc2(1:j-1,:);
pvc1 = pvc1(1:j-1,:);
pvc2 = pvc2(1:j-1,:);

figure('Name', 'u and v points')
imshow(im_diff)
hold on
scatter(puc1(:,1), puc1(:,2), 'x', 'red');
scatter(puc2(:,1), puc2(:,2), 'x', 'red');
scatter(pvc1(:,1), pvc1(:,2), 'x', 'green');
scatter(pvc1(:,1), pvc2(:,2), 'x', 'green');
hold off
end

