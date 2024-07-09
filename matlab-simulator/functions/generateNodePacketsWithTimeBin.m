function [nodesTxPacketData, MAC_params, metrics] = generateNodePacketsWithTimeBin (nodesTxPacketData, params, node_params, metrics, MAC_params, timeBin_ind) 
% function goal is to generate/update nodesTxPacketData every time bin / time symbol bins 
    
    % [active_locs,active_locs_timeBins] = ismember(MAC_params.packet_arrival_timeBins,timeBin_ind);

    % Extract all nodes with arrivals matching given time_ind
    [nodesWithLoad, ~]  = find(MAC_params.packet_arrival_timeBins == timeBin_ind);

    % if there is no node with with given time_ind as arrival time return to main function
    if(isempty(nodesWithLoad))
        return;
    end

    randomizeNodes = randperm(length(nodesWithLoad)); % select randomly from contending IoT nodes for fairness
    currentNodeBin = MAC_params.currentBin; % current bin in nodesTxPacketData
%     currentGatewayBin = MAC_params.currentBin; % current bin in gatewayRxPacketData

    for nodeWithLoadArr_Idx = 1:length(nodesWithLoad)
        randomizedIndex = randomizeNodes(nodeWithLoadArr_Idx);
        nodeLoadInd = nodesWithLoad(randomizedIndex);
        
        % get node packet and CAD bins
        nodePacketBins = node_params.packetLengthBins(nodeLoadInd);
        nodeCADTimeBins = params.CADTimeBin;

        % no active transmission
        if (nodesTxPacketData(nodeLoadInd,currentNodeBin) == 0) 
            determineCADStatus = false;

        % if node in last last bin of CAD, determine CAD status and transmit from next bin
        elseif (nodesTxPacketData(nodeLoadInd,currentNodeBin) == -1) 
            determineCADStatus = true;
        
        % if node in already transmitting a packet, try after packet completion
        elseif (nodesTxPacketData(nodeLoadInd,currentNodeBin) > 0) 
            waitTimeBins = nodePacketBins-nodesTxPacketData(nodeLoadInd,currentNodeBin)+1;
            MAC_params = backoffAndUpdateArrivalTime(MAC_params, nodeLoadInd, timeBin_ind, waitTimeBins);
            continue;

        % if node in sensing/CAD mode, schedule after sensing
        elseif (nodesTxPacketData(nodeLoadInd,currentNodeBin) < -1) 
            waitTimeBins = -nodesTxPacketData(nodeLoadInd,currentNodeBin)+1;
            MAC_params = backoffAndUpdateArrivalTime(MAC_params, nodeLoadInd, timeBin_ind, waitTimeBins);
            continue;

        % else incorrect node status
        else
            error('Incorrect node status: %d, timeBin_ind = %d, node_ind = %d \n',nodesTxPacketData(nodeLoadInd,currentNodeBin), timeBin_ind, nodeLoadInd);
        end
        
        %% node is not actively Tx and CAD and has packet to transmit
        % Note: No active Tx now => current node doesn't have active Tx now and also not in future time bins 

        switch params.type
            case 'ALOHA'
                %% ALOHA - no CAD 

                % assumes channel is always FREE
                nodesTxPacketData = transmitPacketFromNode(nodesTxPacketData, nodeLoadInd, currentNodeBin, nodePacketBins);

            case 'CSMA'
                %% CSMA - do CAD 

                % if sensing not done - start sensing and backoff for cad bins - 1
                if (~determineCADStatus) 
                    nodesTxPacketData = sensingChannelActivityAtNode(nodesTxPacketData, nodeLoadInd, currentNodeBin, nodeCADTimeBins);
                    MAC_params = backoffAndUpdateArrivalTime(MAC_params, nodeLoadInd, timeBin_ind, nodeCADTimeBins);

                % if node in last last bin of sensing, evaluate status and transmit from next bin or backoff
                elseif (determineCADStatus) 
                    % Assuming hearing range delays are within CAD time  
                    nodesActiveTxCheck = nodesTxPacketData(:,currentNodeBin-1) > 0;
                    distance_check = node_params.CADcheck(:,nodeLoadInd);
                    isChannelFree = (sum(nodesActiveTxCheck.*distance_check) < params.allowedCollisions);
                    if (isChannelFree)
                        nodesTxPacketData = transmitPacketFromNode(nodesTxPacketData, nodeLoadInd, currentNodeBin, nodePacketBins);
                    else
                        backoffSleepOffsetTimerBins = randi(params.localStream,node_params.maxPacketLengthBins);
                        MAC_params = backoffAndUpdateArrivalTime(MAC_params, nodeLoadInd, timeBin_ind, backoffSleepOffsetTimerBins);
                    end
                end   
            
            case 'FSMA'
                 %% FSMA - do CAD 

                % if sensing not done - start sensing and backoff for cad bins - 1
                if (~determineCADStatus) 
                    if (params.variableCADFlag)
                        nodeCADTimeBins = randi(params.maxAllowedVariableCADFactor)*params.CADTimeBin;
                    end
                    nodesTxPacketData = sensingChannelActivityAtNode(nodesTxPacketData, nodeLoadInd, currentNodeBin, nodeCADTimeBins);
                    MAC_params = backoffAndUpdateArrivalTime(MAC_params, nodeLoadInd, timeBin_ind, nodeCADTimeBins);

                % if node in last last bin of sensing, evaluate status and transmit from next bin or backoff
                elseif (determineCADStatus) 
     
                    % determine gatewayCAD status
                    % both detection delay and propagation
                    
                    %% delay from gateway free signal to nodes
                    if (params.enableDetectionDelay && params.enablePropagationDelays)
                        % gatewayCADFreeStatus = metrics.gatewayRxNodesPerTimeBin(timeBin_ind-1) < params.nodesLimitPerTimeBin;
                        gatewayCADFreeStatus = metrics.gatewayRxNodesPerTimeBin(timeBin_ind-node_params.nodeRxTotalDelayBins(nodeLoadInd)) < params.nodesLimitPerTimeBin;

                    % only propagation delay
                    elseif (~params.enableDetectionDelay && params.enablePropagationDelays)
                        % gatewayCADFreeStatus = metrics.gatewayRxNodesPerTimeBin(timeBin_ind-1) < params.nodesLimitPerTimeBin;
                        gatewayCADFreeStatus = metrics.gatewayRxNodesPerTimeBin(timeBin_ind-node_params.propagationDelayBins(nodeLoadInd)) < params.nodesLimitPerTimeBin;

                    % only detection delay
                    elseif (params.enableDetectionDelay && ~params.enablePropagationDelays)
                        gatewayCADFreeStatus = metrics.gatewayRxNodesPerTimeBin(timeBin_ind-params.detectionDelayBins) < params.nodesLimitPerTimeBin;

                    else
                        % gatewayCADFreeStatus = metrics.gatewayRxNodesPerTimeBin(timeBin_ind) < params.nodesLimitPerTimeBin;
                        gatewayCADFreeStatus = sum(nodesTxPacketData(:,currentNodeBin-1) > 0) < params.nodesLimitPerTimeBin;
                        % gatewayCADFreeStatus = metrics.activeTxNodesPerTimeBin(timeBin_ind-1) < params.nodesLimitPerTimeBin;
                    end
                    
                    % % gatewayCADFreeStatus = metrics.gatewayRxNodesPerTimeBin(timeBin_ind) < params.nodesLimitPerTimeBin;
                    % if (params.enableDetectionDelay)
                    %     gatewayCADFreeStatus = sum(nodesTxPacketData(:,currentNodeBin-params.detectionDelayBins) > 0) < params.nodesLimitPerTimeBin;
                    % else
                    %     gatewayCADFreeStatus = sum(nodesTxPacketData(:,currentNodeBin) > 0) < params.nodesLimitPerTimeBin;
                    % end

                    % determine channel status
                    isChannelFree = false;
                    % if (gatewayCADFreeStatus && params.txWithDynamicProbabilityFlag)
                    if (gatewayCADFreeStatus && params.txWithDynamicProbabilityFlag)

                        activeNodes = sum(nodesTxPacketData(:,currentNodeBin+(params.detectionDelayBins+node_params.gatewayMaxDelayBins)) > 0);
    
                        % dynamic probabity assignment as per expected load
                        if (activeNodes > 0)
                            params.startOffsetTxProbabilitylimit = 0;
                        else
                            params.startOffsetTxProbabilitylimit = 1;
                        end
    
                        randGen = rand(params.localStream);
                        % metrics.randomGenStartOffsetTxProbability{nodeLoadInd} = [metrics.randomGenStartOffsetTxProbability{nodeLoadInd} randGen];
                        if (randGen <= params.startOffsetTxProbabilitylimit)
                            isChannelFree = true;
                        end
    
                    elseif (gatewayCADFreeStatus && params.startOffsetTimerFlag)
                        randGen = rand(params.localStream);
                        % metrics.randomGenStartOffsetTxProbability{nodeLoadInd} = [metrics.randomGenStartOffsetTxProbability{nodeLoadInd} randGen];
                        if (randGen <= params.startOffsetTxProbabilitylimit)
                            isChannelFree = true;
                        end
    
                    elseif (gatewayCADFreeStatus)
                        isChannelFree = true;
                    end

                    % transmit/backoff
                    if (isChannelFree)
                        nodesTxPacketData = transmitPacketFromNode(nodesTxPacketData, nodeLoadInd, currentNodeBin, nodePacketBins);
                    else
                        backoffSleepOffsetTimerBins = randi(params.localStream,node_params.maxPacketLengthBins);
                        MAC_params = backoffAndUpdateArrivalTime(MAC_params, nodeLoadInd, timeBin_ind, backoffSleepOffsetTimerBins);
                    end
                end

            otherwise
                error('Enter valid MAC type (ALOHA, CSMA, BSMA, FSMA)')
        end
           
    end
end


% transmit packet data
function nodesTxPacketData = transmitPacketFromNode(nodesTxPacketData, nodeLoadInd, currentNodeBin, nodePacketBins)
    nodesTxPacketData(nodeLoadInd,currentNodeBin:currentNodeBin+nodePacketBins-1) = 1:nodePacketBins;  % transmit from next time sym
end

% channel activity detection
function nodesTxPacketData = sensingChannelActivityAtNode(nodesTxPacketData, nodeLoadInd, currentNodeBin, additionalCADTimeBins)
    nodesTxPacketData(nodeLoadInd,currentNodeBin:currentNodeBin+additionalCADTimeBins) = -1-additionalCADTimeBins:-1; % sense till this time sym (current bin + time step)
end