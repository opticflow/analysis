classdef CodecInfo < handle
    % Codec informatino contains name, descrition, and display attributes.
    %
    %   Florian Raudies, 01/16/2016, Palo Alto, CA.
    properties
        name            % Name of the codec.
        description     % Description of the codec.
        displays        % Display type of the codec.
    end
    methods
        function obj = CodecInfo(info)
            % Constructor.
            % Expects the structure info to contain the following fields:
            %   - name
            %   - description
            %   - displays
            %
            obj.name            = info.name;
            obj.description     = info.description;
            obj.displays        = info.displays;            
        end
    end
end