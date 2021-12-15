function [p2d] = projTrans(H,p)
%PROJTRANS Translated from helper function in 
% 16-385 assgn3
n = length(p);
p3d = [p ones(n,1)]';
h3d = H*p3d;
h3d = h3d';

p2d = zeros(size(h3d, 1), 2);
p2d = h3d(:,1:2)./h3d(:,3);
end