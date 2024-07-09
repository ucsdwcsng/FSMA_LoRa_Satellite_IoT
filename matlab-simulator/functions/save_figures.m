function save_figures(params)
    
    FolderName = './figures';   % Your destination folder
    
    limit = params.nodesLimitPerTimeBin;
    sf = params.loraSF;
    payload = params.avgBytesPerPacket;
    codeRate = params.loraCodeRateType;

    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    if (isempty(FigList))
        return
    end
        
    for iFig = 1:length(FigList)
      FigHandle = FigList(iFig);
      FigName   = get(FigHandle, 'Name');
      savefig(FigHandle, fullfile(FolderName, FigName, sprintf('limit%d_sf%d_PL%d_CR%d_fig_%d.fig',limit,sf,payload,codeRate,FigHandle.Number)));
    end

end