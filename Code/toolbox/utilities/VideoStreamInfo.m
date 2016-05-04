classdef VideoStreamInfo < handle
    % Holds information about video streams.
    %
    %   Florian Raudies, 01/16/2016, Palo Alto, CA.    
    properties
        id          % Identifier of the video stream.
        language    % Language of this stream.
        type        % Type either video or audio.
        codec       % Codec used to encode the stream.
    end
    methods
        function obj = VideoStreamInfo(info)
            % Constructor.
            % The structure info is optional.
            % If it is present the following fields are expected:
            %   - id
            %   - language
            %   - type
            %   - codec
            %
            if nargin<1, return; end
            obj.id = info.id;
            obj.language = info.language;
            obj.type = lower(info.type); 
            if strcmp(obj.type, 'video'),
                obj.codec   = VideoCodecInfo(info.codec);
            elseif strcmp(obj.type, 'audio'),
                obj.codec   = AudioCodecInfo(info.codec);
            else
                obj.codec   = [];
            end
        end
    end
end
