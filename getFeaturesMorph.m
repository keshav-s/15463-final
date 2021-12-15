function [pcs,puc1,puc2,pvc1,pvc2] = getFeaturesMorph(im_on, im_off,...
    bwPatternParams, thresh, do_plot)
num_feats = bwPatternParams.num_feats;
total_num_pts = num_feats+floor(num_feats/4);
im_diff = im_on-im_off;
im_thresh = (im_diff>thresh);
clean = bwmorph(bwmorph(im_thresh, 'clean', Inf), 'spur', Inf);
BW = bwmorph(clean, 'thin', Inf);
BW = bwmorph(BW, 'skel', Inf);
CC = bwconncomp(BW);

% remove small features
numPixels = cellfun(@numel,CC.PixelIdxList);
idxs = find(numPixels< 16); 
for i=1:length(idxs)
    idx = idxs(i);
    BW(CC.PixelIdxList{idx}) = 0;
end
% remove way-too-large features (2 features probably blurred together)
idxs = find(numPixels>30);
for i=1:length(idxs)
    idx = idxs(i);
    BW(CC.PixelIdxList{idx}) = 0;
end

s = regionprops(BW, 'Centroid', 'Extrema');
pcs = cat(1, s.Centroid);
exts = cat(2, s.Extrema);
puc1 = reshape(exts(1,:), 2, [])'; % top-left extrema
puc2 = reshape(exts(5,:), 2, [])'; % bot-right extrema
pvc1 = reshape(exts(2,:), 2, [])'; % top-right extrema
pvc2 = reshape(exts(6,:), 2, [])'; % bot-left extrema

if do_plot
    figure(2);
    imshow(im_on);
    hold on
    scatter(pcs(:,1), pcs(:,2),'x');
    hold off
end
end

