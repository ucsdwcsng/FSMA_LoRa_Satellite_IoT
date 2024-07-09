% function to backoff and update arrival time
function MAC_params = backoffAndUpdateArrivalTime(MAC_params, node_index, timeBin_ind, backoff_bins)
    % get arrival time index
    arrivalTimeInd = find(MAC_params.packet_arrival_timeBins(node_index,:) == timeBin_ind);

    % if time bin already exists increment 1
    % Note: make sure backoff_bins value is incrementing and less than max int value
    backoff_bins = timeBin_ind + backoff_bins;
    while(find(ismember(MAC_params.packet_arrival_timeBins(node_index,:), backoff_bins),1))
        backoff_bins = backoff_bins + 1;
    end

    % change current time bin value to new backoff bin
    MAC_params.packet_arrival_timeBins(node_index,arrivalTimeInd) = backoff_bins;
end