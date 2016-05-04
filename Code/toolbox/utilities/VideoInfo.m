classdef VideoInfo < handle
    % Holds information about video files. Most importantly this object
    % provides direct access to
    %   - duration of the video,
    %   - frame rate, and
    %   - video resolution.
    %
    % This object holds VideoStreamInfo objects in its stream attribute.
    % A VideoStreamInfo object contains in its codec attribute either a
    % VideoCodecInfo object or AudioCodecInfo object.
    %
    %
    %   Florian Raudies, 01/16/2016, Palo Alto, CA.
    
    properties
        fileName            % Name of the video file with path.
        meta                % Meta information about the video.
        duration            % Duration of the video in seconds.
        start               % Start point of the video. Usually 0.
        bitrate             % Bitrate in kb/s.
        stream              % Information about the steams (video/audio).
    end
    
    properties (SetAccess = private)
        iStreamForVideo     % Index of the video stream.  
    end
    
    methods
        function obj = VideoInfo(info)
            % Constructor.
            % Expects the structure 'info' to contain the following fields:
            %   - fileName
            %   - meta
            %   - start
            %   - bitrate
            %   - stream
            %
            obj.fileName        = info.fileName;
            obj.meta            = info.meta;
            obj.duration        = info.duration;
            obj.start           = info.start;
            obj.bitrate         = info.bitrate;
            nStream             = length(info.stream);
            s(nStream)          = VideoStreamInfo();
            for iStream = 1:nStream,
               s(iStream) = VideoStreamInfo(info.stream(iStream));
            end
            obj.stream = s;
            obj.iStreamForVideo = -1;
            for iStream = 1:nStream,
                if strcmp(obj.stream(iStream).type,'video'),
                    obj.iStreamForVideo = iStream;
                    break;
                end
            end

        end
        function fileName = getFileName(obj)
            % Returns the filename with path.
            fileName = obj.fileName;
        end
        function d = getDuration(obj)
            % Returns the duration of the video file in seconds.
            d = obj.duration;
        end
        function R = getResolution(obj)
            % Returns the video resolution as row vector [widht, height].
            R = [0 0];
            if obj.iStreamForVideo~=-1,
                R = obj.stream(obj.iStreamForVideo).codec.Size;     
            end
        end
        function fps = getFramesPerSecond(obj)
            % Returns the frame rate in frames per second.
            fps = 0;
            if obj.iStreamForVideo~=-1,
                fps = obj.stream(obj.iStreamForVideo).codec.fps;
            end
        end
    end
end