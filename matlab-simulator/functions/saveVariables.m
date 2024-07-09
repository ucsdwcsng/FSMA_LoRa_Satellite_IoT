function saveVariables(params, output_metrics, nodesCountVals)
% saving variables

    timeStr = string(datetime('now','Format','d-MMM-y-HH-mm-ss'));
    folderName = "results";
    if (~exist(folderName, 'dir'))
        mkdir(folderName);
    end
    cd (folderName);
    mkdir(string(timeStr));
    cd (timeStr);
    filename = sprintf('variables_%s_%dvals_%0.0ftmin_%dnlim_%dac_%0.0fdc_%dCR_%dsf_%dPL',params.type,length(nodesCountVals), params.totalTimeSec/60,params.nodesLimitPerTimeBin, params.allowedCollisions, params.dutyCycle*100, params.loraCodeRateType, params.loraSF, params.avgBytesPerPacket);

    if (isfield(params,'subtype'))
        filename = sprintf('%s_%s',filename,params.subtype);
    end
    
    save(filename,'output_metrics', 'params', 'nodesCountVals');
    cd '../';
    cd '../';
end