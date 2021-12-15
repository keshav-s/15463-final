function [num_feats, dl, im] = genStructLightBlocks(bwPatternParams)
rng(1);

prjW = bwPatternParams.prjW;
prjH = bwPatternParams.prjH; 
r = bwPatternParams.radius;
n = bwPatternParams.feats_per_line;
dh = bwPatternParams.feat_dist; 
dl = bwPatternParams.line_dist;
brightness = bwPatternParams.brightness;

hlen = 2*r+1; % length of each hatch block
lineSeg = ones(1, hlen);
halfHatch = diag(lineSeg);
hatch = halfHatch | flip(halfHatch);
skip = zeros(hlen, dh);

h_skip_combos = {};
linelen = 0;
for ii = 1:(n-1)
    skips = repmat(skip, 1, ii);
    h_skip = [hatch skips];
    h_skip_combos{ii} = h_skip;
    linelen = linelen + size(h_skip, 2);
end

linelen = linelen+hlen;
% ncols = floor(hlen/dl)+1;
ncols = floor((prjW + dh)/(linelen + dh));
% dl = ceil(hlen/(ncols-1));
% rowExtra = mod(hlen, restartRow);
% nrows = floor(prjH/(hlen+rowExtra));
nrows = floor((prjH-(ncols-1)*dl)/(hlen+dl));
% while (ncols-1)*dl + nrows*(hlen+rowExtra) > prjH
%     nrows = nrows - 1;
% end
rowskip = zeros(dl, linelen);
num_feats = 0;
im = [];
for j = 1:ncols
    col = zeros((j-1)*dl, linelen);
    for i = 1:nrows
        eline = [];
        randline_idxs = randsample(n-1, n-1);
        for ii = 1:n-1
            h_skip = h_skip_combos{randline_idxs(ii)};
            eline = [eline h_skip];
            num_feats = num_feats + 1;
        end
        eline = [eline hatch];
        num_feats = num_feats + 1;

        if i == 1
            col = [col; eline];
        else
            col = [col; rowskip; eline];
        end
    end
    col = [col; zeros(prjH-size(col, 1), linelen)];

    if j == 1
        im = col;
    else
        im = [im zeros(prjH, dh) col];
    end
end
im = [im zeros(prjH, prjW-size(im,2))];
im = repmat(im, 1, 1, 3)*brightness;
end