function arrival_times = possion_arrival_model(params, packet_length, nodes, total_time, duty_cycle)

    % duty cycle (0 to 1)
    if (nargin < 5)
        duty_cycle = 0.01;
    end
    
    % total time in seconds
    if (nargin < 4)
        total_time = 600; % 10 min 
    end
    
    % total nodes
    if (nargin < 3)
        nodes = 10;
    end
    
    % Packet_length
    if (nargin < 2)
        packet_length = ones(nodes,1);
    end

    arrival_times = cell(nodes,1);
    
    for node_ind = 1:nodes

        % Define the average arrival rate (lambda)
        lambda = duty_cycle/packet_length(node_ind); % packets per second
        
        % Generate a Poisson process (packet arrivals)
        N = poissrnd(lambda*total_time); % total number of packets
        if(params.fixNodePacketsFlag)
            N = params.fixNodePackets;
        end
        
        if(N>0)
            % generate unique time intervals
%             generatedArrivalTimes = randperm(ceil(total_time/params.loraSymTimeBin),N)*params.loraSymTimeBin;
%             arrival_times{node_ind} = unique(generatedArrivalTimes, 'sorted'); % random arrival times with atleast a gap of symbol time
            arrival_times{node_ind} = sort(total_time*rand(params.localStream,1,N)); % random arrival times
%             arrival_times{node_ind} = sort(floor((total_time/packet_length(node_ind))*rand(1,N))*packet_length(node_ind)); % random arrival times with atleast a gap of packet length
        else
            arrival_times{node_ind} = [];
        end
    
    end

    % Display the arrival times
%     disp(arrival_times);
end