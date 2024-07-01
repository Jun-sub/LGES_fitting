% Parse 진행 후 얻은 data file 넣어서 진행

% BSL OCV Code
clc; clear; close all;

%% Interface

% data folder
data_folder = 'G:\공유 드라이브\BSL-Data\LGES\2차 실험\OCP\데이터 변환\Processed_Data_CHC';
[save_folder,save_name] = fileparts(data_folder); %fileparts[a,b,c] - a: 파일 경로, b: 파일 이름, c: 파일 확장자

% cathode, fullcell, or anode
id_cfa = 1; % 1 for cathode, 2 for fullcell, 3 for anode, 0 for automatic (not yet implemented) 셀 타입 지정

% OCV steps
    % chg/dis sub notation : with respect to the full cell operation
step_ocv_chg = 4; %data struct.type 확인해서 기입 양극은 4,6 음극은 6,4
step_ocv_dis = 6;

% parameters
y1 = 0.215685; % cathode stoic at soc = 100%. reference : AVL NMC811
x_golden = 0.5; %골든을 0.5로 설정



%% Engine
slash = filesep;
files = dir([data_folder slash '*.mat']); %mat 형식 파일을 다 불러와서 나열

for i = 1:length(files) %파일 갯수만큼 다 진행
    fullpath_now = [data_folder slash files(i).name]; % path for i-th file in the folder
    load(fullpath_now); %mat 파일 바로 불러옴

    for j = 1:length(data) %데이터 갯수만큼 반복 (step 수만큼)
    % calculate capabilities
        if length(data(j).t) > 1 %data의 시간이 1보다 크면, 왜 필요한건지는 모르겠음.
            data(j).Q = abs(trapz(data(j).t,data(j).I))/3600; %[Ah] data에 용량 추가. Ah로 나타내기 위해 3600 나눔. 각 스텝마다의 용량으로 나타남. 
            data(j).cumQ = abs(cumtrapz(data(j).t,data(j).I))/3600; %[Ah] 마찬가진데, 축적 용량으로 나타남. 
        end
    end

    data(step_ocv_chg).soc = data(step_ocv_chg).cumQ/data(step_ocv_chg).Q;
    data(step_ocv_dis).soc = 1-data(step_ocv_dis).cumQ/data(step_ocv_dis).Q;

    % stoichiometry for cathode and anode (not for fullcell)
    if id_cfa == 1 % cathode
        data(step_ocv_chg).stoic = 1-(1-y1)*data(step_ocv_chg).soc;
        data(step_ocv_dis).stoic = 1-(1-y1)*data(step_ocv_dis).soc;
    elseif id_cfa == 3 % anode
        data(step_ocv_chg).stoic = data(step_ocv_chg).soc;
        data(step_ocv_dis).stoic = data(step_ocv_dis).soc;
    elseif id_cfa == 2 % full cell
        % stoic is not defined for full cell.
    end


    % make an overall OCV struct
    if id_cfa == 1 || id_cfa == 3 % cathode or anode halfcell
        x_chg = data(step_ocv_chg).stoic;  
        y_chg = data(step_ocv_chg).V;
        z_chg = data(step_ocv_chg).cumQ;
        x_dis = data(step_ocv_dis).stoic;
        y_dis = data(step_ocv_dis).V;
        z_dis = data(step_ocv_dis).cumQ;
    elseif id_cfa == 2 % fullcell
        x_chg = data(step_ocv_chg).soc;
        y_chg = data(step_ocv_chg).V;
        z_chg = data(step_ocv_chg).cumQ;
        x_dis = data(step_ocv_dis).soc;
        y_dis = data(step_ocv_dis).V;
        z_dis = data(step_ocv_dis).cumQ;

    end

    OCV_all(i).OCVchg = [x_chg y_chg z_chg];
    OCV_all(i).OCVdis = [x_dis y_dis z_dis];

    OCV_all(i).Qchg = data(step_ocv_chg).Q;
    OCV_all(i).Qdis = data(step_ocv_dis).Q;


    % golden criteria
    OCV_all(i).y_golden = (interp1(x_chg,y_chg,0.5)+ interp1(x_dis,y_dis,0.5))/2; 
    

    % plot
    color_mat=lines(4);
    if i == 1
    figure
    end
    hold on; box on;
    plot(x_chg,y_chg,'-',"Color",color_mat(1,:))
    plot(x_dis,y_dis,'-','Color',color_mat(2,:))
    % axis([0 1 3 4.2])
    xlim([0 1])
    set(gca,'FontSize',12,'XDir', 'reverse');



end

% select an golden OCV
[~,i_golden] = min(abs([OCV_all.y_golden]-median([OCV_all.y_golden])));
OCV_golden.i_golden = i_golden;

% save OCV struct
OCV_golden.OCVchg = OCV_all(1,i_golden).OCVchg;
OCV_golden.OCVdis = OCV_all(1,i_golden).OCVdis;

% plot
title_str = strjoin(strsplit(save_name,'_'),' ');
title(title_str)
plot(OCV_golden.OCVchg(:,1),OCV_golden.OCVchg(:,2),'--','Color',color_mat(3,:))
plot(OCV_golden.OCVdis(:,1),OCV_golden.OCVdis(:,2),'--','Color',color_mat(4,:))
% save
save_fullpath = [save_folder filesep save_name '.mat'];
save(save_fullpath,'OCV_golden','OCV_all')
