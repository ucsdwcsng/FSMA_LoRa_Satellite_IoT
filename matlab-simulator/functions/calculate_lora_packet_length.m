function packet_length = calculate_lora_packet_length(payload_size_bytes_in, params)
    % implementation reference: https://cdn.sparkfun.com/assets/7/7/3/2/2/SX1276_Datasheet.pdf;

    % params
    payload_size_bytes = double(payload_size_bytes_in);% input typically is in uint8 format
    spreading_factor = params.loraSF;
    coding_rate = params.loraCodeRateType; 
    bandwidth = params.loraBW; 
    preamble_length = params.loraPreambleSyms;
    implicit_header_mode = params.loraImplicitHeaderMode;  
    low_data_rate_optimize = params.loraLowDatarateOptimize;  % 0 for off, 1 for on (should be on if SF = 11 or 12 and BW = 125)
    crc_on = params.loraCRC;  % 0 for off, 1 for on

    % Calculate symbol time
    Tsym = (2^spreading_factor) / bandwidth;

    % Calculate preamble time
    Tpreamble = (preamble_length + 4.25) * Tsym;

    % Calculate payload symbol number
    payload_symbol_num = 8 + max(ceil((8*payload_size_bytes - 4*spreading_factor + 28 + 16*crc_on - 20*implicit_header_mode) / (4*(spreading_factor - 2*low_data_rate_optimize))) * (coding_rate + 4), 0);

%     if implicit_header_mode == 0
%         payload_symbol_num = 8 + max(ceil((8*payload_size_bytes - 4*spreading_factor + 28 + 16*crc_on - 20*implicit_header_mode) / (4*(spreading_factor - 2*low_data_rate_optimize))) * (coding_rate + 4), 0);
%     else
%         payload_symbol_num = 8 + ceil((8*payload_size_bytes - 4*spreading_factor + 8*crc_on - 20*implicit_header_mode) / (4*(spreading_factor - 2*low_data_rate_optimize))) * (coding_rate + 4);
%     end

    % Calculate payload time
    Tpayload = payload_symbol_num * Tsym;

    % Calculate total packet time
    packet_length = Tpreamble + Tpayload;
end
