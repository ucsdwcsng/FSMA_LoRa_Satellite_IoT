function plotsVaryingTotalNodes(metrics, params, nodesCountVals, type, line_type)
% plots for anlayzing metrics by varying total number of nodes
% to understand scalability, reliability and overall network efficiency
    
%     if(strcmp(params.type,'FSMA')) 
%         sim_type = sprintf('%s limit%d',params.type,params.nodesLimitPerTimeBin);
%     elseif(strcmp(params.type,'BSMA')) 
%         sim_type = sprintf('%s limit%d',params.type,params.nodesLimitPerTimeBin);
%     elseif(strcmp(params.type,'CSMA'))
%         sim_type = sprintf('%s %.0fkm limit%d',params.type,floor(params.CADdistanceLimit/1e3),params.nodesLimitPerTimeBin) ;
%     else
%         sim_type = sprintf('%s limit%d',params.type,params.nodesLimitPerTimeBin) ;
%     end

    sim_type = params.type;
    if (params.nodesLimitPerTimeBin > 1)
        sim_type = sprintf('%s-nlim%d',sim_type,params.nodesLimitPerTimeBin);
    end
    if (isfield(params,'subtype'))
        sim_type = sprintf('%s-%s',sim_type,params.type);
    end


    if (nargin < 5)
        line_type = '-';
    end

    if (nargin > 3)
        sim_type = type;
    end

    %% plotting end figures
    figure(201); hold on;
    stem(nodesCountVals, metrics.unservedPacketsRate, DisplayName=sim_type,LineWidth=2); 
    xlabel('Nodes');
    ylabel('Unserved Packets per second')
    title({'Avg Unserved Packets'})
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    movegui('south')
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    figure(202); hold on;
    p2 = plot(nodesCountVals, metrics.rxActiveTime, DisplayName=sim_type);
    p2.LineStyle = line_type;
    xlabel('Nodes');
    title('Energy spent on Rx')
    ylabel('Energy')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    movegui('southeast')
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;
    
    figure(203); hold on;
    p3 = plot(nodesCountVals, metrics.txActiveTime, DisplayName=sim_type);
    p3.LineStyle = line_type;
    xlabel('Nodes');
    title('Energy spent on Tx')
    ylabel('Energy')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    movegui('northeast')
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    figure(204); hold on;
%     yline(metrics.networkCapacity,'--r',DisplayName='Acceptable Load'); hold on;
    stem(nodesCountVals, metrics.offeredLoadVals, DisplayName=sim_type,LineWidth=2); 
    xlabel('Nodes');
    ylabel('Active load (bps)')
    title({'Avg Active load'})
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    movegui('north')
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    figure(205); hold on;
%     yline(metrics.networkCapacity,'--r',DisplayName='Network Capacity'); hold on;
    p5 = plot(nodesCountVals, metrics.goodThroughputVals, DisplayName=sim_type); 
    p5.LineStyle = line_type;
    hold on;
    p5b = plot(nodesCountVals, metrics.networkCapacity, DisplayName='Network capcity'); 
    p5b.LineStyle = ':';
    xlabel('Nodes');
    title('Avg Network (good) Throughput')
    subtitle(sprintf('Duty cycle:%0.2f %%, Total time: %0.2f min',params.dutyCycle*100,params.totalTimeSec/60))
    ylabel('Throughput (bps)')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    movegui('northwest')
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    figure(206); hold on;
    p6 = plot(nodesCountVals, metrics.packetReceptionRatioVals*100, DisplayName=sim_type);
    p6.LineStyle = line_type;
    xlabel('Nodes');
    title('Packet Received Ratio (%)')
    subtitle(sprintf('Duty cycle:%0.2f %%, Total time: %0.2f min',params.dutyCycle*100,params.totalTimeSec/60))
    ylabel('PRR (%)')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    movegui('southwest')
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    figure(207); hold on;
    p7 = plot(nodesCountVals, metrics.gatewayRxActiveTimeRatio*100, DisplayName=sim_type); 
    p7.LineStyle = line_type;
    xlabel('Nodes');
    title('Satellite Rx/sleep time (%)')
    ylabel('Active time (%)')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    movegui('southeast')
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    figure(208); hold on;
    p8 = plot(nodesCountVals, metrics.gatewayTxActiveTimeRatio*100, DisplayName=sim_type);
    p8.LineStyle = line_type;
    xlabel('Nodes');
    title('Satellite active/Tx time (%)')     
    ylabel('Active time (%)')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    movegui('northeast')
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    fig209 = figure(209);
    fig209.OuterPosition = [1 500 690 580];
    hold on;
%     yline(100,'--r',DisplayName='Network Capacity'); hold on;
    p9 = plot(100*metrics.normalizedOfferedLoadRatio, 100.*metrics.normalizedThroughputRatio, DisplayName=sim_type); 
    p9.LineStyle = line_type;
    xlabel('Normalized Offered Load (%)');
    title('Normalized Throughput (%)')
    ylabel('Normalized Throughput (%)')
    subtitle(sprintf('SF:%0.0f,Payload:%0.0f bytes,Allowed collisions:%d',params.loraSF,params.avgBytesPerPacket, params.allowedCollisions))
    % subtitle(sprintf('SF:%0.0f, Payload:%0.0f bytes, Node limit:%d',params.loraSF,params.avgBytesPerPacket, params.nodesLimitPerTimeBin))
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    movegui('northwest')
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    fig210 = figure(210);
    fig210.OuterPosition = [1 1 690 580];
    hold on;
    %     yline(100,'--r',DisplayName='Efficiency'); hold on;
    p10 = plot(100*metrics.normalizedOfferedLoadRatio, 100.*metrics.packetReceptionRatioVals, DisplayName=sim_type);
    p10.LineStyle = line_type;
    xlabel('Normalized Offered Load (%)');
    title('Packet Received Ratio (%)')
    subtitle(sprintf('SF:%0.0f, Payload:%0.0f bytes,Totaltime:%0.2f min',params.loraSF,params.avgBytesPerPacket, params.totalTimeSec/60))
    % subtitle(sprintf('SF:%0.0f, Payload:%0.0f bytes, Node limit:%d',params.loraSF,params.avgBytesPerPacket, params.nodesLimitPerTimeBin))

    ylabel('PRR (%)')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    movegui('southwest')
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    %% added figures
    figure(211); hold on;
    simType = sprintf('%s, SF:%d, PL:%0.2f ms',params.type,params.loraSF,params.avgPacketLengthSec*1000);

    p11 = plot(nodesCountVals, metrics.channelActiveStatus*100, DisplayName=simType); 
    p11.LineStyle = line_type;
    xlabel('Nodes');
    title('Channel active/busy time (%)')
    ylabel('Active time (%)')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    movegui('southeast')
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    % combined figure
    figure(212); 
    if(isfield(params,'fixNodePacketsFlag') && params.fixNodePacketsFlag)
        sgtitle(sprintf('Fixed packets per node: %d',params.fixNodePackets));
    else
        sgtitle(sprintf('Duty cycle:%0.2f %%, Total time: %0.2f min',params.dutyCycle*100,params.totalTimeSec/60));
    end
    subplot(2,3,1); hold on;
    p5 = plot(nodesCountVals, metrics.totalPackets, DisplayName=simType); 
    p5.LineStyle = '--';
%     xlabel('Nodes');
%     title('Total Packets')
%     ylabel('Packets')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    subplot(2,3,1); hold on;
    p5 = plot(nodesCountVals, metrics.totalCollisions, DisplayName=simType); 
    p5.LineStyle = line_type;
    xlabel('Nodes');
    title(' Total packets/Collisions')
    ylabel('Packets')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    subplot(2,3,2); hold on;
    p5 = plot(nodesCountVals,  (metrics.totalPackets-metrics.totalCollisions), DisplayName=simType); 
    p5.LineStyle = line_type;
    xlabel('Nodes');
    title('Succedded Packets')
    ylabel('Packets')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    subplot(2,3,3);  hold on;
    p5 = plot(nodesCountVals, metrics.goodThroughputVals, DisplayName=simType); 
    p5.LineStyle = line_type;
%     hold on;
%     p5b = plot(nodesCountVals, metrics.networkCapacity, DisplayName='Network capcity'); 
%     p5b.LineStyle = ':';
    xlabel('Nodes');
    title('Avg Network (good) Throughput')
    ylabel('Throughput (bps)')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    subplot(2,3,4); hold on;
    p5 = plot(nodesCountVals, 100*(metrics.totalCollisions./metrics.totalPackets), DisplayName=simType); 
    p5.LineStyle = line_type;
    xlabel('Nodes');
    title('Collisions Ratio (%)')
    ylabel('Collsions (%)')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    subplot(2,3,5);  hold on;
    p6 = plot(nodesCountVals, metrics.packetReceptionRatioVals*100, DisplayName=simType);
    p6.LineStyle = line_type;
    xlabel('Nodes');
    title('Packet Received Ratio (%)')
    ylabel('PRR (%)')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    subplot(2,3,6);  hold on;
    p5 = plot(nodesCountVals, 100.*metrics.normalizedThroughputRatio, DisplayName=simType); 
    p5.LineStyle = line_type;
    xlabel('Nodes');
    title('Normalized Throughput (%)')
    ylabel('Normalized Throughput (%)')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2);
    set(gca,'fontsize', 18);
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;

    end