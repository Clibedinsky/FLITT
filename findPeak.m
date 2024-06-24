function [peakTimes,peakMags,tremorTimes,tremorMags] = findPeak(singleLegData,sel,PositivePeaks,NegativePeaks,tremorTime,peaksCriterion,plotLeg)
%
% %%% Find Peaks and Tremors in fly tracking data %%%
%
% INPUT:
%   singleLegData     :   Single-leg x and y positions
%   sel               :   The amount above (or below) surrounding data for a peak to be counted (default = 3)
%   PositivePeaks     :   Analyse positive peaks? 1=yes ; 0=no
%   NegativePeaks     :   Analyse negative peaks? 1=yes ; 0=no
%   tremorTime        :   tremorTime(1) = filter out peaks that are closer than this (in ms) ; tremorTime(2) = Time over which 2 peaks are consecutive to be counted as a tremor (in ms)(default = 30)
%   peaksCriterion    :   Number of consecutive peaks for a tremor to be considered a tremor (default = 0, for no criterion imposed)
%   plotLeg           :   Plot single-leg data? 1=yes ; 0=no
%
% OUTPUT:
%   peakTimes         :   time index of peaks identified
%   peakMags          :   magnitude (pixels) of peaks identified
%   tremorTimes       :   time index of peaks in tremors
%   tremorMags        :   magnitude (pixels) of peaks in tremors
%
% Example:
% (used within findTremors.m)
% [peakTimes,peakMags,tremorTimes,tremorMags] = findPeak(trajectory(:,6,1),3,1,1,30,0);
%
% Version 1.0, 30th July 2017. C.D.Libedinsky
%   - First Version

selBoth = 1; % force the 'sel' criterion to apply both forward and backwards in time

x0 = singleLegData; % rename for brevity
len0 = length(x0);  % number of time points in x0 (note that it includes NANs)

% Filter x0 to remove peaks of height 1 pixel, so long as it occurs within a larger peak (and against the grain)
% For example, in a large positive peak, remove a 1px peak if it is a negative peak

for t = 2:len0-1 % start from the 2nd because we'll compare every point with the one before
    if ((x0(t) - x0(t-1) == 1) && (x0(t) - x0(t+1) == 1)) || ((x0(t) - x0(t-1) == -1) && (x0(t) - x0(t+1) == -1)) % if positive or negative 1px peak
        
        % Find the first point after the peak when the height changes
        tmp1 = x0(t+1:end)-x0(t+1); % subtract the non-peak value after the peak, from every timepoint after the peak.
        t_Forward = min(find(tmp1));% find the first value after the peak that changed
        t_Forward = t + t_Forward;  % add to t to find the timepoint at which this happened
        
        % Do the same for values before the peak
        tmp1 = x0(1:t-1)-x0(t-1);
        t_Backward = max(find(tmp1)); % no need to sum since t_Backwards is already counted with respect to t=1
        
        if ~isempty(t_Forward) && ~isempty(t_Backward) % to avoid problems at the begining and end
            if x0(t) - x0(t-1) == 1 % if it is a positive peak
                if x0(t) <= x0(t_Forward) && x0(t) <= x0(t_Backward) % if this small 1px positive peak is found within a large negative peak
                    x0(t) = x0(t+1); % make the 1px peak flat (i.e. removed)
                end
            elseif x0(t) - x0(t-1) == -1 % if it is a negative peak
                if x0(t) >= x0(t_Forward) && x0(t) >= x0(t_Backward) % if this small 1px negative peak is found within a large positive peak
                    x0(t) = x0(t+1); % make the 1px peak flat (i.e. removed)
                end
            end
        end
    end
end

dx0 = diff(x0); % Find derivative
dx0(dx0 == 0) = -eps; % This is so we find the first of repeated values
ind = find(dx0(1:end-1).*dx0(2:end) < 0)+1; % Find where the derivative changes sign

% Start with finding all the positive and negative peaks (with sel = 0 and PositivePeaks = 1; NegativePeaks = 1)
% Notice that ind contains all the places where the derivative changes sign, and not only peaks and valleys
x = x0(ind);    % x only has the changes in derivative
len = numel(x); % total number of changes in derivative
allPeakInds = [];

if len > 2 % If there are at least 2 changes of derivative
    
    % Skip the first point if it is smaller so we always start on a positive inflection
    if x(1) >= x(2)
        ii = 2;
    else
        ii = 1;
    end
    
    % Loop through changes in derivative and save only peaks and valleys
    while ii < len-1
        ii = ii+1;
        if x(ii) < x(ii-1) && x(ii) < x(ii+1) % x(ii) is a valley
            allPeakInds = [allPeakInds;ii];
        end
        if x(ii) > x(ii-1) && x(ii) > x(ii+1) % x(ii) is a peak
            allPeakInds = [allPeakInds;ii];
        end
    end
    % allPeakMags = x(allPeakInds);
    % Note that I am not saving allPeakInds nor allPeakMags. But I'll leave it here in case someone wants to save them at some point
end


% Now use 'sel' value to filter out peaks that are too small
timePeaks = ind(allPeakInds);
x = x0(timePeaks); % x has all peaks and valleys
len = numel(x);

peakTimes = [];
peakMags = [];
if len > 2 % At least 2 peaks and/or valleys
    
    % Skip the first point if it is smaller so we always start on a positive inflection
    if x(1) >= x(2)
        ii = 2;
    else
        ii = 1;
    end
    
    % Loop through peaks and then valleys
    peakInds = [];
    while ii < len-1 % stop before the end because we are comparing x(ii) with x(ii+1)
        ii = ii+1;
        if selBoth
            if NegativePeaks && PositivePeaks % Execute only if both positive and negative peaks were requested
                if x(ii) > x(ii-1) && x(ii) > x(ii+1) && ((x(ii) - x(ii-1)) > sel && (x(ii) - x(ii+1)) > sel)
                    if abs(timePeaks(ii) - timePeaks(ii-1)) > tremorTime(1) && abs(timePeaks(ii) - timePeaks(ii+1)) > tremorTime(1)
                        peakInds = [peakInds;ii];
                    end
                end
                if x(ii) < x(ii-1) && x(ii) < x(ii+1) && ((x(ii) - x(ii-1)) < -1*sel && (x(ii) - x(ii+1)) < -1*sel)
                    if abs(timePeaks(ii) - timePeaks(ii-1)) > tremorTime(1) && abs(timePeaks(ii) - timePeaks(ii+1)) > tremorTime(1)
                        peakInds = [peakInds;ii];
                    end
                end
            end
            if PositivePeaks && ~NegativePeaks % Execute only if positive peaks were requested exclusively
                if x(ii) > x(ii-1) && x(ii) > x(ii+1) && ((x(ii) - x(ii-1)) > sel && (x(ii) - x(ii+1)) > sel)
                    if abs(timePeaks(ii) - timePeaks(ii-1)) > tremorTime(1) && abs(timePeaks(ii) - timePeaks(ii+1)) > tremorTime(1)
                        peakInds = [peakInds;ii];
                    end
                end
            end
            if NegativePeaks && ~PositivePeaks % Execute only if negative peaks were requested exclusively
                if x(ii) < x(ii-1) && x(ii) < x(ii+1) && ((x(ii) - x(ii-1)) < -1*sel && (x(ii) - x(ii+1)) < -1*sel)
                    if abs(timePeaks(ii) - timePeaks(ii-1)) > tremorTime(1) && abs(timePeaks(ii) - timePeaks(ii+1)) > tremorTime(1)
                        peakInds = [peakInds;ii];
                    end
                end
            end
        else
            if NegativePeaks && PositivePeaks % Execute only if both positive and negative peaks were requested
                if x(ii) < x(ii-1) && x(ii) < x(ii+1) && ((x(ii) - x(ii-1)) < -1*sel || (x(ii) - x(ii+1)) < -1*sel)
                    if abs(timePeaks(ii) - timePeaks(ii-1)) > tremorTime(1) && abs(timePeaks(ii) - timePeaks(ii+1)) > tremorTime(1)
                        peakInds = [peakInds;ii];
                    end
                end
                if x(ii) > x(ii-1) && x(ii) > x(ii+1) && ((x(ii) - x(ii-1)) > sel || (x(ii) - x(ii+1)) > sel)
                    if abs(timePeaks(ii) - timePeaks(ii-1)) > tremorTime(1) && abs(timePeaks(ii) - timePeaks(ii+1)) > tremorTime(1)
                        peakInds = [peakInds;ii];
                    end
                end
            end
            if PositivePeaks && ~NegativePeaks % Execute only if positive peaks were requested exclusively
                if x(ii) > x(ii-1) && x(ii) > x(ii+1) && ((x(ii) - x(ii-1)) > sel || (x(ii) - x(ii+1)) > sel)
                    if abs(timePeaks(ii) - timePeaks(ii-1)) > tremorTime(1) && abs(timePeaks(ii) - timePeaks(ii+1)) > tremorTime(1)
                        peakInds = [peakInds;ii];
                    end
                end
            end
            if NegativePeaks && ~PositivePeaks % Execute only if negative peaks were requested exclusively
                if x(ii) < x(ii-1) && x(ii) < x(ii+1) && ((x(ii) - x(ii-1)) < -1*sel || (x(ii) - x(ii+1)) < -1*sel)
                    if abs(timePeaks(ii) - timePeaks(ii-1)) > tremorTime(1) && abs(timePeaks(ii) - timePeaks(ii+1)) > tremorTime(1)
                        peakInds = [peakInds;ii];
                    end
                end
            end
        end
        
    end
    peakMags = x(peakInds);
    peakTimes = ind(allPeakInds);
    peakTimes = peakTimes(peakInds);
end

%%% Identify tremor peaks only
tremorTimes = [];
tremorMags = [];
if peaksCriterion < 3
    for i = 2:length(peakTimes)
        if peakTimes(i) - peakTimes(i-1) < tremorTime(2)
            tremorTimes = [tremorTimes peakTimes(i) peakTimes(i-1) peakTimes(i+1)];
            tremorMags = [tremorMags peakMags(i) peakMags(i-1) peakMags(i+1)];
        end
    end
    [tremorTimes,ind] = unique(tremorTimes,'first');
    tremorMags = tremorMags(ind);
elseif peaksCriterion == 3
    for i = 2:length(peakTimes)-1
        if peakTimes(i) - peakTimes(i-1) < tremorTime(2) && peakTimes(i+1) - peakTimes(i) < tremorTime(2)
            tremorTimes = [tremorTimes peakTimes(i) peakTimes(i-1) peakTimes(i+1)];
            tremorMags = [tremorMags peakMags(i) peakMags(i-1) peakMags(i+1)];
        end
    end
    [tremorTimes,ind] = unique(tremorTimes,'first');
    tremorMags = tremorMags(ind);
end

if plotLeg
    figure; plot(1:len0,x0,'.-',ind(allPeakInds),x,'ro',peakTimes,peakMags,'ko','linewidth',2);
end

end %end function

