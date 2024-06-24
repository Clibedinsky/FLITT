function output = findTremors(dataDir, wt, mt, tremorSize, tremorTime, pos)
%
% %%% Find tremors in fly tracking data %%%
%
% INPUTS:
%   dataDir   :   Home folder where fly files are located
%   wt        :   Two first characters of the file names of wild types
%   mt        :   Two first characters of the file names of mutant to analyse
%   tremorSize:   The amount above (or below) surrounding data for a peak to be counted (default = 3)
%   tremorTime:   [min max]: Time over which 2 peaks are consecutive to be counted as a tremor (in ms)(default = [3 100])
%   pos       :   pos = 1 use positive peaks ; pos = 0 use negative peaks
%
% OUTPUT:
%   output    :   2-field structure (WT and MT). Each one containing: {'folder','trajectory','PeaksX','PeaksY','SumPeaks','TremorsX','TremorsY','SumTremors'}
%
% Example:
% output = findTremors('/Users/camilo/Documents/MATLAB/Sherry Tremor/Hk2 yw Own Classifier', 'yw', 'HK', 3, [3 50], 1);
%
% Version 1.0, 30th July 2017. C.D.Libedinsky
%   - First Version

cd(dataDir);

legsToAnalyse = 1:6;
peaksCriterion = 3;
dataSmooth = 3; % in ms

% Find folders with wild types
dirFolders = dir;
wtFolders = [];
for folderNum = 3:length(dirFolders)
    thisFolder = dirFolders(folderNum).name;
    if thisFolder(1:length(wt)) == wt
        wtFolders = [wtFolders folderNum];
    end
end

% Find folders with mutant
dirFolders = dir;
mtFolders = [];
for folderNum = 3:length(dirFolders)
    thisFolder = dirFolders(folderNum).name;
    if thisFolder(1:length(mt)) == mt
        mtFolders = [mtFolders folderNum];
    end
end

% assign positive and negative peak analysis variables
if pos == 1
    neg = 0;
elseif pos == 0
    neg = 1;
end


%%% For MTs %%%
output.MT = cell(length(mtFolders) + 1,8);
output.MT{1,1} = 'folder'; output.MT{1,2} = 'trajectory'; ...
    output.MT{1,3} = 'PeaksX'; output.MT{1,4} = 'PeaksY'; output.MT{1,5} = 'SumPeaks';...
    output.MT{1,6} = 'TremorsX'; output.MT{1,7} = 'TremorsY'; output.MT{1,8} = 'SumTremors';

for mtFolder = 1:length(mtFolders) % for each mutant fly
    thisFolder = dirFolders(mtFolders(mtFolder)).name;
    currentFolder = [dataDir '/' thisFolder];
    cd(currentFolder)
    disp(thisFolder)
    output.MT{mtFolder+1,1} = thisFolder;
    
    % Load File
    load('trajectory.mat') % load the raw data
    trajectory(find(trajectory==0)) = nan; % replace missing frames (which are labeled as 0) with NANs
    
    % Smooth trajectory
    if dataSmooth
        for a = 1:2
            for l = 1:6
                trajectory(:,l,a) = nanfastsmooth(trajectory(:,l,a),dataSmooth,1,0);
            end
        end
    end
    output.MT{mtFolder+1,2} = trajectory;
    
    % Find tremors
    sumPeaks = 0;
    sumTremors = 0;
    for leg = 1:length(legsToAnalyse)
        thisLeg = legsToAnalyse(leg);
        [finalPeaksX,peakMagsX,tremorPeaksX,tremorPeakMagsX] = findPeak(trajectory(:,thisLeg,1),tremorSize,pos,neg,tremorTime,peaksCriterion,0); % in x
        allLegsX{leg,1} = finalPeaksX;
        allLegsX{leg,2} = peakMagsX;
        tremorsX{leg,1} = tremorPeaksX;
        tremorsX{leg,2} = tremorPeakMagsX;
        
        [finalPeaksY,peakMagsY,tremorPeaksY,tremorPeakMagsY] = findPeak(trajectory(:,thisLeg,2),tremorSize,pos,neg,tremorTime,peaksCriterion,0); % in y
        allLegsY{leg,1} = finalPeaksY;
        allLegsY{leg,2} = peakMagsY;
        tremorsY{leg,1} = tremorPeaksY;
        tremorsY{leg,2} = tremorPeakMagsY;
        
        % To calculate the sum, don't double count the peaks that co-occur in the x and y axis
        % For peaks
        removePeak = 0;
        if ~isempty(finalPeaksX) && ~isempty(finalPeaksY)
            for i=1:size(finalPeaksX,1)
                if find(finalPeaksY(:,1)-finalPeaksX(i,1) == 0) % if peaks in x and y are simultaneous, then consider them the same peak
                    removePeak = removePeak + 1;
                end
            end
        end
        % For tremors
        removeTremor = 0;
        if ~isempty(tremorPeaksX) && ~isempty(tremorPeaksY)
            for i=1:size(tremorPeaksX,1)
                if find(tremorPeaksY(:,1)-tremorPeaksX(i,1) == 0) % if peaks in x and y are simultaneous, then consider them the same peak
                    removeTremor = removeTremor + 1;
                end
            end
        end
        
        sumPeaks = sumPeaks + length(finalPeaksX) + length(finalPeaksY) - removePeak;
        sumTremors = sumTremors + length(tremorPeaksX) + length(tremorPeaksY) - removeTremor;
        
    end
    output.MT{mtFolder+1,3} = allLegsX;
    output.MT{mtFolder+1,4} = allLegsY;
    output.MT{mtFolder+1,5} = round(sumPeaks/length(trajectory)*1000);
    
    output.MT{mtFolder+1,6} = tremorsX;
    output.MT{mtFolder+1,7} = tremorsY;
    output.MT{mtFolder+1,8} = round(sumTremors/length(trajectory)*1000);
end


%%% For WTs
output.WT = cell(length(wtFolders) + 1,8);
output.WT{1,1} = 'folder'; output.WT{1,2} = 'trajectory'; ...
    output.WT{1,3} = 'PeaksX'; output.WT{1,4} = 'PeaksY'; output.WT{1,5} = 'SumPeaks';...
    output.WT{1,6} = 'TremorsX'; output.WT{1,7} = 'TremorsY'; output.WT{1,8} = 'SumTremors';

for wtFolder = 1:length(wtFolders)
    thisFolder = dirFolders(wtFolders(wtFolder)).name;
    currentFolder = [dataDir '/' thisFolder];
    cd(currentFolder)
    disp(thisFolder)
    output.WT{wtFolder+1,1} = thisFolder;
    
    % Load File
    load('trajectory.mat')
    trajectory(find(trajectory==0)) = nan;    
    
    if dataSmooth
        for a = 1:2
            for l = 1:6
                trajectory(:,l,a) = nanfastsmooth(trajectory(:,l,a),dataSmooth,1,0);
            end
        end
    end
    
    output.WT{wtFolder+1,2} = trajectory;
    
    % Find tremors
    sumPeaks = 0;
    sumTremors = 0;
    for leg = 1:length(legsToAnalyse)
        thisLeg = legsToAnalyse(leg);
        [finalPeaksX,peakMagsX,tremorPeaksX,tremorPeakMagsX] = findPeak(trajectory(:,thisLeg,1),tremorSize,pos,neg,tremorTime,peaksCriterion,0); % in x
        allLegsX{leg,1} = finalPeaksX;
        allLegsX{leg,2} = peakMagsX;
        tremorsX{leg,1} = tremorPeaksX;
        tremorsX{leg,2} = tremorPeakMagsX;
        
        [finalPeaksY,peakMagsY,tremorPeaksY,tremorPeakMagsY] = findPeak(trajectory(:,thisLeg,2),tremorSize,pos,neg,tremorTime,peaksCriterion,0); % in y
        allLegsY{leg,1} = finalPeaksY;
        allLegsY{leg,2} = peakMagsY;
        tremorsY{leg,1} = tremorPeaksY;
        tremorsY{leg,2} = tremorPeakMagsY;
        
        % To calculate the sum, don't double count the peaks that co-occur in the x and y axis
        % For peaks
        removePeak = 0;
        if ~isempty(finalPeaksX) && ~isempty(finalPeaksY)
            for i=1:size(finalPeaksX,1)
                if find(finalPeaksY(:,1)-finalPeaksX(i,1) == 0) % if peaks in x and y are simultaneous, then consider them the same peak
                    removePeak = removePeak + 1;
                end
            end
        end
        % For tremors
        removeTremor = 0;
        if ~isempty(tremorPeaksX) && ~isempty(tremorPeaksY)
            for i=1:size(tremorPeaksX,1)
                if find(tremorPeaksY(:,1)-tremorPeaksX(i,1) == 0) % if peaks in x and y are simultaneous, then consider them the same peak
                    removeTremor = removeTremor + 1;
                end
            end
        end
        
        sumPeaks = sumPeaks + length(finalPeaksX) + length(finalPeaksY) - removePeak;
        sumTremors = sumTremors + length(tremorPeaksX) + length(tremorPeaksY) - removeTremor;
        
        
    end
    output.WT{wtFolder+1,3} = allLegsX;
    output.WT{wtFolder+1,4} = allLegsY;
    output.WT{wtFolder+1,5} = sumPeaks;%round(sumPeaks/length(trajectory)*1000);
    
    output.WT{wtFolder+1,6} = tremorsX;
    output.WT{wtFolder+1,7} = tremorsY;
    output.WT{wtFolder+1,8} = sumTremors;%round(sumTremors/length(trajectory)*1000);
end

