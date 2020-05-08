function s = objtostruct(obj)
    % Converts objects to structure.
    %
    % This routine is necessary since many of the NR routines are poorly
    % written and use structures and not classes.  
    
    % If the object is already a structure, then just copy it.
    if isstruct(obj)
        s = obj;
        return
    end        
    
    % Copy the properties
    prop = properties(obj);
    nprop = length(prop);
    s = struct();
    for i = 1:nprop
        s.(prop{i}) = obj.(prop{i});
    end
end