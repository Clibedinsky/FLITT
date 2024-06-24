# FLITT
Wu, S., Tan, K.J., Govindarajan, L.N., Stewart, J.C., Gu, L., Ho, J.W.H., Katarya, M., Wong, B.H., Tan, E.K., Li, D. and Claridge-Chang, A., 2019. Fully automated leg tracking of Drosophila neurodegeneration models reveals distinct conserved movement signatures. PLoS biology, 17(6), p.e3000346.

# Running tremor scripts

  1. Run findTremors to find the numbers of tremors in each video

    output = findTremors('/Users/syaw/Dropbox/Work/Writing Ongoing/Gait in Fly ND Models/Tracking methods paper/Data/ElavQ84 Upside Down', 'Q27', 'Q84', 3, [3 100], 1)
    
     Run both positive and negative peaks (1 or 0)
  
  2. Run plotSpecific (after findTremors) to plot the chart of interest
  
    plotSpecific(output,'Q84 elav-gal4 Q84 B2 27D male 2-1up tremor _H2',1:6,'both', 1)
  
  3. Run findFrequency to plot tremor frequency histogram and get histogram numbers
  
    [outputPos, outputNeg, outputFreqPosMT, outputFreqNegMT, outputFreqBothMT, outputFreqPosWT, outputFreqNegWT, outputFreqBothWT] = findFrequency('/Users/syaw/Dropbox/Work/Writing Ongoing/Gait in Fly ND Models/Tracking methods paper/Data/SCA3', 'yw', 'HK2', 'legs')
  
    You can click on the note symbol in the figure drawn, then click on the bar to get bar values
  
    You can sort(outputFreqBothMT) to get a list of the tremor frequency values
  
    This also gives you all the Neg(ative) and Pos(itive) tremors for WT and mutant. Click on the ‘TremorsX’ or ‘TremorsY’ 6x2 cell to see in which legs the tremors are found.





![image](https://github.com/Clibedinsky/FLITT/assets/31479517/a02dfe25-9da8-4b2d-b5cf-cbe157e1b0e3)

