%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %%                     'EXTENDED' PLOT FUNCTION                       %%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    Author: Frederic Depuydt                                          %
%  %    Company: KU Leuven                                                %
%  %    Contact: frederic.depuydt@kuleuven.be; f.depuydt@outlook.com      %
%  %    Version: 1.0                                                      %
%  %                                                                      %
%  %    A function that will plot X and Y data when executed.             %
%  %    This function extends the native MATLAB plot with extra           %
%  %    parameters.                                                       %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %        FUNCTION (non-static)                                         %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %    plt(                    'Extended' Plot function                  %
%  %        X,                      Values (X axis)                       %
%  %        Y,                      Values (Y axis)                       %
%  %        parameter,              A certain parameter                   %
%  %        value,                  Value for the parameter               %
%  %        ...)                                                          %
%  %                                                                      %
%  %        Possible parameters:                                          %
%  %                                                                      %
%  %            'type'              The type of plot                      %
%  %                values:                                               %
%  %                    'plot'          plot style (default)              %
%  %                    'stairs'        stairs style                      %
%  %                    'stem'          stem style                        %
%  %                                                                      %
%  %            'downsample'        Reduce number of plotted values       %
%  %                value:          Integer that represents the # samples %
%  %                                                                      %
%  %            'range'             Limit the plotted range               %
%  %                values:                                               %
%  %                    [Xmin, Xmax]                                      %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %        Examples                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %                                                                      %
%  %            plt(X,Y,'downsample',10000);                              %
%  %            plt(X,Y,'range',[0 10]);                                  %
%  %            plt(X,Y,'type','stairs');                                 %
%  %            plt(X,Y,'downsample',1000,'range',[0 100]);               %
%  %                                                                      %
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  h = plt(X,Y,varargin)
%% Precheck
if(~exist('X','var'));error('Parameter X is missing!');end;
if(~exist('Y','var'));error('Parameter Y is missing!');end;
if(isempty(X));error('X is an empty matrix!');end;
if(isempty(Y));error('Y is an empty matrix!');end;
if(length(X)~=length(Y));error('X and Y are different lengths! \n Length X = %s \n Length Y = %s',num2str(length(X)),num2str(length(Y)));end;

%% Initialise
downsample = -1;
type = 'plot';
Xmin = 0;
Xmax = 0;

%% Reading arguments
sendargin = {};
k=1;
while ~isempty(varargin)
    if(isstruct(varargin{1}))
        var = varargin{1};
        fields = fieldnames(var);
        varargin(length(fields)*2+1:end+length(fields)*2-1)=varargin(2:end);
        for i = 1:numel(fields)
            varargin(i*2-1)=fields(i);
            varargin{i*2}=var.(char(fields(1)));
        end
    elseif(ischar(varargin{1}))
        switch lower(varargin{1})
            case 'type'
                type = varargin{2};
                varargin(1:2) = [];
            case 'downsample'
                downsample = varargin{2};
                varargin(1:2) = [];
            case 'range'
                Xmin = varargin{2}(1);
                Xmax = varargin{2}(2);
                varargin(1:2) = [];
            otherwise
                sendargin{k} = varargin{1}; %#ok<AGROW>
                k = k+1;
                varargin(1) = [];
        end
    else
        sendargin{k} = varargin{1}; %#ok<AGROW>
        k = k+1;
        varargin(1) = [];
    end
end

%% PART Xmin-Xmax
if(Xmin || Xmax)
    if(Xmin>=Xmax);error('Xmin is bigger or equal to Xmax! \n Xmin = %s \n Xmax = %s',num2str(Xmin),num2str(Xmax));end;
    L = length(X);
    X0 = find([X(end:-1:2) Xmin]<=Xmin,1);
    X1 = find([X(1:end-1) Xmax]>=Xmax,1);
    X = X((L+1-X0):X1);
    Y = Y((L+1-X0):X1);
end
%% Downsample
if(downsample~=-1)
    if(mod(downsample,1)~=0);warning('Downsampling non natural! \n Downsample = %s',num2str(downsample));downsample=round(downsample);end;
    if(downsample<2);warning('Downsampling under limit! \n Downsample = %s',num2str(downsample));downsample=2;end;
    if(downsample<=length(X))
        sx = (length(X)-1)/(downsample-1);
        mx = length(X);
        range = sx+1:sx:mx-sx;
        range = [1,round(range + rand(1,downsample-2)*sx-sx/2),mx];
        X = X(range);
        Y = Y(range);
    else
        warning('No downsampling needed! \n Sample length = %s \n Downsample = %s',num2str(length(X)),num2str(downsample));
    end
elseif(length(X)>100000)
    warning('Plotting %s samples! \nUse the "downsample" parameter.',num2str(length(X)));
end 
%% Plotting

switch(type)
    case 'plot'
        h = plot(X,Y,sendargin{:});
    case 'stairs'
        [stairsX,stairsY] = stairs(X,Y);
        h = plot(stairsX,stairsY,sendargin{:});
    case 'stem'
        h = stem(X,Y,sendargin{:});
    otherwise
        error('Unknown type: %s',type);
end
end