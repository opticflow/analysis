function videoInfo = getVideoInfo(inFile)
% getVideoInfo
%   inFile      - Input filename.
%
% RETURN
%   videoInfo   - Object with information about the video stream. Some
%                 arguments, like frame rate, video resolution, and
%                 duration are directly accessible.
%
% DESCRIPTION
%   Uses the system installed program 'ffprobe' that need to be part of the
%   path to pull information about the video file.
%

%   Florian Raudies, 01/16/2016, Palo Alto, CA.

if ~exist(inFile,'file'),
    error('Unable to open %s.\n', inFile);
end

[status, msg] = system(['ffprobe ', inFile]);
if status,
    error('Unable to get info for file %s.\n',inFile);
end

info = regexp(msg,['Input #\d+, (?<format>.*?), from ''(?<fileName>.+?)?'':\n'...
      '(?<meta>  Metadata:\n.*?\n)?'...
      '  Duration: (?<duration>(\d+:\d+:\d+\.\d+)|(N/A))'...
      ', start: (?<start>\d+\.\d+)?'...
      ', bitrate: (?<bitrate>(-?\d+ kb/s)|(N/A))\n'...
      '(?<data>.*)'],'names');

if strcmp(info.duration,'N/A'), info.duration = [];
else                            info.duration = [60*60 60 1]*sscanf(...
        info.duration,'%d:%d:%f'); % sec
end
if isempty(info.start),         info.start = [];
else                            info.start = sscanf(info.start, '%f'); end
if strcmp(info.bitrate, 'N/A'), info.bitrate = [];
else                            info.bitrate = sscanf(...
        info.bitrate,'%d kb/s')*1000; % b/s
end

% Parse streams.
Index = regexp(info.data,{'Stream','Metadata'}, 'start');

% If there are any streams present.
if ~isempty(Index{1}),
    IndexStart = [Index{1} length(info.data)];    
    nStream = length(Index{1});
    % Parse each stream, one at a time.
    for iStream = 1:nStream,
        info.stream(iStream) = regexp(...
            strtrim(info.data(IndexStart(iStream):IndexStart(iStream+1)-1)),...
            ['Stream #\d+:(?<id>\d+)' ...
             '(?<language>\(.+?\))?:' ...
             ' (?<type>[^:]+): (?<codec>[^\n]+\n)(?<meta>    Metadata:.*\n)?'],...
             'names');
    end
end

% Parse the codec information within each stream.
for iStream = 1:nStream,
    type        = lower(info.stream(iStream).type);
    valueStr    = info.stream(iStream).codec;
    switch type
        case 'video'
            info.stream(iStream).codec = parseVideoCodecInfo(valueStr);
        case 'audio'
            info.stream(iStream).codec = parseAudioCodecInfo(valueStr);
        otherwise
            fprintf('Unknown stream type %s.\n',type);
    end                                          
end

% Construct an object hierarchy for the video information.
videoInfo = VideoInfo(info);



function info = parseVideoCodecInfo(strValue)
    % This function parses the information about the video codec. Most
    % importantly, this information contains the frame rate and video 
    % resolution. 
    % An example string is:
    % h264 (Main) (avc1 / 0x31637661), yuv420p, 1280x720 [SAR 1:1 DAR 16:9], 
    % 16042 kb/s, 59.94 fps, 59.94 tbr, 90k tbn, 119.88 tbc (default)
    %
    % I added the line break for readability. It is not present in the 
    % original string.

    % Parse the input string.
    info = regexp(strValue,['(?<name>.+?)'...
                            '(?<description> \(.+?\))?'...
                            '(?<pixelFormat>, [^\s\d][^,]+))?'...
                            '(?<bitsPerChannel> \(\d+ bpc\))?'...
                            '(?<Size>, \d+x\d+)?'...
                            '(?<aspectRatios> \[SAR \d+:\d+ DAR \d+:\d+\])?'...
                            '(?<quality>, q=\d+:\d+)?'...
                            '(?<bitrate>, \d+ kb/s)?'...
                            '(?<aspectRatios>, SAR \d+:\d+ DAR \d+:\d+)?'...
                            '(?<fps>, [\d\.]+k? fps)?'...
                            '(?<tbr>, [\d\.]+k? tbr)?'...
                            '(?<tbn>, [\d\.]+k? tbn)?'...
                            '(?<tbc>, [\d\.]+k? tbc)?'...
                            '(?<displays> \(.*\))?'], 'names', 'once');
    if isempty(info)
        info = strValue;
        return;
    end
    if isempty(info.description),   info.description = {};
    else                            info.description = cellfun(@(c)c{1},...
            regexp(info.description, ' \((.+?)\)','tokens'),'UniformOutput',false); 
    end
    if isempty(info.pixelFormat),   info.pixelFormat = [];
    else                            info.pixelFormat = sscanf(', %s',info.pixelFormat); end
    if isempty(info.bitsPerChannel),info.bitsPerChannel = [];
    else                            info.bpc = sscanf(info.bpc, ' (%d bpc)'); end
    if isempty(info.Size),          info.Size = [];
    else                            info.Size = sscanf(info.Size, ', %dx%d')'; end
    if isempty(info.quality),       info.quality = [];
    else                            info.quality = sscanf(info.quality, ', q=%d-%d')'; end
    if isempty(info.bitrate),       info.bitrate = [];
    else                            info.bitrate = sscanf(info.bitrate, ', %d kb/s')*1000; end
    if isempty(info.aspectRatios),  info.aspectRatios = struct('SAR', [], 'DAR', []);
    else
        if info.aspectRatios(1)==' '
           ratios = sscanf(info.aspectRatios,' [SAR %d:%d DAR %d:%d]');
        else
           ratios = sscanf(info.aspectRatios,', SAR %d:%d DAR %d:%d');
        end
        info.aspectRatios = struct('SAR',ratios(1:2).','DAR',ratios(3:4).');
    end
    if isempty(info.fps),           info.fps = [];
    else                            info.fps = parseRate(info.fps, 'fps'); end
    if isempty(info.tbr),           info.tbr = [];
    else                            info.tbr = parseRate(info.tbr, 'tbr'); end
    if isempty(info.tbn),           info.tbn = [];
    else                            info.tbn = parseRate(info.tbn, 'tbn'); end
    if isempty(info.tbc),           info.tbc = [];
    else                            info.tbc = parseRate(info.tbc, 'tbc'); end
    if isempty(info.displays),      info.displays = {};
    else                            info.displays = cellfun(@(c)c{1},...
            regexp(info.displays,' \((.+?)\)','tokens'),'UniformOutput',false);
    end

function rate = parseRate(valueStr, rateName)
    % This method parses the rate values for the rateName.
    tokens = regexp(valueStr,[', ([\d\.]+)(k?) ' rateName], 'tokens', 'once');
    if isempty(tokens{2})
        rate = sscanf(tokens{1},['%f' rateName]);
    else
        rate = sscanf(tokens{1},['%f' rateName])*1000;
    end

    
function info = parseAudioCodecInfo(valueStr)
    % Parses the audio codec information using the value string as input.
    % An example is:
    % aac (LC) (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 128 kb/s (default)    
    info = regexp(valueStr,['(?<name>\w+)' ...
                            '(?<description>( \(.+?\))+)?' ...
                            '(?<sampleRate>, \d+ Hz)?' ...
                            '(?<channels>, [^,]+)?' ...
                            '(?<sampleFormat>, [^,]+)?' ...
                            '(?<aspectRatios>, SAR \d+:\d+ DAR \d+:\d+)?' ...
                            '(?<bitrate>, \d+ kb/s)?' ...
                            '(?<displays> \(.*\))?'],'names','once');
    if isempty(info)
        info = valueStr;
        return;
    end
    if isempty(info.description),   info.description = {};
    else                            info.description = cellfun(@(c)c{1},...
            regexp(info.description,' \((.+?)\)','tokens'),'UniformOutput',false);
    end
    info = rmfield(info,'aspectRatios');
    if isempty(info.sampleRate),    info.sampleRate = [];
    else                            info.sampleRate = sscanf(info.sampleRate, ', %d Hz'); end
    if isempty(info.channels),      info.channels = [];
    else                            info.channels = sscanf(info.channels, ', %s'); end
    if isempty(info.sampleFormat),  info.sampleFormat = [];
    else                            info.sampleFormat = sscanf(info.sampleFormat, ', %s'); end
    if isempty(info.bitrate),       info.bitrate = [];
    else                            info.bitrate = sscanf(info.bitrate, ', %d kb/s')*1000; end
    if isempty(info.displays),      info.displays = {};
    else                            info.displays = cellfun(@(c)c{1},...
            regexp(info.displays, ' \((.+?)\)','tokens'), 'UniformOutput',false);
    end

    
% This is an example of a full output message as provided by ffprobe.

% ffprobe version 2.8.4 Copyright (c) 2007-2015 the FFmpeg developers
%   built with gcc 4.8 (Ubuntu 4.8.4-2ubuntu1~14.04)
%   configuration: 
%   libavutil      54. 31.100 / 54. 31.100
%   libavcodec     56. 60.100 / 56. 60.100
%   libavformat    56. 40.101 / 56. 40.101
%   libavdevice    56.  4.100 / 56.  4.100
%   libavfilter     5. 40.101 /  5. 40.101
%   libswscale      3.  1.101 /  3.  1.101
%   libswresample   1.  2.101 /  1.  2.101
% Input #0, mov,mp4,m4a,3gp,3g2,mj2, from 'Walking.MP4':
%   Metadata:
%     major_brand     : avc1
%     minor_version   : 0
%     compatible_brands: avc1isom
%     creation_time   : 2016-05-23 23:30:14
%   Duration: 00:00:51.85, start: 0.000000, bitrate: 16190 kb/s
%     Stream #0:0(eng): Video: h264 (Main) (avc1 / 0x31637661), yuv420p, 1280x720 [SAR 1:1 DAR 16:9], 16042 kb/s, 59.94 fps, 59.94 tbr, 90k tbn, 119.88 tbc (default)
%     Metadata:
%       creation_time   : 2016-05-23 23:30:14
%       handler_name    :         GoPro AVC
%       encoder         : GoPro AVC encoder
%     Stream #0:1(eng): Audio: aac (LC) (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 128 kb/s (default)
%     Metadata:
%       creation_time   : 2016-05-23 23:30:14
%       handler_name    :         GoPro AAC
