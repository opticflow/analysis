function info = loadAnnotation(inFile, formatString)
% loadAnnotation
%   inFile          - Input file name.
%   formatString    - Formatting of the data per row.
%
% RETURN
%   info            - Structure with GENERIC fields according to the header
%                     names in the CSV file. Each field has all row values
%                     for that name as data.
%
% DESCRIPTION
%   This loads annotations from CSV files. These files are assumed to have
%   the following format:
%
%   I. EXAMPLE:
%       loco.ordinal,loco.onset,loco.offset,loco.code01,cell length
%       0,0,66982,s,66982
%       1,66983,79555,m,12572
%       2,79556,122476,s,42920
%
%   II. EXAMPLE:
%       first name,surename,age,height
%       Hans,Baumgardner,66,165
%       Sven,Smith,34,170
%

%   Florian Raudies, 01/27/2016, Palo Alto, CA.

nField          = length(strfind(formatString,'%'));
headerString    = repmat('%s',[1 nField]);

fh = fopen(inFile);
if fh==-1, error('Matlab:IO', 'Cannot open file %s.!', inFile); end
field   = textscan(fh, headerString, 1, 'Delimiter', ',');
data    = textscan(fh, formatString, 'Delimiter', ',');
fclose(fh);

info = struct();
for iField = 1:nField,
    name = strrep(strrep(field{iField}{1},'.','_'),' ','_');
    info.(name) = data{iField};
end

