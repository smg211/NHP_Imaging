function save_surface(mesh, nm, subsurfdir)
    subcortex = []; 
    subcortex.pos = mesh.pos; 
    subcortex.tri = mesh.tri;
             
     % Critical to include unit in the mesh -- else the
     % write_headshape code will try to scale it to be head-sized
     % and thus assume CM; 
     subcortex.unit = mesh.unit; 
     ft_write_headshape([subsurfdir filesep nm '.gii'], subcortex, 'format', 'gifti', 'unit', mesh.unit);
     ft_write_headshape([subsurfdir filesep nm '.stl'], subcortex, 'format', 'stl', 'unit', mesh.unit);
end