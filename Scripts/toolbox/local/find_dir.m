function str = find_dir(prefix, suffix)
	for i=1:length(prefix)
		if(exist([char(prefix{i}) char(suffix)], 'dir'))
			str = [char(prefix{i}) char(suffix)];
			return;
		end
	end
	error(['No MATLAB Projects directory found: ' char(prefix{i}) char(suffix)])
end

