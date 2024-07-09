function [metrics] = validatePacketSuccess(gatewayRxPacketData, params, node_params, MAC_params, metrics, timeBin_ind)
% this function updates packet received per collision free node.
% if more than accepted number of simultaneous transmissions => collision.
% when collision accurs all nodes packets fail/collides partially/completely
   % rxPacketBins = gatewayRxPacketData(:,MAC_params.currentBin-1:MAC_params.currentBin);
   rxPacketBins_nnz = sum(gatewayRxPacketData>0,2);
   minReqPacketLengthBins = params.minRxPacketLengthReqForDecode*node_params.packetLengthBins;
   succededNodeInCurrentBin = find(rxPacketBins_nnz > minReqPacketLengthBins);

   % if no active nodes with Tx packet bins return
   if (isempty(find(rxPacketBins_nnz>0, 1)))
       return;
   end

   % % diffPacketBins = diff(rxPacketBins,[],2);
   % minReqPacketLengthBins = params.minRxPacketLengthReqForDecode*node_params.packetLengthBins;
   % succededNodeInCurrentBin = find(diffPacketBins <= -1*minReqPacketLengthBins);

  % if no succeded nodes return
   if (isempty(succededNodeInCurrentBin))
       return;
   end

   for sNodeInd = 1:length(succededNodeInCurrentBin)
        sNode = succededNodeInCurrentBin(sNodeInd);
        % check if array is empty or last time bin greater than packet length
        if (isempty(metrics.succeededNodeTimeBins{sNode}) || (timeBin_ind > (metrics.succeededNodeTimeBins{sNode}(end)+minReqPacketLengthBins(sNode)))) % % last packet is more than packet length
        
            % success condition -  sum of last packet bins with tx mode should be atleast minRequiredBins
            if (sum(gatewayRxPacketData(sNode, MAC_params.currentBin-node_params.packetLengthBins(sNode)+1:MAC_params.currentBin) > 0) >= minReqPacketLengthBins)
        
                % success condition met, store timeBin;
                metrics.succeededNodeTimeBins{sNode} = [metrics.succeededNodeTimeBins{sNode} timeBin_ind];
            end
        end
   end

end