%% Load Parameters
close all;
do_plot = 1;
undistort = 0;

load('bwPatternParams.mat');
im_pattern = rgb2gray(im2double(imread('./data/pattern.png')));
im_color_off = im2double(imread('./data/bw_ims/prjOff4.jpg'));
im_color_on = im2double(imread('./data/bw_ims/prjOn4.jpg'));
im_off = rgb2gray(im_color_off);
im_on = rgb2gray(im_color_on);
calib = cv.FileStorage(fullfile('./data/results', 'calibration.yml'));

%% Detect pattern features
BW = bwmorph(im_pattern, 'skel');
s = regionprops(BW, 'Centroid', 'Extrema');
P.pps = cat(1, s.Centroid);
exts = cat(2, s.Extrema);
P.pup1 = reshape(exts(1,:), 2, [])'; % top-left extrema
P.pup2 = reshape(exts(5,:), 2, [])'; % bot-right extrema
P.pvp1 = reshape(exts(2,:), 2, [])'; % top-right extrema
P.pvp2 = reshape(exts(6,:), 2, [])'; % bot-left extrema
if do_plot
    figure(1);
    imshow(im_pattern);
    hold on
    scatter(P.pps(:,1), P.pps(:,2), 'x');
    hold off
end

%% Detect image features
% to better find features, I took an image of a planar scene with
% the pattern displayed and an image without the pattern.
feature_thresh = 0.08; %arbitrary
% [puc1,puc2,pvc1,pvc2] = getFeaturesManual(im_on, im_off, bwPatternParams, ...
%     feature_thresh, do_plot);
[I.pcs,I.puc1,I.puc2,I.pvc1,I.pvc2] = getFeaturesMorph(im_on, im_off,...
    bwPatternParams, feature_thresh, do_plot);

%% Undistort images and points
camK = calib.camK;
camKc = calib.camKc;
prjK = calib.prjK;
prjKc = calib.prjKc;
if undistort
    I.ud_pcs = cvUndistortPoints(I.pcs, camK, camKc);
    I.ud_puc1 = cvUndistortPoints(I.puc1, camK, camKc);
    I.ud_puc2 = cvUndistortPoints(I.puc2, camK, camKc);
    I.ud_pvc1 = cvUndistortPoints(I.pvc1, camK, camKc);
    I.ud_pvc2 = cvUndistortPoints(I.pvc2, camK, camKc);
    ud_im_on = cv.undistort(im_color_on, camK, camKc);
    
    P.ud_pps = cvUndistortPoints(P.pps, prjK, prjKc);
    P.ud_pup1 = cvUndistortPoints(P.pup1, prjK, prjKc);
    P.ud_pup2 = cvUndistortPoints(P.pup2, prjK, prjKc);
    P.ud_pvp1 = cvUndistortPoints(P.pvp1, prjK, prjKc);
    P.ud_pvp2 = cvUndistortPoints(P.pvp2, prjK, prjKc);
    ud_im_pattern = cv.undistort(im_pattern, prjK, prjKc);
end
%% Get rectification matrices, rectify images and points
R1 = eye(3);
t1 = zeros(3,1);
R2 = calib.R;
t2 = calib.T;
[Mcam, Mprj, Kp, R_rect, tcam_p, tprj_p] = rectifyPair(camK, prjK, R1, R2, t1, t2);
b = tprj_p(1); % baseline

if undistort
    I.f_pcs = projTrans(Mcam, I.ud_pcs);
    I.f_puc1 = projTrans(Mcam, I.ud_puc1);
    I.f_puc2 = projTrans(Mcam, I.ud_puc2);
    I.f_pvc1 = projTrans(Mcam, I.ud_pvc1);
    I.f_pvc2 = projTrans(Mcam, I.ud_pvc2);
    
    P.f_pps = projTrans(Mprj, P.ud_pps);
    P.f_pup1 = projTrans(Mprj, P.ud_pup1);
    P.f_pup2 = projTrans(Mprj, P.ud_pup2);
    P.f_pvp1 = projTrans(Mprj, P.ud_pvp1);
    P.f_pvp2 = projTrans(Mprj, P.ud_pvp2);
else
    I.f_pcs = projTrans(Mcam, I.pcs);
    I.f_puc1 = projTrans(Mcam, I.puc1);
    I.f_puc2 = projTrans(Mcam, I.puc2);
    I.f_pvc1 = projTrans(Mcam, I.pvc1);
    I.f_pvc2 = projTrans(Mcam, I.pvc2);
    
    P.f_pps = projTrans(Mprj, P.pps);
    P.f_pup1 = projTrans(Mprj, P.pup1);
    P.f_pup2 = projTrans(Mprj, P.pup2);
    P.f_pvp1 = projTrans(Mprj, P.pvp1);
    P.f_pvp2 = projTrans(Mprj, P.pvp2);
end

if do_plot
    figure;
    if undistort
        montage({ud_im_on, rectifyIm(ud_im_on, Mcam),...
            ud_im_pattern, rectifyIm(ud_im_pattern, Mprj)});
    else
        montage({im_on, rectifyIm(im_on, Mcam),...
            im_pattern, rectifyIm(im_pattern, Mprj)});
    end
end

%% Plane parameter voting
Pspace = zeros(length(I.f_pcs),length(P.f_pps), 3);
for if_idx = 1:length(I.f_pcs)
    for pf_idx = 1:length(P.f_pps) 
        puc1 = I.f_puc1(if_idx, :);
        puc2 = I.f_puc2(if_idx, :);
        pvc1 = I.f_pvc1(if_idx, :);
        pvc2 = I.f_pvc2(if_idx, :);
        uc = [puc1-puc2, 0];
        vc = [pvc1-pvc2, 0];
        pc = [I.f_pcs(if_idx, :), 1];

        pup1 = P.f_pup1(pf_idx, :);
        pup2 = P.f_pup2(pf_idx, :);
        pvp1 = P.f_pvp1(pf_idx, :);
        pvp2 = P.f_pvp2(pf_idx, :);
        up = [pup1-pup2, 0];
        vp = [pvp1-pvp2, 0];
        pp = [P.f_pps(pf_idx, :), 1];

        n_uc = cross(uc, pc);
        n_up = cross(up, pp);
        line_u = cross(n_uc, n_up);

        n_vc = cross(vc, pc);
        n_vp = cross(vp, pp);
        line_v = cross(n_vc, n_vp);

        n = cross(line_u, line_v);
        n = n/norm(n);

        theta = acos(-1*n(3));
        phi = acos(n(1)/sin(theta));
        D = (b*dot(n,pp))/(pp(1) - pc(1)) - dot(n, -Mprj*tprj_p);
        D = D/1000;
        Pspace(if_idx, pf_idx, :) = real([D, theta, phi]);
    end
end

a = 1;
psp = reshape(Pspace, [], 3);
[N, ~, ~, binX, binY] = histcounts2(psp(:,1), psp(:,2));
[unqBins,~,binID] = unique([binX,binY],'rows');
Asum = splitapply(@sum,psp(:,3),binID);
B = zeros(size(N)); 
ind = sub2ind(size(B),unqBins(:,1),unqBins(:,2)); 
B(ind) = Asum;
