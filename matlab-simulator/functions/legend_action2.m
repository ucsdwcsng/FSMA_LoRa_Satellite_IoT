% This function is to highlight/blink plots by clicking legend
% Source: https://blogs.mathworks.com/pick/2016/03/25/interactive-legend-in-r2016a/?doing_wp_cron=1640736007.1837210655212402343750

function legend_action2(src,event)
% This callback function makes the plot to "blink"

  for id = 1:4                        % Repeat 4 times
      event.Peer.LineWidth = 4;       % Set line width to 4
      pause(0.2)                      % Pause 0.2 seconds
      event.Peer.LineWidth = 0.5;     % Set line width to 0.5
      pause(0.2)                      % Pause 0.2 seconds
  end
end