
%직접 파일 경로를 다 지정하여 플랏하기

data1_path = "C:\Users\admin\Desktop\켄텍 서류\과제 폴더\LGES\데이터\modeling_DC and EIS\12_6cm2_soc10_EIS # Sample 1\PEIS_C09_cathode_cycle_soc10.csv"; %여기서 full, cathode, anode 지정하고, soc 숫자만 변경해주면 됨.
data2_path = "C:\Users\admin\Desktop\켄텍 서류\과제 폴더\LGES\데이터\modeling_DC and EIS\12_6cm2_soc10_EIS # Sample 2\PEIS_C11_cathode_cycle_soc10.csv"; %여기서 full, cathode, anode 지정하고, soc 숫자만 변경해주면 됨.

data1 = readmatrix (data1_path);
data2 = readmatrix (data2_path);

data_1_Real = data1(:,2);
data_1_Imag = data1(:,3);

data_2_Real = data2(:,2);
data_2_Imag = data2(:,3);


% 그래프 그리기
figure;
plot(data_1_Real, -data_1_Imag, 'b', 'DisplayName', 'cathode 1 Soc 10');
hold on;
plot(data_2_Real, -data_2_Imag, 'r', 'DisplayName', 'cathode 2 Soc 10');

% 그래프 스타일 설정
grid on;
xlabel('Ohm Real');
ylabel('-Ohm Imag');
title('EIS plot');
axis equal
legend;