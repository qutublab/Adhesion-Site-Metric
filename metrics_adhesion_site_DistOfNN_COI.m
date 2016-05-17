%%
clear;clc;

imgkey = {'JCC1003','JCC1008','JCC1009','JCC1010','JCC3113','JCC3118','JCC3119','JCC4003'};
%imgkey = {'R001', 'R002', 'R003', 'R123'};

COIinfo = dir('*-COI*.tif');
COIfile = {COIinfo.name};

% lower bound for the size of adhesion site
thCOI  = 1;
thMask = 1;

%%

% initialization
D = cell(length(COIfile),length(imgkey));
DZeroPadded = cell(length(COIfile),length(imgkey));
DSize = zeros(length(COIfile),length(imgkey));

steps = length(COIfile)*length(imgkey);
step = 0;

% waitbar
h = waitbar(0,'Please wait...');

% compute the distance metrics
for idx_COI = 1:length(COIfile)
    
    COI = bwareaopen(im2single(imread(COIfile{idx_COI})),thCOI);
    propsCOI = regionprops(COI,'Centroid');
    centroidCOI = vertcat(propsCOI.Centroid);
    
    for idx_imgkey = 1:length(imgkey)
        
        minfo = dir(strcat(imgkey{idx_imgkey}, '*.tif'));  % '-SEQ*.tif'));
%         % 12-18-12 Byron
%         % Include the mask opf the COI that generated the pattern cells
%         coiinfo = dir(strcat(imgkey{idx_imgkey},'-COI-VIN-MASK.tif'));
%         maskfile = cat(2, {minfo.name}, {coiinfo.name});
        maskfile = {minfo.name};
        numOfMask = length(maskfile);
        d = cell(numOfMask,1);
        
        for idx_mask = 1:numOfMask
            mask = bwareaopen(im2single(imread(maskfile{idx_mask})),thMask);
            propsMask = regionprops(mask,'Centroid');
            centroidMask = vertcat(propsMask.Centroid);
            
            % use COI as the reference, for every centroid point in the mask, find the
            % nearest neighbor in the COI
            [nMC,dMC]=knnsearch(centroidCOI,centroidMask,'k',1,'distance','euclidean');
            
            % use mask as the reference, for every centroid in the COI, find the
            % nearest neighbor in the mask
            [nCM,dCM]=knnsearch(centroidMask,centroidCOI,'k',1,'distance','euclidean');
            
            d{idx_mask} = sum(dMC) + sum(dCM);
        end
        D{idx_COI,idx_imgkey} = [d{:}]';
        DSize(idx_COI,idx_imgkey) = numOfMask;
        step = step+1;
        waitbar(step/steps)
    end
end

%%

DSizeMax = max(max(DSize));

for idx_COI = 1:length(COIfile)
    header_D = cell(length(imgkey)+1,1);
    header_D{1} = 'CellNumber';
    filename = COIfile{idx_COI};
    COIname = filename(1:7);
    for idx_imgkey = 1:length(imgkey)
        % zero-padding the computed distance metrics
        DZeroPadded{idx_COI,idx_imgkey} = padarray(D{idx_COI,idx_imgkey},[DSizeMax-DSize(idx_COI,idx_imgkey)],'post');
        DZeroPaddedMaxCOI = max(max([DZeroPadded{idx_COI,:}]));
%         size(imgkey)
%         idx_COI
%         header_D{idx_imgkey+1} =  strcat('COI-',imgkey{idx_COI},'-MASKS-',imgkey{idx_imgkey});
        header_D{idx_imgkey+1} =  strcat('COI-',COIname,'-MASKS-',imgkey{idx_imgkey});
    end
    % the zero padded distance metrics are normalized by the largest value in the
    % dataset related to the same COI 
    outputMatrix = [(1:DSizeMax)', ([DZeroPadded{idx_COI,:}]./DZeroPaddedMaxCOI)];
%    csvfilename = strcat('metrics_adhesion_site_DistOfNN_','COI_',imgkey{idx_COI},'.csv');
    csvfilename = strcat('metrics_adhesion_site_DistOfNN_','COI_',COIname,'.csv');
    ext_csvwrite(csvfilename, outputMatrix, header_D)    
end

% close the waitbar
close(h)