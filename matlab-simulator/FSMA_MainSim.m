%% LoRa based Satellite IoT

clc;
clearvars;
close all;

% rng(1);
globalStream = RandStream('mlfg6331_64','NormalTransform','Polar');
RandStream.setGlobalStream(globalStream);

%add funcitons path
addpath('./functions')  
%% params

type_strings = ["FSMA", "ALOHA", "CSMA", "CSMA", "CSMA"]; 
cad_distance = [3000 0 30 1500 3000]*1e3;

for ind = 1:numel(type_strings)

    % start time
    % type_start = tic;

    % Set type and inital params
    [config] = setConfigParameters(type_strings(ind), cad_distance(ind));
    [params] = setInitialParameters(config);   
    
     fprintf("%s, %s \n",params.type, params.subtype);
%     params.plotsFlag = true;
                        
    %% initialize nodes array

    params.nIterations = 5;
    nodesCountVals =  [5 10 20 30 40 50 60 80 100 125 150 175 200];
    % nodesCountVals =  [5 10 20 30 40 50 60 80 100 125 150 175 200 250 300 400 500];

    lengthNodesArray = length(nodesCountVals);
    totalCollisions = zeros(lengthNodesArray,params.nIterations);
    totalPackets = zeros(lengthNodesArray,params.nIterations);
    packetReceptionRatioVals = zeros(lengthNodesArray,params.nIterations);
    goodThroughputVals = zeros(lengthNodesArray,params.nIterations);
    offeredLoadVals = zeros(lengthNodesArray,params.nIterations);
    rxActiveTime = zeros(lengthNodesArray,params.nIterations);
    txActiveTime = zeros(lengthNodesArray,params.nIterations);
    unservedPacketsRate = zeros(lengthNodesArray,params.nIterations);
    gatewayTxActiveTimeRatio = zeros(lengthNodesArray,params.nIterations);
    gatewayRxActiveTimeRatio = zeros(lengthNodesArray,params.nIterations);
    channelActiveStatus = zeros(lengthNodesArray,params.nIterations);
    networkCapacity = zeros(lengthNodesArray,params.nIterations);
    
    for itrInd = 1:params.nIterations
        fprintf('Iteration: %d \n',itrInd);
    
        % parfor
        parfor nodesInd = 1:lengthNodesArray
            % t_start = tic;
    
            % clear any previous memory in node_params
            node_params = [];
            metrics  = [];
            MAC_params = [];
    
            % set number of nodes
            node_params.nodesCount = nodesCountVals(nodesInd);
            % fprintf('Nodes: %d \n',node_params.nodesCount);
    
            % Distance 
            node_params.CADdistanceLimit = params.CADdistanceLimit;
            if (strcmp(config.type,'CSMA'))
                [node_params.distance, node_params.propagationDelays, node_params.nodesPower, node_params.CADcheck] = sensorDistributionAndLinkBudget(params, node_params);
            else
                 [node_params.distance, node_params.propagationDelays, node_params.nodesPower] = sensorDistributionAndLinkBudget(params, node_params);
            end
    
            % if propogation delays enabled
            if (params.enablePropagationDelays)
                node_params.propagationDelayBins = ceil(node_params.propagationDelays/params.timePerBinInSec);
            else
                node_params.propagationDelayBins = zeros(node_params.nodesCount,1);
            end
    
            % if detection delay at gateway is non zero
            if (params.enableDetectionDelay)
                node_params.nodeRxTotalDelayBins = ceil((node_params.propagationDelays + params.detectionDelaySec)/params.timePerBinInSec); % PD + detection delays
            else
                node_params.nodeRxTotalDelayBins = node_params.propagationDelayBins;
            end
    
            % Lora node payloads
            payload_indices = randi(length(params.allowedBytesPerPacket),node_params.nodesCount,1);
            node_params.node_payloads_bytes = params.allowedBytesPerPacket(payload_indices);
            node_params.node_packet_lengths_sec = params.allowedPacketLengthSec(payload_indices);
            node_params.packetLengthBins = (ceil(node_params.node_packet_lengths_sec./params.timePerBinInSec));
            node_params.gatewayMaxDelayBins =  max(node_params.propagationDelayBins);
            node_params.nodeMaxDelayBins = max(node_params.nodeRxTotalDelayBins);
    
            %% Metrics
            metrics.transmittedNodePackets = zeros(node_params.nodesCount, 1);
            metrics.nodesTotalActiveTimebins = zeros(node_params.nodesCount, 1);
            metrics.nodeTotalCADTimebins = zeros(node_params.nodesCount, 1);
            metrics.succeededNodeTimeBins = cell(node_params.nodesCount, 1);
            metrics.activeTxNodesPerTimeBin = zeros(1,  params.totalTimeBins);
            metrics.gatewayTxCADStatusPerTimeBin = true(1,  params.totalTimeBins); 
            metrics.channelActiveStatusPerTimeBin = false(1, params.totalTimeBins);
            metrics.gatewayRxNodesPerTimeBin = zeros(1,  params.totalTimeBins); 
            metrics.randomGenStartOffsetTxProbability = cell(node_params.nodesCount, 1);
            %% MAC
            node_params.maxPacketLengthBins = max(node_params.packetLengthBins);
            MAC_params.txRequiredTimeBins = 2*node_params.maxPacketLengthBins + node_params.gatewayMaxDelayBins + 1; 
            MAC_params.rxRequiredTimeBins = node_params.maxPacketLengthBins+ node_params.gatewayMaxDelayBins+1;
            MAC_params.currentBin = node_params.maxPacketLengthBins + node_params.gatewayMaxDelayBins+1;
            MAC_params.nodesInTxMode = false(node_params.nodesCount,1);
            MAC_params.nodesInCADMode = false(node_params.nodesCount,1);
            MAC_params.lock_status = 'F';% F-free, S-sensing, B-busy
            MAC_params.lockedNode = 0;
            MAC_params.lock_timer = 0; 
            MAC_params.collision_free_bins = 0; 
            MAC_params.exit_timer_bins = node_params.packetLengthBins(1);           %MAC_params.localStream = RandStream('dsfmt19937','NormalTransform','Inversion');
            nodesTxPacketData = zeros(node_params.nodesCount, MAC_params.txRequiredTimeBins,'int32');
    
            %% poisson packet arrival 
            arrival_times = possion_arrival_model(params, node_params.node_packet_lengths_sec, node_params.nodesCount,  params.totalTimeSec, params.dutyCycle);
            node_params.packetsPerNode = zeros(node_params.nodesCount,1); % each node packets 
            packet_arrival_timeBins = zeros(node_params.nodesCount,255); % converting dynamic cell to matrix
    
            % check arrival times in each node
            for node_ind = 1:node_params.nodesCount
                node_params.packetsPerNode(node_ind) = length(arrival_times{node_ind});
                packet_arrival_timeBins(node_ind,1:node_params.packetsPerNode(node_ind)) = floor(arrival_times{node_ind}/params.timePerBinInSec);
            end
    
            MAC_params.packet_arrival_timeBins = packet_arrival_timeBins(:,1:max(node_params.packetsPerNode));
            
            %% Transmit & Receive
            startOffsetTimeBin = node_params.nodeMaxDelayBins+1; % to avoid array indexing errors
    
            for timeBin_ind = startOffsetTimeBin:params.totalTimeBins
                % disp(timeBin_ind/params.totalTimeBins);
    
                % update nodesTxPacketData
                % nodesTxPacketData = [nodesTxPacketData(:,2:end) zeros(node_params.nodesCount, 1)];
                nodesTxPacketData = circshift(nodesTxPacketData, -1,2); 
                nodesTxPacketData(:,end) = 0;
    
                [nodesTxPacketData, MAC_params, metrics] = generateNodePacketsWithTimeBin (nodesTxPacketData, params, node_params, metrics, MAC_params, timeBin_ind);
                
                % update metrics
                metrics.nodesTotalActiveTimebins = (sum((nodesTxPacketData(:, MAC_params.currentBin) > 0),2)) + metrics.nodesTotalActiveTimebins;
                metrics.nodeTotalCADTimebins = (sum((nodesTxPacketData(:, MAC_params.currentBin) < 0),2)) + metrics.nodeTotalCADTimebins;
                metrics.activeTxNodesPerTimeBin(timeBin_ind) = sum(nodesTxPacketData(:, MAC_params.currentBin) > 0);
    
                % generate gatewayRxPacketData; 
                % (1:MAC_params.currentBin) => nodes transmit packet data upto current timebin (gateway can't see future bins)
    %             [gatewayRxPacketData] = generateGatewayPacketsWithTimeBin(nodesTxPacketData(:,1:MAC_params.currentBin), node_params, metrics);
                [gatewayRxPacketData, totalNodesPerBin] = generateGatewayPacketsWithTimeBin (nodesTxPacketData(:,1:MAC_params.currentBin), node_params, params) ;
                metrics.gatewayRxNodesPerTimeBin(timeBin_ind) = totalNodesPerBin(MAC_params.currentBin);
    
                % updated metrics - validate packet succes and CAD status
                if (params.enableCaptureEffect)
                    [gatewayRxPacketData_filt, MAC_params] = applyCaptureEffect(gatewayRxPacketData, params, MAC_params, node_params.nodesPower, node_params.packetLengthBins);
                else
                    gatewayRxPacketData(:,(totalNodesPerBin > params.allowedCollisions)) = 0;
                    gatewayRxPacketData_filt = gatewayRxPacketData;
                end
    
                active_nodes = sum(gatewayRxPacketData_filt>0);
                if (~isempty(find(active_nodes>1, 1)))
                    display(find(active_nodes))
                end
                [metrics] = validatePacketSuccess(gatewayRxPacketData_filt, params, node_params, MAC_params, metrics, timeBin_ind);
            end   
            
            %% metrics
                
            metrics.succeededNodePackets =  cellfun(@(x)length(x), metrics.succeededNodeTimeBins);
            metrics.transmittedNodePackets = ceil(metrics.nodesTotalActiveTimebins./node_params.packetLengthBins);
            metrics.totalOfferedNodePackets = node_params.packetsPerNode;
            metrics.gatewayTxCADStatusPerTimeBin = metrics.gatewayRxNodesPerTimeBin < params.nodesLimitPerTimeBin;
            metrics.channelActiveStatusPerTimeBin = metrics.activeTxNodesPerTimeBin > 0; 
            metrics.gatewayRxNodesPerTimeBin(metrics.gatewayRxNodesPerTimeBin > params.allowedCollisions) = 0;
    
            totalTimeBins = length(metrics.activeTxNodesPerTimeBin);
            totalTimeSec = totalTimeBins*params.timePerBinInSec;
            nodesTotalActiveTime = double(metrics.nodesTotalActiveTimebins)*params.timePerBinInSec;
            nodesTotalCADTime = double(metrics.nodeTotalCADTimebins)*params.timePerBinInSec;
    
            totalPackets(nodesInd,itrInd) =  sum(metrics.transmittedNodePackets);
            totalCollisions(nodesInd,itrInd) = sum(metrics.transmittedNodePackets) - sum(metrics.succeededNodePackets);
            packetReceptionRatioVals(nodesInd,itrInd) =  (sum(metrics.succeededNodePackets)./sum(metrics.transmittedNodePackets));
            goodThroughputVals(nodesInd,itrInd) =  sum(metrics.succeededNodePackets.*node_params.node_payloads_bytes) *(params.bitsPerByte/params.totalTimeSec); %(In bps)
            offeredLoadVals(nodesInd,itrInd) = sum(metrics.totalOfferedNodePackets.*node_params.node_payloads_bytes) *(params.bitsPerByte/params.totalTimeSec); %(In bps)
            rxActiveTime(nodesInd,itrInd) = sum(nodesTotalCADTime)*params.timePerBinInSec;
            txActiveTime(nodesInd,itrInd) = sum(nodesTotalActiveTime)*params.timePerBinInSec;
            unservedPacketsRate(nodesInd,itrInd) = sum(metrics.totalOfferedNodePackets - metrics.succeededNodePackets)/totalTimeSec;
            gatewayTxActiveTimeRatio(nodesInd,itrInd) = sum(metrics.gatewayTxCADStatusPerTimeBin)/totalTimeBins;
            gatewayRxActiveTimeRatio(nodesInd,itrInd) = 1 - gatewayTxActiveTimeRatio(nodesInd,itrInd);
            channelActiveStatus(nodesInd,itrInd) = mean(metrics.channelActiveStatusPerTimeBin);
            % networkCapacity(nodesInd) = params.allowedCollisions*params.avgBytesPerPacket*params.bitsPerByte/(mean(node_params.packetLengthBins)*params.timePerBinInSec); %(In bps)
            networkCapacity(nodesInd,itrInd) = params.allowedCollisions*params.bitsPerByte*(mean(node_params.node_payloads_bytes./node_params.node_packet_lengths_sec)); %(In bps)
            
            % print total sim time
            % toc(t_start)
    
            if(params.plotsFlag)
                plotsGivenTotalNodes(params, node_params, metrics)
            end
    
    
        end    
    
    end    
    if (length(nodesCountVals)>1)
        output_metrics.totalPackets = mean(totalPackets,2);
        output_metrics.totalCollisions = mean(totalCollisions,2);
        output_metrics.packetReceptionRatioVals = mean(packetReceptionRatioVals,2);
        output_metrics.goodThroughputVals= mean(goodThroughputVals,2);
        output_metrics.offeredLoadVals = mean(offeredLoadVals,2);
        output_metrics.rxActiveTime = mean(rxActiveTime,2);
        output_metrics.txActiveTime = mean(txActiveTime,2);
        output_metrics.unservedPacketsRate = mean(unservedPacketsRate,2) ;
        output_metrics.gatewayTxActiveTimeRatio = mean(gatewayTxActiveTimeRatio,2);
        output_metrics.gatewayRxActiveTimeRatio = mean(gatewayRxActiveTimeRatio,2);
        output_metrics.channelActiveStatus = mean(channelActiveStatus,2);
        output_metrics.networkCapacity = mean(networkCapacity,2);

        output_metrics.normalizedOfferedLoadRatio = output_metrics.offeredLoadVals./output_metrics.networkCapacity;
        output_metrics.normalizedThroughputRatio = output_metrics.goodThroughputVals./output_metrics.networkCapacity;
        output_metrics.normalizedThroughputRatio_error = std(goodThroughputVals,[],2)./mean(networkCapacity,2);

        % save variables
        saveVariables(params, output_metrics, nodesCountVals)
    
        % plots
        plotsVaryingTotalNodes2(output_metrics, params, nodesCountVals)

    end

    % end time
    % toc(type_start)
end
save_figures(params);
