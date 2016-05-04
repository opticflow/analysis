clc; clear all; close all;
% Example for the method loadAnnotation.
%   Florian Raudies, 01/27/2016, Palo Alto, CA.

formatString    = '%d%d%d%s%d';
inFile          = '../Data/AnnotationSamples/036MR_11.csv';
info            = loadAnnotation(inFile, formatString);
Names           = fieldnames(info);
nNames          = length(Names);

fprintf('The file %s has the following fields:\n', inFile);
for iName = 1:nNames,
    name = Names{iName};
    data = info.(name);
    fprintf(' %s with type %s and %d values.\n', ...
        name, formatString(2*iName), length(data));
end