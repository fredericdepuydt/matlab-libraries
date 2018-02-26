classdef satellite
    properties
        id, ...
            location, ...
            velocity, ...
            mass, ...
            diameter
    end
methods
    function obj = satellite(num,location,velocity,mass,diameter)
        obj.id = num;
        obj.location = location;
        obj.velocity = velocity;
        obj.mass = mass;
        obj.diameter = diameter;
    end
end
methods (Static)
    
end
end