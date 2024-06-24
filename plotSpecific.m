function plotSpecific(output,flyPlot,legsPlot, axis, markers)
%
% %%% Plot specific fly, leg, x or y %%%
%
% INPUTS:
%   output    :   Output of findTremors.m
%   flyPlot   :   File name of fly to plot
%   legsPlot  :   Which leg or legs to plot (1:6)
%   axis      :   'x', 'y' or 'both'
%   markers   :   0==no ; 1==yes
%
% Example:
% plotSpecific(output,'SH5 35d male-4-3 none bias_H2A',1:6,'both', 1)
%

% Created by Camilo Libedinsky 28 May 2017

for legs = 1:length(legsPlot)
    legPlot = legsPlot(legs);
    figure
    
    if strcmp(axis,'x')
        axisAnalysis = 1;
        legendValue = {'X','Peaks X', 'Tremors X'};
    elseif  strcmp(axis,'y')
        axisAnalysis = 2;
        legendValue = {'Y','Peaks Y', 'Tremors Y'};
    elseif  strcmp(axis,'both')
        axisAnalysis = 1:2;
        legendValue = {'X','Peaks X', 'Tremors X', 'Y','Peaks Y', 'Tremors Y'};
    end
    
    for legAxis = axisAnalysis
        
        whichGroup = [];
        for i=2:size(output.MT,1)
            if strcmp(output.MT{i,1},flyPlot)
                x0 = output.MT{i,2}(:,legPlot,legAxis);
                whichFly = i;
                whichGroup = 'mt';
            end
        end
        for i=2:size(output.WT,1)
            if strcmp(output.WT{i,1},flyPlot)
                x0 = output.WT{i,2}(:,legPlot,legAxis);
                whichFly = i;
                whichGroup = 'wt';
            end
        end
        
        
        if strcmp(whichGroup,'mt')
            len0 = length(x0);
            finalPeaks = output.MT{whichFly,legAxis+2}(legPlot,1);
            finalPeaks = finalPeaks{:,1};
            peakMags = output.MT{whichFly,legAxis+2}(legPlot,2);
            peakMags = peakMags{:,1};
            
            tremorPeaks = output.MT{whichFly,legAxis+5}(legPlot,1);
            tremorPeaks = tremorPeaks{:,1};
            tremorMags = output.MT{whichFly,legAxis+5}(legPlot,2);
            tremorMags = tremorMags{:,1};
            
            plot(1:len0,x0,'.-','linewidth',4);hold on
            if markers
                plot(finalPeaks,peakMags,'ko','linewidth',10);
                plot(tremorPeaks,tremorMags,'ro','linewidth',10);
            end
            
        elseif strcmp(whichGroup,'wt')
            len0 = length(x0);
            finalPeaks = output.WT{whichFly,legAxis+2}(legPlot,1);
            finalPeaks = finalPeaks{:,1};
            peakMags = output.WT{whichFly,legAxis+2}(legPlot,2);
            peakMags = peakMags{:,1};
            
            tremorPeaks = output.WT{whichFly,legAxis+5}(legPlot,1);
            tremorPeaks = tremorPeaks{:,1};
            tremorMags = output.WT{whichFly,legAxis+5}(legPlot,2);
            tremorMags = tremorMags{:,1};
            
            plot(1:len0,x0,'.-','linewidth',4);hold on
            if markers
                plot(finalPeaks,peakMags,'ko','linewidth',2);
                plot(tremorPeaks,tremorMags,'ro','linewidth',2);
            end
        else
            disp('Please specify a correct fly name');
        end
        hold on;
    end
    
    if legPlot == 1
        legName = 'Left-Front';
    elseif legPlot == 2
        legName = 'Left-Middle';
    elseif legPlot == 3
        legName = 'Left-Hind';
    elseif legPlot == 4
        legName = 'Right-Front';
    elseif legPlot == 5
        legName = 'Right-Middle';
    elseif legPlot == 6
        legName = 'Right-Hind';
    end
    
    titleName = [flyPlot ' leg:' legName];
    title(titleName)
    %     legend(legendValue ,'Location','northwest');
    hold off;
end
end