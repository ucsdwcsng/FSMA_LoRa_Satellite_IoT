function plotsVaryingTotalNodes2(metrics, params, nodesCountVals, type, line_type)
% plots for anlayzing metrics by varying total number of nodes
% to understand scalability, reliability and overall network efficiency
    
    if(strcmpi(params.type,'CSMA'))
        sim_type = sprintf('%s-%.0fkm',params.type,floor(params.CADdistanceLimit/1e3)) ;
    else
        sim_type = params.type;
    end

    if (nargin < 5)
        line_type = '-';
    end

    if (nargin > 3)
        sim_type = type;
    end

    %% plotting end figures


    fig20 = figure(20);
    fig20.OuterPosition = [1 500 690 580];
    hold on;
    % multiplying with 100 for nodesCountVals to change 1% duty cycle to 0.01% duty cycle
    p9 = errorbar(100*nodesCountVals, 100.*metrics.normalizedThroughputRatio, 100*metrics.normalizedThroughputRatio_error, '--',Linewidth=3, DisplayName=sim_type); 
    p9.LineStyle = line_type;
    xlabel('Nodes');
    ylim([0 100])

    % xlim([0 50000])
    % xticks(0:10000:50000)
    % xticklabels(0:10000:50000)
    % title('Normalized Throughput (%)')
    ylabel('Normalized Throughput (%)')
    set(findall(gca, 'Type', 'Line'),'LineWidth',3);
    set(gca,'fontsize', 18);
    movegui('northwest')
    grid on;
    leg = legend('Location','best');
    leg.ItemHitFcn = @legend_action1;
    fig20.Position = [10 10 1200 1000];

    set(leg,'fontsize',30);
    set(gca, 'fontsize',30);
    set(gcf,'PaperUnits', 'inches', 'paperposition', [0 0 6 5])
    filename = '/figures/eval_scalability.pdf';
    % saveas(gcf,[pwd,filename]) 
    % export_fig(fig20, [pwd,filename]);
    exportgraphics(fig20,[pwd,filename],'ContentType','vector')
    % system('pdfcrop ./figures/eval_scalability.pdf ./figures/eval_scalability.pdf')

    end