classdef VideoCodecInfo < CodecInfo
    % Holds information about the video codec.
    %   For the description of the tbr, tbn, tbc see also:
    %   http://ffmpeg-users.933282.n4.nabble.com/What-does-the-output-of-ffmpeg-mean-tbr-tbn-tbc-etc-td941538.html
    %
    %   Florian Raudies, 01/16/2016, Palo Alto, CA.
    properties
        pixelFormat     % Pixel format.
        bitsPerChannel  % Bits per channel.
        Size            % Size of the video image as row [width, height]
        aspectRatios    % Aspect ratios.
        quality         % Quality of the codec.
        bitrate         % Bitrate of the codec.
        fps             % Frames per second of the codec.
        tbr             % Video frame rate or 2 x frame rate.
        tbn             % Time base in AVStream from the container.
        tbc             % Time base in AVCodecContext.
    end
    methods
        function obj = VideoCodecInfo(info)
            % Constructor.
            % This constructor expects the sturcutre with the fields:
            %   - pixelFormat
            %   - bitsPerChannel
            %   - Size
            %   - apsectRatios
            %   - quality
            %   - fps
            %   - tbr
            %   - tbn
            %   - tbc
            obj                 = obj@CodecInfo(info);
            obj.pixelFormat     = info.pixelFormat;
            obj.bitsPerChannel  = info.bitsPerChannel;
            obj.Size            = info.Size;
            obj.aspectRatios    = info.aspectRatios;
            obj.quality         = info.quality;
            obj.bitrate         = info.bitrate;
            obj.fps             = info.fps;
            obj.tbr             = info.tbr;
            obj.tbn             = info.tbn;
            obj.tbc             = info.tbc;
        end
    end
end