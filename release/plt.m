%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %%                     'EXTENDED' PLOT FUNCTION                       %%
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %                                                                      %
%    %    Author: Frederic Depuydt                                          %
%    %    Company: KU Leuven                                                %
%    %    Contact: frederic.depuydt@kuleuven.be; f.depuydt@outlook.com      %
%    %    Version: 1.0                                                      %
%    %                                                                      %
%    %    A function that will plot X and Y data when executed.             %
%    %    This function extends the native MATLAB plot with extra           %
%    %    parameters.                                                       %
%    %                                                                      %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %        FUNCTION (non-static)                                         %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %                                                                      %
%    %    plt(                    'Extended' Plot function                  %
%    %        X,                      Values (X axis)                       %
%    %        Y,                      Values (Y axis)                       %
%    %        parameter,              A certain parameter                   %
%    %        value,                  Value for the parameter               %
%    %        ...)                                                          %
%    %                                                                      %
%    %        Possible parameters:                                          %
%    %                                                                      %
%    %            'type'              The type of plot                      %
%    %                values:                                               %
%    %                    'plot'          plot style (default)              %
%    %                    'stairs'        stairs style                      %
%    %                    'stem'          stem style                        %
%    %                                                                      %
%    %            'downsample'        Reduce number of plotted values       %
%    %                value:          Integer that represents the # samples %
%    %                                                                      %
%    %            'range'             Limit the plotted range               %
%    %                values:                                               %
%    %                    [Xmin, Xmax]                                      %
%    %                                                                      %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %        Examples                                                      %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    %                                                                      %
%    %            plt(X,Y,'downsample',10000);                              %
%    %            plt(X,Y,'range',[0 10]);                                  %
%    %            plt(X,Y,'type','stairs');                                 %
%    %            plt(X,Y,'downsample',1000,'range',[0 100]);               %
%    %                                                                      %
%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%
