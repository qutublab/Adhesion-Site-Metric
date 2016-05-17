%%
clear;clc;
%imgkey = {'JCC1008'};
%imgkey = {'JCC1003','JCC1008','JCC1009','JCC1010','JCC3113','JCC3118','JCC3119','JCC4003'};
imgkey = {'R001','R002','R003','R123'};

% lower bound for the size of adhesion site
thCOI  = 1;
thMask = 1;

%%
for idx_imgkey = 1:length(imgkey)
    COIinfo = dir(strcat(imgkey{idx_imgkey},'-COI*.tif'));
    COIfile = {COIinfo.name};
    
    minfo = dir(strcat(imgkey{idx_imgkey}, '*.tif'));   %'-SEQ*.tif'));
    maskfile = {minfo.name};
    numOfMask = length(maskfile);
    d = cell(numOfMask,1);
    AvgArea = zeros(numOfMask+1,1);
    TotArea = zeros(numOfMask+1,1);
    MajorAxisLength = zeros(numOfMask+1,1);
    MinorAxisLength= zeros(numOfMask+1,1);
    NumOfAdhesionSites = zeros(numOfMask+1,1);
    
    tic
    %[row col] = size(imread(COIfile{1}));
    %COI = bwareaopen(im2single(imread(COIfile{1})),thCOI);
    %propsCOI = regionprops(COI,'Centroid','Area',...
    %    'MajorAxisLength','MinorAxisLength','Solidity','Eccentricity');
    %AvgArea(end) = mean([propsCOI.Area]);
    %TotArea(end) = sum([propsCOI.Area]);
    %MajorAxisLength(end) = mean([propsCOI.MajorAxisLength]);
    %MinorAxisLength(end) = mean([propsCOI.MinorAxisLength]);
    %NumOfAdhesionSites(end) = numel([propsCOI.Area]);
    
    %centroidCOI = vertcat(propsCOI.Centroid);
    
    for idx_mask = 1:numOfMask
        mask = bwareaopen(im2single(imread(maskfile{idx_mask})),thMask);
        propsMask = regionprops(mask,'Centroid','Area',...
            'MajorAxisLength','MinorAxisLength','Solidity','Eccentricity');
        centroidMask = vertcat(propsMask.Centroid);
        
        % use COI as the reference, for every centroid point in the mask, find the
        % nearest neighbor in the COI
        %[nMC,dMC]=knnsearch(centroidCOI,centroidMask,'k',1,'distance','euclidean');
        
        % use mask as the reference, for every centroid in the COI, find the
        % nearest neighbor in the mask
        %[nCM,dCM]=knnsearch(centroidMask,centroidCOI,'k',1,'distance','euclidean');
        
        %d{idx_mask} = sum(dMC) + sum(dCM);
        
        AvgArea(idx_mask) = mean([propsMask.Area]);
        TotArea(idx_mask) = sum([propsMask.Area]);
        MajorAxisLength(idx_mask) = mean([propsMask.MajorAxisLength]);
        MinorAxisLength(idx_mask)= mean([propsMask.MinorAxisLength]);
	  Solidity(idx_mask)= mean([propsMask.Solidity]);
        Eccentricity(idx_mask)= mean([propsMask.Eccentricity]);
        NumOfAdhesionSites(idx_mask) = numel([propsMask.Area]);
        
    end
    toc
    
    %
    %header_d = {strcat('CellNumber-',imgkey{idx_imgkey}),'DistOfNN'};
    %csvfilename = strcat('metrics_adhesion_site_DistOfNN-',imgkey{idx_imgkey},'.csv');
    %ext_csvwrite(csvfilename,[(1:numOfMask)', ([d{:}]'./max([d{:}]))], header_d)
    
    header_metrics = {strcat('CellNumber-',imgkey{idx_imgkey}), 'AvgArea', 'TotArea', 'MajorAxisLength', 'MinorAxisLength',...
        'NumOfAdhesionSites'};
    csvfilename = strcat('metrics_adhesion_site-',imgkey{idx_imgkey},'.csv');
    ext_csvwrite(csvfilename,[(1:(numOfMask+1))', AvgArea, TotArea,MajorAxisLength,MinorAxisLength,...
        NumOfAdhesionSites], header_metrics)
    
    % hist([d{:}],numOfMask);
end
