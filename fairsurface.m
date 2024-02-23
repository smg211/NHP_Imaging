function [pos1, tri1] = fairsurface(pos, tri, N)

% FAIRSURFACE modify the mesh in order to reduce overlong edges, and
% smooth out "rough" areas. This is a non-shrinking smoothing algorithm.
% The procedure uses an elastic model : At each vertex, the neighbouring
% triangles and vertices connected directly are used. Each edge is
% considered elastic and can be lengthened or shortened, depending
% on their length. Displacement are done in 3D, so that holes and
% bumps are attenuated.
%
% Use as
%   [pos, tri] = fairsurface(pos, tri, N);
% where N is the number of smoothing iterations.
%
% This implements:
%   G.Taubin, A signal processing approach to fair surface design, 1995

% This function corresponds to spm_eeg_inv_ElastM
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
%                    Christophe Phillips & Jeremie Mattout
% spm_eeg_inv_ElastM.m 1437 2008-04-17 10:34:39Z christophe
%
% $Id$

ts = [];
ts.XYZmm = pos';
ts.tri   = tri';
ts.nr(1) = size(pos,1);
ts.nr(2) = size(tri,1);

% Connection vertex-to-vertex
%--------------------------------------------------------------------------
M_con = sparse([ts.tri(1,:)';ts.tri(1,:)';ts.tri(2,:)';ts.tri(3,:)';ts.tri(2,:)';ts.tri(3,:)'], ...
  [ts.tri(2,:)';ts.tri(3,:)';ts.tri(1,:)';ts.tri(1,:)';ts.tri(3,:)';ts.tri(2,:)'], ...
  ones(ts.nr(2)*6,1),ts.nr(1),ts.nr(1));

kpb   = .1;                       % Cutt-off frequency (default: .1)
lam   = .5; mu = lam/(lam*kpb-1); % Parameters for elasticity. (default: .5)
XYZmm = ts.XYZmm;

% smoothing iterations
%--------------------------------------------------------------------------
for j=1:N
  
  XYZmm_o = zeros(3,ts.nr(1));
  XYZmm_o2 = zeros(3,ts.nr(1));
  
  for i=1:ts.nr(1)
    ln = find(M_con(:,i));
    d_i = sqrt(sum((XYZmm(:,ln)-XYZmm(:,i)*ones(1,length(ln))).^2));
    if sum(d_i)==0
      w_i = zeros(size(d_i));
    else
      w_i = d_i/sum(d_i);
    end
    XYZmm_o(:,i) = XYZmm(:,i) + ...
      lam * sum((XYZmm(:,ln)-XYZmm(:,i)*ones(1,length(ln))).*(ones(3,1)*w_i),2);
  end
  
  for i=1:ts.nr(1)
    ln = find(M_con(:,i));
    d_i = sqrt(sum((XYZmm(:,ln)-XYZmm(:,i)*ones(1,length(ln))).^2));
    if sum(d_i)==0
      w_i = zeros(size(d_i));
    else
      w_i = d_i/sum(d_i);
    end
    XYZmm_o2(:,i) = XYZmm_o(:,i) + ...
      mu * sum((XYZmm_o(:,ln)-XYZmm_o(:,i)*ones(1,length(ln))).*(ones(3,1)*w_i),2);
  end
  
  XYZmm = XYZmm_o2;
  
end

% collect output results
%--------------------------------------------------------------------------

pos1 = XYZmm';
tri1 = tri;

if 0
  % this is some test/demo code
  mesh = [];
  [mesh.pos, mesh.tri] = mesh_sphere(162);
  
  scale = 1+0.3*randn(size(pos,1),1);
  mesh.pos = mesh.pos .* [scale scale scale];
  
  figure
  ft_plot_mesh(mesh)
  
  [mesh.pos, mesh.tri] = fairsurface(mesh.pos, mesh.tri, 10);
  
  figure
  ft_plot_mesh(mesh)
end