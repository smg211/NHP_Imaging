%% For each of the following datapoints (A,B,C), measure data 

%% RA (ML - AP only)
%% ABC
% MMA_right_meas = {[60.5, -43+17.55], [26.7, -43+11.91], [39.2, -43+11.21]}; 
% MMB_right_DBS = {[58.91, -44.6], [25.07, -50.7], [37.51, -51.4]};
% MMB_right_Edge = {[61.73, -48.7], [27.61, -55.5], [40.15, -56]}; 
% MMB_right_lesion = {[56.75, -49.8], [22.83, -55.9], [35.35, -56.5]}; 
% 
% 
% %% DEF
% %MMA_left_meas = {[-36.3, -35-11.94], [-57.4, -7.7-12.02], [-52.1, -31.7]}; % Edited pt 3, dim 2 (prev = -12-12.32)
% %MMB_left_DBS = {[-34.47, -31.9], [-55.48, -5.3], [-50.3, -16.4]}; 
% %MMB_left_Edge ={[-37.53, -28.3], [-58.62, -2.7], [-53.27, -13.5]}; 
% %MMB_left_lesion = {[-33.2, -26.0], [], [-49.06, -11.9]}; 
% % save('stx_conversion.mat', 'MMA_right_meas', 'MMB_right_DBS',...
% %     'MMB_right_Edge','MMB_right_lesion', 'MMA_left_meas',...
% %     'MMB_left_DBS', 'MMB_left_Edge','MMB_left_lesion'); 
% 
% % RECALIBRATE IN NX
% MMA_left_meas = {[ -31.9, 87.8 - 21.57], [], []}; 
% MMB_left_Edge = {[-32.7, 89.5],[],[]};  
% MMB_left_lesion = {[-28.72, 90.0],[],[]}; 
% save('stx_conversion2.mat', 'MMA_right_meas', 'MMB_right_DBS',...
%     'MMB_right_Edge','MMB_right_lesion', 'MMA_left_meas',...
%     'MMB_left_Edge','MMB_left_lesion'); 


%% For each of the following datapoints (A,B,C), measure data 
% Measurements taken on 6/2/2022 before sterilizing stereotax equipmetn 
% R - A - S convention

% A / B / C points ABC
MMA_left_meas = {[-28.0, -12.12 - 98.1, 41.6]  , [-33.8, -98.1 - 7.61, 41.4], [-23.9, -8.85 - 98.1, 41.2]}; 

MMB_left_Edge = {[-29.8, -101.0, 38.43      ]  , [-35.69, -96.5, 37.65], [-26.04, -97.5, 38.05]}; 
MMB_left_DBS = {[-26.44, -102.0, 46.37      ]  , [-32.29, -97.3, 46.37], [-22.76, -98.5, 46.22]}; 

MMC_left_Edge = {[-30.37, -95.8 - 17.02, 5.96], [-36.33, -95.8 - 12.5, 5.65], [-26.63, -95.8-13.68, 5.6]}; 
MMC_left_DBS =  {[-27.33, -95.8 - 18.23, 14.09],[-33.22, -95.8 - 13.75, 13.76], [-23.55, -95.8-14.79, 14.05]};

% Different A / B / C points 
MMA_right_meas = { [66.0, -47.8 + 15.1, 40.9], [59.8, -51.4 + 15.1, 41.0], [64.5, -42.9 + 15.1, 41.0]}; 
MMB_right_Edge = { [68.65, -42.1, 37.8],       [62.11, -45.9, 37.57],       [66.83, -37.5, 37.37]}; 
MMC_right_Edge = { [69.51, -45.4 + 15.1, 5.8], [63.2, -45.4 + 11.3, 5.3], [67.75, -45.4 + 19.9, 5.55]}; 



save('stx_conversion.mat',  'MMA_left_meas',...
    'MMB_left_Edge','MMB_left_DBS', 'MMC_left_Edge', 'MMC_left_DBS',...
    'MMA_right_meas', 'MMB_right_Edge', 'MMC_right_Edge'); 



