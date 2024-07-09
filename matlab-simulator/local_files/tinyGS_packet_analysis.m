%
close all;
clc;
clearvars;

%% Station data
filename = 'TinyGS_table.xlsx';
stationData = readtable(filename);

% Display the updated table
disp(stationData);

%%
distances = stationData.Distance_km;
elevations_deg = stationData.Elevation_deg;
RSSI = stationData.RSSI_dBm;
SNR = stationData.SNR_dB;
doppler = stationData.Predicted_doppler_Hz;
frequency_error = stationData.Frequency_error_Hz;

time = datetime(stationData.Time,'ConvertFrom','excel','format','HH:mm:ss.SSS');
milliSecTime = (second(time)- floor(second(time)))*1000;
median_ms = median(milliSecTime);
milliSecTime(milliSecTime>median_ms+50) = NaN;
milliSecTime(milliSecTime<median_ms-50) = NaN;

[~,distance_sort_inds] = sort(distances);
[~,time_sort_inds] = sort(milliSecTime);


figure();
tiledlayout(2,3);
plotfigure(distances(distance_sort_inds),elevations_deg(distance_sort_inds), 'Distances (Km)', 'Elevation angle (deg)', 'Elevation angle captured', "north")
plotfigure(distances(distance_sort_inds),RSSI(distance_sort_inds), 'Distances (Km)', 'RSSI (dBm)', 'RSSI Received', "southwest")
plotfigure(distances(distance_sort_inds),doppler(distance_sort_inds)/1e3, 'Distances (Km)', 'Frequency (kHz)', 'Doppler', "northeast")
plotfigure(distances(distance_sort_inds),milliSecTime(distance_sort_inds), 'Distances (Km)', 'Time milliseconds', sprintf('Time captured: %s.xxx',datetime(time(1),'format','HH:mm:ss')), "northwest")
plotfigure(distances(distance_sort_inds),SNR(distance_sort_inds), 'Distances (Km)', 'SNR (dB)', 'SNR Received', "south")
plotfigure(distances(distance_sort_inds),frequency_error(distance_sort_inds)/1e3, 'Distances (Km)', 'Frequency (kHz)', 'Frequency Error', "southeast")

function plotfigure(x, y, xlabelStr, ylabelStr, titleStr, moveguiStr)
    if(nargin < 6)
        moveguiStr = "center";
    end
%     figId = figure;
%     figId.Position = [100, 100, 600, 400];
    nexttile
    hold on;
    plot(x, y);
    xlabel(xlabelStr)
    ylabel(ylabelStr)
    title(titleStr)
    grid on;
    set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
    set(gca,'fontsize', 18);
    movegui(moveguiStr);
end