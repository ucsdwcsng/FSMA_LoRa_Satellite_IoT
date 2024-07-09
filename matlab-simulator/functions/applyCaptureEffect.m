function [packetData_filt, MAC_params] = applyCaptureEffect(packetData, params, MAC_params, nodesPower, packetLengthBins)
    %CAPTU Summary of this function goes here
    %   Detailed explanation goes here
    
    %params.loraSymTimeBin
    % MAC_params.lock_status = 'F';% F-free, S-sensing, B-busy
    % MAC_params.lockedNode = 0;
    % MAC_params.lock_timer = 0; 
    

    receivedPacketsInLastBin = packetData(:,MAC_params.currentBin);
    activeNodes = find(receivedPacketsInLastBin>0);
    packetData_filt = zeros(size(packetData)); 


    if(~isempty(activeNodes))
        activePowerValues = nodesPower(activeNodes); % Find the maximum power value among the active nodes 
        [max_power, idx] = max(activePowerValues); % Find the corresponding node number with the maximum power 
        nodeWithMaxPower = activeNodes(idx);
        minAddPower_dB = 1;

        %% mode change
        if strcmpi(MAC_params.lock_status, 'F') % trigger sense
            if (receivedPacketsInLastBin(nodeWithMaxPower) > 10*params.loraSymTimeBin)
                return
            end

            MAC_params.lockedNode = nodeWithMaxPower;
            MAC_params.lock_status = 'S';
            MAC_params.lock_timer = 0;
            MAC_params.collision_free_bins = 1;
            MAC_params.exit_timer_bins = packetLengthBins(nodeWithMaxPower);
            

        
        elseif strcmpi(MAC_params.lock_status, 'S') % lock node
            MAC_params.collision_free_bins = MAC_params.collision_free_bins + 1;
            if (MAC_params.lock_timer > 4*params.loraSymTimeBin)
                MAC_params.lock_status = 'B';
                MAC_params.lockedNode = nodeWithMaxPower; % change locked node
            end

        elseif strcmpi(MAC_params.lock_status, 'B') % look for collisions
            if ((nodeWithMaxPower ~= MAC_params.lockedNode) && (max_power > nodesPower(MAC_params.lockedNode) + minAddPower_dB))
                %collision_occured
                MAC_params.collision_free_bins = 0;
            else
                MAC_params.collision_free_bins = MAC_params.collision_free_bins + 1;
            end
        else
            error('MAC_params.lock_status should be either of F-free, S-sense or B-busy, instead given %c', MAC_params.lock_status);
        end

        %% sensing or busy mode validity check

        MAC_params.lock_timer = MAC_params.lock_timer+1;
        % if ((nodeWithMaxPower ~= MAC_params.lockedNode) && (max_power > nodesPower(MAC_params.lockedNode) + minAddPower_dB))
        %         MAC_params.last_ncorrupt_bins = MAC_params.last_ncorrupt_bins + 1;
        %         packetData(:,MAC_params.currentBin-MAC_params.last_ncorrupt_bins+1:MAC_params.currentBin) = 0;
        % elseif (length(activeNodes) > 1)
        %         MAC_params.last_ncorrupt_bins = MAC_params.last_ncorrupt_bins + 1;
        %         otherNodeIndices = (1:length(receivedPacketsInLastBin)) ~= MAC_params.lockedNode;
        %         packetData(otherNodeIndices,MAC_params.currentBin-MAC_params.last_ncorrupt_bins+1:MAC_params.currentBin) = 0;
        % end
    end

    %% exit check - release lock
    if ((MAC_params.lock_timer >= MAC_params.exit_timer_bins) || isempty(activeNodes))
        % updated rx matrix
        if (MAC_params.collision_free_bins > 0)
            packetData_filt(MAC_params.lockedNode,MAC_params.currentBin-MAC_params.collision_free_bins+1:MAC_params.currentBin) = (1:MAC_params.collision_free_bins);
        end

        MAC_params.lock_status = 'F';
        MAC_params.lockedNode = 0;
        MAC_params.lock_timer = 0;
        MAC_params.collision_free_bins = 0;


    end
 
    %% making sure to avoid multiple active nodes
    if (nnz(packetData_filt(:,MAC_params.currentBin)>0) > 1)
        % disp(packetData_filt)
    end

    

    %% packet check


end