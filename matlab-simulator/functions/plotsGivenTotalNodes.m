function plotsGivenTotalNodes(params, node_params, metrics)
% plots for anlaysing metrics for a given number of nodes
    
        %% metrics to plot
        time_totalTxActiveNodes = metrics.activeTxNodesPerTimeBin;
        time_totalRxActiveNodes = metrics.gatewayRxNodesPerTimeBin;
        time_axis = (1:length(time_totalTxActiveNodes))*params.timePerBinInSec;
        nodes_totalActiveTime = double(metrics.nodesTotalActiveTimebins)*params.timePerBinInSec;
        nodes_totalCADTime = double(metrics.nodeTotalCADTimebins)*params.timePerBinInSec;
        nodes_goodThroughput = (double(metrics.succeededNodePackets).*double(node_params.node_payloads_bytes))*(params.bitsPerByte/params.totalTimeSec); %(In bps)
        nodes_packetsReceivedRatioPerNode = (double(metrics.succeededNodePackets)./double(metrics.transmittedNodePackets))*100; %(0 - 100%)
    
        % factor = sum(metrics.transmittedNodePackets);        
        factor = 1;        
        
        %% plots
        figure(101); clf;

        plot(time_axis, time_totalTxActiveNodes./factor); hold on;
        plot(time_axis,time_totalRxActiveNodes./factor,':y')
        xlabel('Time (s)');
        ylabel('Packets')
        title('Simultaneous Packets at Satellite')
        yline(params.allowedCollisions./factor,'-',{ sprintf('Allowed collisions: %0.f packets',params.allowedCollisions) },'color','r','linewidth',2);
%         set(findall(gca, 'Type', 'Line'),'LineWidth',2);
        set(gca,'fontsize', 18);
        movegui('northeast')
        
        figure(102); clf;
        stem(nodes_totalActiveTime,'--')
        xlabel('Nodes');
        ylabel('Time (s)')
        title({'Total active time per node', sprintf('Simulation time %0.2f min (%d s)',params.totalTimeSec/60, params.totalTimeSec)})
        set(findall(gca, 'Type', 'Line'),'LineWidth',2);
        set(gca,'fontsize', 18);
        movegui('southwest')
        
        figure(103); clf; 
        stem(nodes_goodThroughput,':')
        xlabel('Nodes');
        title('Throughput from each node')
        ylabel('Throughput (bps)')
        set(findall(gca, 'Type', 'Line'),'LineWidth',2);
        set(gca,'fontsize', 18);
        movegui('south')
        
        figure(104); clf;
        stem(nodes_packetsReceivedRatioPerNode,'-.')
        xlabel('Nodes');
        title('Packet Received Ratio per node(%)')
        ylabel('PRR (%)')
        set(findall(gca, 'Type', 'Line'),'LineWidth',2);
        set(gca,'fontsize', 18);
        movegui('southeast')

        figure(105); clf;
        stem(nodes_totalCADTime,':')
        xlabel('Nodes');
        ylabel('Time (s)')
        title({'Total CAD time per node', sprintf('Simulation time %0.2f min (%d s)',params.totalTimeSec/60, params.totalTimeSec)})
        set(findall(gca, 'Type', 'Line'),'LineWidth',2);
        set(gca,'fontsize', 18);
        movegui('northwest')
    
end