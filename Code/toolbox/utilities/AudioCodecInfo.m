classdef AudioCodecInfo < CodecInfo
    % Holds the information about the audio codec.
    %
    %   Florian Raudies, 01/16/2016, Palo Alto, CA.
    properties
        sampleRate      % Sample rate in Hz.
        channels        % Number of channels (stereo/mono).
        sampleFormat    % Sampling format.
        bitrate         % Bitrate in kb/s.
    end
    methods
        function obj = AudioCodecInfo(info)
            % Constructor.
            % Expects the structure info with the fields:
            %   - sampleRate
            %   - channels
            %   - sampleFormat
            %   - bitrate
            obj                 = obj@CodecInfo(info);
            obj.sampleRate      = info.sampleRate;
            obj.channels        = info.channels;
            obj.sampleFormat    = info.sampleFormat;
            obj.bitrate         = info.bitrate;
        end
    end
end