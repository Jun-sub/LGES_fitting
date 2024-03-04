
%직접 파일 경로를 다 지정하여 플랏하기

data1_path = "C:\Users\admin\Desktop\켄텍 서류\과제 폴더\LGES\데이터\modeling_DC and EIS\12_6cm2_DC # Sample 1\mono_12_6cm2_soc10_DC_sample#1_soc10-20.txt"; %3,4,5열 각각 full, anode, cathode이고, soc 숫자만 변경해주면 됨.
data2_path = "C:\Users\admin\Desktop\켄텍 서류\과제 폴더\LGES\데이터\modeling_DC and EIS\12_6cm2_DC # Sample 2\mono_12_6cm2_soc10_DC_sample#2_soc10-20.txt"; %3,4,5열 각각 full, anode, cathode이고, soc 숫자만 변경해주면 됨.

data1 = readmatrix (data1_path);
data2 = readmatrix (data2_path);

data_1_time = data1(:,1);
data_1_voltage = data1(:,3); %full = 3 , anode = 4, cathode = 5

data_2_time = data2(:,1);
data_2_voltage = data2(:,3); %full = 3 , anode = 4, cathode = 5


% 그래프 그리기
figure;
pattern = 'soc\d+-\d+';
soc = regexp(data1_path, pattern,'match');
legend_1 = ['Sample 1', soc{1}];
legend_2 = ['Sample 2', soc{1}];
plot(data_1_time, data_1_voltage, 'b', 'DisplayName', legend_1);
hold on;
plot(data_2_time, data_2_voltage, 'r', 'DisplayName', legend_2);

% 그래프 스타일 설정
grid on;
xlabel('Time');
ylabel('Voltage');
title('DC plot');
legend (Location= "best");