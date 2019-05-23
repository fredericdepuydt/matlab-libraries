%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %%                           SCOPE CLASS                              %%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %                                                                      %
%   %    Author: Frederic Depuydt                                          %
%   %    Company: KU Leuven                                                %
%   %    Contact: frederic.depuydt@kuleuven.be; f.depuydt@outlook.com      %
%   %    Version: 1.3                                                      %
%   %                                                                      %
%   %    An Scope class to analyse scope signals                           %
%   %    Readable files: isf, csv                                          %
%   %                                                                      %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %        FUNCTIONS (static)                 *Object creation*          %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %                                                                      %
%   %    usage: objScope = scope.function(var1, var2, ...)                 %
%   %                                                                      %
%   %    csvread(                Reading scope signals from a CSV file     %
%   %        file,                   Filename + extension as String        %
%   %        channels,               Array of strings refering to channels %
%   %        verbose,                Integer to enable verbose mode        %
%   %        retime)                 Calculate more accurate timestamps    %
%   %                                                                      %
%   %    isfread(                Reading scope signals from an ISF file    %
%   %        file,                   Filename + extension as String        %
%   %        verbose)                Integer to enable verbose mode        %
%   %                                                                      %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %        FUNCTIONS (non-static)                                        %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %                                                                      %
%   %    usage: result = objScope.function(var1, var2, ...)                %
%   %    note: most functions do not alter the original scope object,      %
%   %          but return a new object with the function results           %
%   %                                                                      %
%   %    values(                 Returning the values of a channel         %
%   %        channels)               Array of strings refering to channels %
%   %            returns: matrix of the requested values                   %
%   %                                                                      %
%   %    split(                  Splitting 1 scope object into 2 (a and b) %
%   %        channels_a,             Array of strings refering to channels %
%   %        channels_b)             Array of strings refering to channels %
%   %            returns: [objScope1, objScope2]                           %
%   %                                                                      %
%   %    downsample(             Lowering the amount of sample rate        %
%   %        samples,                The new number of samples             %
%   %        verbose)                Integer to enable verbose mode        %
%   %            returns: downsampled scope object                         %
%   %                                                                      %
%   %    remove(                 Removing channels from a Scope object     %
%   %        channels,               Array of strings refering to channels %
%   %        verbose)                Integer to enable verbose mode        %
%   %            returns: scope object without the removed channels        %
%   %                                                                      %
%   %    noisefilter(            Filters noise from requested channels     %
%   %        values,                 The input values you want to filter   %
%   %        threshold,              Threshold value to be filtered        %
%   %        verbose)                Integer to enable verbose mode        %
%   %            returns: filtered output values                           %
%   %                                                                      %
%   %    bandstop(               Filtering by frequencybands               %
%   %        values,                 The input values you want to filter   %
%   %        freq,                   Array of frequentybands to be filtered%
%   %        verbose)                Integer to enable verbose mode        %
%   %            returns: filtered output values                           %
%   %                                                                      %
%   %    scale(                  Scaling values of the requested channels  %
%   %        channels,               Array of strings refering to channels %
%   %        target,                 Target value to which to scale to     %
%   %        verbose)                Integer to enable verbose mode        %
%   %            returns: nothing, results directly applied on scope object%
%   %                                                                      %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   %                                                                      %
%   %    VERBOSE MODE: (default=-1)                                        %
%   %        all static functions check for a verbose variable             %
%   %        to enable or disable display output to the console            %
%   %                                                                      %
%   %    verbose ==  0;  % Display output disabled                         %
%   %    verbose == -1;  % Display output enabled for all nested functions %
%   %    verbose ==  x;  % Display output enabled for x nested functions   %
%   %                                                                      %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%    Reference page in Doc Center
%       doc scope
%
%
