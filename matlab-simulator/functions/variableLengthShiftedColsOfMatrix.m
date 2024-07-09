function [A] = variableLengthShiftedColsOfMatrix(A, shift_vals)
%     A_Fields = whos("A");
%     rows = A_Fields.size(1);
%     cols = A_Fields.size(2);
%     type = A_Fields.class;
% 
% %     if (length(shift_vals) ~= rows)
% %         error("shift_vals array doesn't have equal elements as number of rows of given matrix")
% %     end
% 
%     shifted_A = zeros(rows,cols,type);
%     for row_ind = 1:rows
%         shifted_A(row_ind, shift_vals(row_ind)+1:end) = A(row_ind, 1:end-shift_vals(row_ind));
%     end

    [rows, ~] = size(A);
    for row_ind = 1:rows
        A(row_ind, :) = circshift(A(row_ind,:), shift_vals(row_ind));
        A(row_ind, 1:shift_vals(row_ind)) = 0;
    end
end

