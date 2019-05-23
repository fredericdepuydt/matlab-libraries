%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %%                            COLOR CLASS                             %%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    Author: Frederic Depuydt                                          %
%  %    Company: KU Leuven                                                %
%  %    Contact: frederic.depuydt@kuleuven.be; f.depuydt@outlook.com      %
%  %    Version: 1.0                                                      %
%  %                                                                      %
%  %    A Color class to easily apply colors to plots                     %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %        PROPERTIES                                                    %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    usage: result = color.property                                    %
%  %                                                                      %
%  %    ch1                     Returning the color of scope channel 1    %
%  %    ch2                     Returning the color of scope channel 2    %
%  %    ch3                     Returning the color of scope channel 3    %
%  %    ch4                     Returning the color of scope channel 4    %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %        FUNCTIONS (static)                 *Object creation*          %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    usage: objColor = color.function(var1, var2, ...)                 %
%  %                                                                      %
%  %    PROFIBUS()              Returns PROFIBUS color                    %
%  %    PROFIBUS('m')           Returns PROFIBUS color for a MarkerFace   %
%  %                                                                      %
%  %    PROFINET()              Returns PROFINET color                    %
%  %    PROFINET('m')           Returns PROFINET color for a MarkerFace   %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef color
    properties  (Constant)
        ch1 = struct('color',[240,180,000]/256);
        ch2 = struct('color',[030,144,255]/256);
        ch3 = struct('color',[199,021,133]/256);
        ch4 = struct('color',[034,139,034]/256);
        lightgrey = struct('color',[180 180 180]/256);
        lightpurple = struct('color',[220 120 255]/256);
    end
    methods (Static)
        function obj = PROFIBUS(varargin)
            if isempty(varargin)
                obj = struct('color',[76 0 153]/256);
            else                
                while ~isempty(varargin)
                    if(ischar(varargin{1}))
                        switch lower(varargin{1})
                            case 'm'
                                obj = struct('MarkerFaceColor',[76 0 153]/256);
                        end
                    end
                    varargin(1) = [];
                end
            end
        end
        function obj = PROFINET(varargin)
            if isempty(varargin)
                obj = struct('color',[124 213 45]/256);
            else                
                while ~isempty(varargin)
                    if(ischar(varargin{1}))
                        switch lower(varargin{1})
                            case 'm'
                                obj = struct('MarkerFaceColor',[124 213 45]/256);
                        end
                    end
                   varargin(1) = [];
                end
            end
        end
    end
end
