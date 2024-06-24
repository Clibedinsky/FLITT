function [outputPos, outputNeg, outputFreqPosMT, outputFreqNegMT, outputFreqBothMT, outputFreqPosWT, outputFreqNegWT, outputFreqBothWT] = findFrequency(dataDir, wt, mt, legsORbody)
% %%% Main function to find tremor frequency in legs or body tremors %%%
%
% INPUT:
%   dataDir          :   Path where data is located
%   wt               :   First 2-4 letters of the wild type folder that contains the data
%   mt               :   First 2-4 letters of the mutant folder that contains the data
%   legsORbody       :   "legs" to analyse legs or "body" to analyse body
%
% OUTPUT:
%   outputPos        :   For positive peaks; 2-field structure (WT and MT). Each one containing: {'folder','trajectory','PeaksX','PeaksY','SumPeaks','TremorsX','TremorsY','SumTremors'}
%   outputNeg        :   For negative peaks; 2-field structure (WT and MT). Each one containing: {'folder','trajectory','PeaksX','PeaksY','SumPeaks','TremorsX','TremorsY','SumTremors'}
%   outputFreqPosMT  :   For mutants; For positive peaks; Frequency of tremors
%   outputFreqNegMT  :   For mutants; For negative peaks; Frequency of tremors
%   outputFreqBothMT :   For mutants; For positive and negative peaks; Frequency of tremors
%   outputFreqPosWT  :   For wild type; For positive peaks; Frequency of tremors
%   outputFreqNegWT  :   For wild type; For negative peaks; Frequency of tremors
%   outputFreqBothWT :   For wild type; For positive and negative peaks; Frequency of tremors
%
% [outputPos, outputNeg] = findFrequency('/Users/camilo/Analysis Scripts', 'Up', 'HK', 'body')
%
% Version 1.0, 30th July 2017. C.D.Libedinsky
%   - First Version

if legsORbody == 'legs'
    outputPos = findTremors(dataDir, wt, mt, 3, [3 100], 1);
    outputNeg = findTremors(dataDir, wt, mt, 3, [3 100], 0);
    
    outputFreqPosMT = tremorFreq(outputPos, 'MT', 100, 10);
    outputFreqNegMT = tremorFreq(outputNeg, 'MT', 100, 10);
    outputFreqBothMT = [outputFreqPosMT outputFreqNegMT];
    figure;hist(outputFreqBothMT,10); title('Both MT')
    
    outputFreqPosWT = tremorFreq(outputPos, 'WT', 100, 10);
    outputFreqNegWT = tremorFreq(outputNeg, 'WT', 100, 10);
    outputFreqBothWT = [outputFreqPosWT outputFreqNegWT];
    figure;hist(outputFreqBothWT,10); title('Both WT')
        
    frequencyStats(outputFreqBothMT, 10, 100000, 0.01, 100)
end

if legsORbody == 'body'
    outputPos = findTremorsBody(dataDir, wt, mt, 2, [3 500], 1);
    outputNeg = findTremorsBody(dataDir, wt, mt, 2, [3 500], 0);
    
    outputFreqPosMT = tremorFreqBody(outputPos, 'MT', 100, 10);
    outputFreqNegMT = tremorFreqBody(outputNeg, 'MT', 100, 10);
    outputFreqBothMT = [outputFreqPosMT outputFreqNegMT];
    figure;hist(outputFreqBothMT,10); title('Both MT')
    
    outputFreqPosWT = tremorFreqBody(outputPos, 'WT', 100, 10);
    outputFreqNegWT = tremorFreqBody(outputNeg, 'WT', 100, 10);
    outputFreqBothWT = [outputFreqPosWT outputFreqNegWT];
    figure;hist(outputFreqBothWT,10); title('Both WT')
        
    frequencyStats(outputFreqBothMT, 10, 100000, 0.05, 100)
end