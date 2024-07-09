
function [params] = setInitialParameters(config_params)
% This function generates initial params and metrics required to run the main simulation

    %% get all configuration params
    if (nargin < 1)
        config_params.enableDetectionDelay = True;
        config_params.enablePropagationDelays = false;
        config_params.CADdistanceLimit = 30e3;
        config_params.allowedCollisions = 1;
        config_params.nodesLimitPerTimeBin = 1; 
        config_params.type = 'FSMA'; % others - 'ALOHA', 'CSMA'
    end

    if (~isfield(config_params,'enableDetectionDelay'))
        config_params.enableDetectionDelay = false;
    end
    
    if (~isfield(config_params,'enablePropagationDelays'))
        config_params.enablePropagationDelays = false;
    end
    
    if (~isfield(config_params,'CADdistanceLimit'))
     config_params.CADdistanceLimit = 30e3;
    end
    
    if (~isfield(config_params,'allowedCollisions') && isfield(config_params,'nodesLimitPerTimeBin'))
        config_params.allowedCollisions = config_params.nodesLimitPerTimeBin;
    elseif (isfield(config_params,'allowedCollisions') && ~isfield(config_params,'nodesLimitPerTimeBin'))
        config_params.nodesLimitPerTimeBin = config_params.allowedCollisions;
    elseif (~isfield(config_params,'allowedCollisions') && ~isfield(config_params,'nodesLimitPerTimeBin'))
        config_params.allowedCollisions = 1;
        config_params.nodesLimitPerTimeBin = 1;
    end
    
    if (~isfield(config_params,'type'))
        config_params.type = 'FSMA';
    end


    %% params
    params.type = config_params.type;
    params.CADdistanceLimit = config_params.CADdistanceLimit;
    params.enablePropagationDelays = config_params.enablePropagationDelays;
    params.enableDetectionDelay = config_params.enableDetectionDelay;
    params.nodesLimitPerTimeBin = config_params.nodesLimitPerTimeBin;
    params.allowedCollisions = config_params.allowedCollisions;
    
    % Bytes to bits
    params.bitsPerByte = 8;

    % duty cycle
    params.dutyCycle = 0.01;% 1 percent (1%)
    
    %% lora params
%     params.loraSF = 8; % BSMA Ref
%     params.allowedBytesPerPacket = 16; % BSMA Ref
%     params.loraCodeRateType = 4;

    params.loraSF = 11; % fossa sat
    params.allowedBytesPerPacket = 16; % an array of allowed packets with range (0-255)
    params.loraCodeRateType = 4; % {1,2,3,4} corresponds to {4/5, 4/6, 4/7, 4/8}
    
    params.loraCodeRate = 4/(4+params.loraCodeRateType);
    params.loraBW = 125e3;
    params.loraPreambleSyms = 8;
    params.loraLowDatarateOptimize = 0;
    params.loraImplicitHeaderMode = 0; % 0 for explicit header mode, 1 for implicit
    params.loraCRC = 1;  % 0 for off, 1 for on;
    if (params.loraSF>10)
        params.loraLowDatarateOptimize = 1;% 0 for off, 1 for on (should be on if SF = 11 or 12)
    end
    params.loraSymTime = (2^params.loraSF)/params.loraBW;
    params.loraProcessingTime = 32/params.loraBW;

    % CAD
    params.CADTimeSec = (2^(params.loraSF)+32)/params.loraBW;
%     params.CADTimeSec = 0;

    %% time
    % params.timePerBinInSec = 2*(1.024e-3); % 1.024 ms (0.001024 seconds)
    params.timePerBinInSec = params.loraSymTime;
    params.totalTimeSec = 600; % in seconds (default 600)
    params.totalTimeBins = floor(params.totalTimeSec/params.timePerBinInSec); %0.01s
    params.loraSymTimeBin = ceil(params.loraSymTime/params.timePerBinInSec);
    params.loraProcessingTimeBin = ceil(params.loraProcessingTime/params.timePerBinInSec);
    params.CADTimeBin = ceil(params.CADTimeSec/params.timePerBinInSec); 

    %% power
    params.txPowerPerSec = 3.3*850*1e-3;
    params.rxPowerPerSec = 3.3*26*1e-3;
    
    % Fossa sat
    params.centerFreq = 401.7e6;
    params.nodesTxEIRP = 22; %dBm
    params.leoRxGain = 0; %dBi
    params.txPowerPerSec = 3.3*850*1e-3;
    params.rxPowerPerSec = 3.3*26*1e-3;

    %% Sensitivity
    switch (params.loraSF)
        case 7
            params.loraSensitivity = -123; %dBmz
        case 8
            params.loraSensitivity = -126; %dBm
        case 9
            params.loraSensitivity = -129; %dBm
        case 10
            params.loraSensitivity = -132; %dBm
        case 11
            params.loraSensitivity = -134.5; %dBm
        case 12
            params.loraSensitivity = -137; %dBm
        otherwise
            error('Give a valid LoRa SF {7-12}')
    end

    % Capacity
    % Ref:"Assessing LoRa for Satellite-to-Earth Communications Considering the Impact of Ionospheric Scintillation, Eq:3"
    params.networkCapacity = params.loraSF*params.loraCodeRate*params.loraBW/(2^params.loraSF);  

    %% params changing output metrics

%     params.minRxPacketLengthReqForDecode = 0.95;
    if (~isfield(config_params,'rxPacketSuccessThreshold'))
        config_params.rxPacketSuccessThreshold = 0.95;
    end
    params.minRxPacketLengthReqForDecode = config_params.rxPacketSuccessThreshold;

%     params.allowedBitsPerPacket = 10:10:50; % 0-255
    params.avgBytesPerPacket = mean(params.allowedBytesPerPacket);
    params.enableGatewayRxCAD = true;

    % detection delay
    if (params.enableDetectionDelay)
        params.detectionDelaySec = 2*params.CADTimeSec;
        %     params.detectionDelaySec = 0.3e-3;

    else
        params.detectionDelaySec = 0;
    end
    params.detectionDelayBins = ceil(params.detectionDelaySec/params.timePerBinInSec); 

    % params.detectionDelayBins = 1;
    % warning('hard coding detection delay to 1')
    % subtype
    params.subtype = '';
    if (params.enablePropagationDelays && params.enableDetectionDelay)
        params.subtype = 'DD and PD';
    elseif (~params.enablePropagationDelays && params.enableDetectionDelay)
        params.subtype = 'only DD';
    elseif (params.enablePropagationDelays && ~params.enableDetectionDelay)
        params.subtype = 'only PD';    
    elseif (~params.enablePropagationDelays && ~params.enableDetectionDelay)
        params.subtype = 'ideal';
    end

    if (strcmp(params.type,'CSMA'))
        params.subtype = sprintf('%s CAD-limit %0.0fkm',params.subtype, params.CADdistanceLimit/1e3);
    end

    %% Tx with Proabability
    params.txWithDynamicProbabilityFlag = false;
    if (isfield(config_params,'txWithDynamicProbabilityFlag'))
        params.txWithDynamicProbabilityFlag = config_params.txWithDynamicProbabilityFlag;
    end

    params.startOffsetTimerFlag = false;
    params.txWithProbability = 1;
    if (isfield(config_params,'txWithProbability'))
        params.startOffsetTxProbabilitylimit = config_params.txWithProbability;
        params.startOffsetTimerFlag = true;
    end

    if(strcmp(params.type,'FSMA') && params.txWithDynamicProbabilityFlag)
        params.subtype = sprintf('%s txWithDP-RL', params.subtype);
   
    elseif(strcmp(params.type,'FSMA') && params.startOffsetTimerFlag)
        params.subtype = sprintf('%s txWithP%0.0f', params.subtype, 100*params.startOffsetTxProbabilitylimit);
    end

    %%
    params.sleepOffsetTimerFlag = true; % default enabled
    params.variableCADFlag = false;
    params.maxAllowedVariableCADFactor = 10;

    % plots flag
    params.plotsFlag = false;

    % paacket lengths
    params.allowedPacketLengthSec = calculate_lora_packet_length(params.allowedBytesPerPacket, params);
    params.avgPacketLengthSec = mean(params.allowedPacketLengthSec);
    params.fixNodePacketsFlag = false;
    if (params.fixNodePacketsFlag)
        params.fixNodePackets = 20;
    else
        params.fixNodePackets = 0;
    end
    if (params.fixNodePacketsFlag)
        params.subtype = sprintf('%s fixP', params.subtype);
    end

    params.localStream = RandStream('dsfmt19937','NormalTransform','Inversion');

    %% capture falg
    params.enableCaptureEffect = true;

end