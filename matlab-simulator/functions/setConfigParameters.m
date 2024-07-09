function [config] = setConfigParameters(type, CADdistanceLimit, enablePropagationDelays, enableDetectionDelay)
    
    if (nargin < 4)
        enableDetectionDelay = true;
    end

    if (nargin < 3)
        enablePropagationDelays = true;
    end

    if (nargin < 2)
        CADdistanceLimit = 3000e3;
    end

    % Conver inputType to lower case for case insensitive comparison
    inputType = lower(type);

    % Switch between cases
    switch inputType
        case 'fsma'
            disp('Type: FSMA');

        case 'csma'
            disp('Type: CSMA');
            if nargin < 2
                warning('Distance not provided, using default distance of 3000e3 meters for CSMA.');
            end

        case 'aloha'
            disp('Type: ALOHA');

        otherwise
            disp('Error: Please provide a correct type from the list (FSMA, CSMA, ALOHA).');
    end


    config.type = type;
    config.CADdistanceLimit = CADdistanceLimit;
    config.enablePropagationDelays = enablePropagationDelays;
    config.enableDetectionDelay = enableDetectionDelay;
    
end