clc; clear all; close all;
% This tests the function loadAnnotation by comparing data from file with
% the hard-coded data within this script.
%   Florian Raudies, 01/28/2016, Palo Alto, CA.

% *************************************************************************
iTestCase = 1;
testCase(iTestCase).inFile = '../../../Data/AnnotationSamples/009SS_05.csv';
testCase(iTestCase).formatString = '%d%d%d%s%d';
testCase(iTestCase).FieldNamesShouldBe = {'loco.ordinal','loco.onset',...
    'loco.offset', 'loco.code01', 'cell length'};
testCase(iTestCase).('loco_ordinal')  = [0;       1;      2];
testCase(iTestCase).('loco_onset')    = [0;       20186;  87188];
testCase(iTestCase).('loco_offset')   = [20185;   87187;  104323];
testCase(iTestCase).('loco_code01')   = {'s';     'm';    's'};
testCase(iTestCase).('cell_length')   = [20185;   67001;  17135];
% *************************************************************************
iTestCase = iTestCase + 1;
testCase(iTestCase).inFile = '../../../Data/AnnotationSamples/024KAI_03.csv';
testCase(iTestCase).formatString = '%d%d%d%s';
testCase(iTestCase).FieldNamesShouldBe = {'loco.ordinal','loco.onset',...
    'loco.offset', 'loco.locomotion'};
testCase(iTestCase).('loco_ordinal')    = [0;       1;      2];
testCase(iTestCase).('loco_onset')      = [0;       11526;  187202];
testCase(iTestCase).('loco_offset')     = [11525;   187201; 193742];
testCase(iTestCase).('loco_locomotion') = {'"_"';   '"s"';  '"m"'};

nTestCase       = length(testCase);
nPassed         = 0;
nFailed         = 0;
for iTestCase = 1:nTestCase,
    fprintf('Working on %d test case of %d test case(s).\n', iTestCase, nTestCase);
    inFile              = testCase(iTestCase).inFile;
    formatString        = testCase(iTestCase).formatString;
    FieldNamesShouldBe  = testCase(iTestCase).FieldNamesShouldBe;
    FieldNamesShouldBe  = strrep(strrep(FieldNamesShouldBe,'.','_'),' ','_');    
    info                = loadAnnotation(inFile, formatString);
    FieldNamesIs        = fieldnames(info);
    nFieldNamesShouldBe = length(FieldNamesShouldBe);
    nFieldNamesIs       = length(FieldNamesIs);
    passed  = nFieldNamesShouldBe == nFieldNamesIs;
    if ~passed,
        fprintf('  Found %d field names but expected %d field names.\n',...
            nFieldNamesIs, nFieldNamesShouldBe);
    end
    for iFieldNames = 1:min(nFieldNamesIs, nFieldNamesShouldBe),
        fieldNamesIs        = FieldNamesIs{iFieldNames};
        fieldNamesShouldBe  = FieldNamesShouldBe{iFieldNames};
        passed = all(fieldNamesIs == fieldNamesShouldBe);
        if ~passed,
            fprintf('  Found %s field name but expected %s field name.\n',...
                fieldNamesIs, fieldNamesShouldBe);
        end
        DataShouldBe = testCase(iTestCase).(fieldNamesShouldBe);
        nData = length(DataShouldBe);
        DataIs = info.(fieldNamesIs)(1:nData);
        if iscell(DataShouldBe) && iscell(DataIs),
            passed = all(cellfun(@strcmp, DataShouldBe, DataIs));
        else
            passed = all(DataShouldBe == DataIs);
        end
        if ~passed,
            fprintf('  Found missmatch in data.\n');
        end
    end
    if passed,
        nPassed = nPassed + 1;
    else
        nFailed = nFailed + 1;
    end
end
fprintf('%d tests passed and %d tests failed.\n',nPassed,nFailed);
assert(nFailed==0,'%d tests failed.\n',nFailed);

% ALL PASSED 01/28/2016 FR