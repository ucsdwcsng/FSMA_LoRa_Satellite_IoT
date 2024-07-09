% This function is to toggle (make visible or hide) plots by clicking legend
% Source: https://blogs.mathworks.com/pick/2016/03/25/interactive-legend-in-r2016a/?doing_wp_cron=1640736007.1837210655212402343750

function legend_action1(src,event)
% This callback function is used to toggle the visibility of the plots

  if strcmp(event.Peer.Visible,'on')   % If current line is visible
      event.Peer.Visible = 'off';      %   Set the visibility to 'off'
  else                                 % Else
      event.Peer.Visible = 'on';       %   Set the visibility to 'on'
  end
end