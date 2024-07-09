function [packetData, totalNodesPerBin] = generateGatewayPacketsWithTimeBin (packetData, node_params, params) 
% function goal is to generate gatewayRxPacketData every time bin / time symbol bins 
% according to nodesTxPacketData
    
%     % if active transmissions, return back to called 
%     activeNodes = sum(nodesTxPacketDataExt, 2) > 0;
%     if (sum(activeNodes) == 0)
%         return;
%     end

    % different delays (shifted data) due different propogation delays delays
    nodesDelayBins = node_params.propagationDelayBins;
    if (params.enablePropagationDelays)
        packetData = variableLengthShiftedColsOfMatrix(packetData, nodesDelayBins);
    end
        
    % collisions check
    % if no of transmissions are more than acceptable collisions all nodes packets get lost
%     gatewayRxPacketData = zeros(node_params.nodesCount, MAC_params.rxRequiredTimeBins,'uint16');
%     no_collision_indices = sum(packetData>0) < metrics.acceptedCollisions; % > 0 - only active Tx packet bin
%     gatewayRxPacketData(:,no_collision_indices) = packetData(:, no_collision_indices);

    totalNodesPerBin = sum(packetData>0); % > 0 - only active Tx packet bin
    % packetData(:,(totalNodesPerBin > params.allowedCollisions)) = 0;
end