function [nodesDistance, propagation_delays, nodesPower, distance_check_mat, distance_meas_mat] = sensorDistributionAndLinkBudget(params, node_params)
% This function generates nodes and estimate link budget
% input: system Params
% output: distance_meas_mat (measured distance from all other nodes), distance_check_mat (determines CSMA hearing ability frmo one node to another)

    %% IoT sensors distribution
    cSpeed = 3e8;
    centerPos = [0,0];
    inRadius = 500e3;
    outRadius = 1500e3;
    nodesMinDist = 0.1e3;
    shadowFadingStdDev = 6;%dB
    nodesDistance = inRadius + floor(((outRadius-inRadius)/nodesMinDist).*rand(1,node_params.nodesCount)).*nodesMinDist;
    nodesAngle = 360*rand(1,node_params.nodesCount);
    nodesPos = (nodesDistance.*cosd(nodesAngle)).' +1j*(nodesDistance.*sind(nodesAngle)).';
    plotsFlag = true;%params.plotsFlag;

    % distance
    distance_meas_mat = abs(nodesPos - nodesPos.');
    distance_check_mat = distance_meas_mat < node_params.CADdistanceLimit;

    % propagation_delays
    propagation_delays = nodesDistance/cSpeed;

    if (plotsFlag)
        figure(1); clf;
        viscircles(centerPos,inRadius/1e3,Color='g'); hold on;
        viscircles(centerPos,outRadius/1e3,Color='y'); hold on;
        plot(0,0,'hexagram',Color='r',LineWidth=2); hold on;
        plot(real(nodesPos)/1e3, imag(nodesPos)/1e3,'x',Color='k')
        xlabel('Distance (km)')
        ylabel('Distance (km)')
        title('IoT sensors (nodes) distribution')
        set(findall(gca, 'Type', 'Line'),'LineWidth',2);
        set(gca,'fontsize', 18);
        movegui('northwest')
    end

    %% link budget
    FSPL = 20*log10(nodesDistance) + 20*log10(params.centerFreq) - 20*log10(3e8/(4*pi));
    shadowFading =  normrnd(0, shadowFadingStdDev, size(FSPL));
    nodesPower = params.leoRxGain + params.nodesTxEIRP - FSPL - shadowFading;
    
    if (plotsFlag)
        figure(2); clf;
        [~,~] = cdfplot(nodesPower);
        xlabel('Received power (dBm)');
        title('Recived power at LEO - CDF')
        xline(params.loraSensitivity,'-',{ sprintf('Sensitivity: %0.f dBm',params.loraSensitivity), sprintf('SF: %0.f',params.loraSF) },'color','#77AC30','linewidth',2);
        set(findall(gca, 'Type', 'Line'),'LineWidth',2);
        set(gca,'fontsize', 18);
        movegui('north')

        figure(3); clf;
        [~,~] = cdfplot(shadowFading);
        xlabel('Shadow fading (dB)');
        title('Shadow fading - CDF')
        set(findall(gca, 'Type', 'Line'),'LineWidth',2);
        set(gca,'fontsize', 18);
        movegui('northeast')
    end
end
