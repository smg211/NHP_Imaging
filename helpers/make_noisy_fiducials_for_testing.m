function make_noisy_fiducials_for_testing(noise)

% load a file 
[filename, path] = uigetfile('*.mat');

data = load([path filename]); 

% go through and add a bit of noise, then resave to test file
nFids = length(data.mri_fiducials); 
stereotax_fiducials = data.mri_fiducials; 

for i = 1:nFids
    coords = data.mri_fiducials{i}{2}; 
    coords_noisy = coords + noise*randn(1,3); 
    stereotax_fiducials{i}{2} = coords_noisy;
end

strnum = strfind(filename, '_fiducials'); 
stx_name = 'test';
fiducials_filename = [path filename(1:strnum) 'stereotax' stx_name '.mat'];
stereotax_name = stx_name;
save(fiducials_filename, 'stereotax_fiducials', 'stereotax_name');
