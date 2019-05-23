classdef root
    methods
        function h = root()
            global rootdirectory;
            cd(rootdirectory);
        end
    end
    methods (Static)
        function set()
            global rootdirectory;
            rootdirectory = pwd;
        end
        function h = get()
            global rootdirectory;
            h = rootdirectory;
        end
    end
end