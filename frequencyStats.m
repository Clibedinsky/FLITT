function frequencyStats(var, numDivs, numReps, pVal, maxTime)
% %%% Run permutation statistical analysis to determine tremor frequency %%%
%
% INPUTS:
%   outputFreqBothMT    :   output of tremorFreq() function for both positive and negative peaks (created under findFrequency() function)
%   numDivs             :   Number of subdivisions of the frequency range for the histogram
%   numReps             :   Number of permutations to find the confidence intervals
%   pVal                :   1-tailed p value
%   maxTime             :   maximum time difference between peaks to be considered a tremor (in ms)
%
% OUTPUT: 
% Output is a histogram of number of tremors at different frequencies vs
% frequency. Values above the dotted line (pVal confidence interval)
% denotes the dominant frequency that is significantly different from
% chance
%
% Example:
% frequencyStats(outputFreqBothMT, 25, 1000, 0.001, 100)
%
% Version 1.0, 30th July 2017. C.D.Libedinsky
%   - First Version


[peakNum peakTime] = hist(var,numDivs);
[realPeakNum realPeakTimeind] = max(peakNum);
realPeakTime = peakTime(realPeakTimeind);

numTremors = length(var);

peakDistribution = zeros(numReps,1);
for rep = 1:numReps
    newVar = round(rand(1,numTremors) * maxTime);
    
    [peakNum peakTime] = hist(newVar,numDivs);
    randPeakNum = max(peakNum);
    peakDistribution(rep,1) = randPeakNum;
end
peakDistribution = sort(peakDistribution);
pIndex = numReps - round(numReps*pVal);

signNumber = peakDistribution(min(find(peakDistribution>peakDistribution(pIndex))));

figure; hist(var,numDivs); hold on; 
xl = xlim;

plot([0 xl(2)],[signNumber signNumber], 'r--'); hold off

if realPeakNum <= signNumber
    ylim([0 signNumber+signNumber/10])
else
    ylim([0 realPeakNum+realPeakNum/10])
end

title('Mutant')
