function [dice] = evaluateDice(auto,man)
%This function evaluates the Sorenson Dice coefficient between and
%automatic label set and a manual labelset

%Created by Emily Lindemer 08/25/2016

    auto_mat=fast_vol2mat(auto);
    man_mat=fast_vol2mat(man);

    man_mat(find(man_mat>0))=1;
    auto_mat(find(auto_mat>0))=1;

    label_intersect=length(intersect(auto_mat,man_mat));

    dice=(2*label_intersect)/(sum(man_mat)+sum(auto_mat));


end

