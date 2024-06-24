function outputFreq = tremorFreq(output, WTorMT, maxTime, numDivsPlot)
%
% %%% Calculate tremor frequencies %%%
%
% INPUTS:
%   output      :   Output of findTremors()
%   WTorMT      :   'WT' = wild type ; 'MT' = mutant
%   maxTime     :   Maximum difference in time between peaks to be considered part of a tremor (in findTremors() it corresponds to tremorTime(max))
%   numDivsPlot :   Number of divisions in the histogram
%
% OUTPUT:
%   outputFreq  :   Frequency of tremors
%
% Example:
% outputFreq = tremorFreq(output, 'MT', 50, 20);
%
% Version 1.0, 30th July 2017. C.D.Libedinsky
%   - First Version

% Determine number of flies in the strain to analyse
if strcmp(WTorMT,'WT')
    
    numFlies = size(output.WT,1)-1;
    outputFreq = [];
    for fly = 1:numFlies
        if output.WT{fly+1,8} % if the fly has tremors
            for leg = 1:6
                if output.WT{fly+1,6}{leg,1}
                    % in X
                    tremorTimestamps = output.WT{fly+1,6}{leg,1};
                    diffTrTiSt = diff(tremorTimestamps);
                    diffTrTiSt = diffTrTiSt(find(diffTrTiSt<maxTime));
                    outputFreq = [outputFreq diffTrTiSt];
                end
                if output.WT{fly+1,7}{leg,1}
                    % in Y
                    tremorTimestamps = output.WT{fly+1,7}{leg,1};
                    diffTrTiSt = diff(tremorTimestamps);
                    diffTrTiSt = diffTrTiSt(find(diffTrTiSt<maxTime));
                    outputFreq = [outputFreq diffTrTiSt];
                end
            end
        end
    end
    figure;hist(outputFreq,numDivsPlot)
    title('WT')
    
elseif strcmp(WTorMT,'MT')
    
    numFlies = size(output.MT,1)-1;
    outputFreq = [];
    for fly = 1:numFlies
        if output.MT{fly+1,8} % if the fly has tremors
            for leg = 1:6
                if output.MT{fly+1,6}{leg,1}
                    % in X
                    tremorTimestamps = output.MT{fly+1,6}{leg,1};
                    diffTrTiSt = diff(tremorTimestamps);
                    diffTrTiSt = diffTrTiSt(find(diffTrTiSt<maxTime));
                    outputFreq = [outputFreq diffTrTiSt];
                end
                if output.MT{fly+1,7}{leg,1}
                    % in Y
                    tremorTimestamps = output.MT{fly+1,7}{leg,1};
                    diffTrTiSt = diff(tremorTimestamps);
                    diffTrTiSt = diffTrTiSt(find(diffTrTiSt<maxTime));
                    outputFreq = [outputFreq diffTrTiSt];
                end
            end
        end
    end
    figure;hist(outputFreq,numDivsPlot)
    title('MT')
    
else
    disp('Please specify ''WT'' for wild-type or ''MT'' for mutant (case-sensitive)')
end

