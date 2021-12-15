unfiltered_pts = ptsObj.Location(1:total_num_pts, :);
final_pts = zeros(length(unfiltered_pts),2);
i = 1;
while ~isempty(unfiltered_pts)
    pt = unfiltered_pts(1,:);
    dist = abs(unfiltered_pts - pt);
    rpts = unfiltered_pts(dist(:,1) < 9,:);
    cpts = unfiltered_pts(dist(:,2) < 9,:);
    neighbors = intersect(rpts, cpts, 'rows');
    fpt = mean(neighbors, 1);
    final_pts(i,:) = fpt;
    i = i+1;
    unfiltered_pts = setdiff(unfiltered_pts, neighbors, 'rows');
end
final_pts = final_pts(1:i-1, :); 