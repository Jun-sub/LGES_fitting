
%샘플 1,2 Soc별 그래프를 한 피규어에 그리는 함수
%샘플 이름 C09, C11

%대략 순서 
% 1) 샘플별 파일 불러오기 
% 2) 샘플 셀 별 1,2 파일 합치기
% 3) 합쳐진 파일 SoC별 정리
% 4) 샘플별 anode, cathode, full 파일 분리해서 정리
% 5) SoC별 피규어당 각 두 개 SoC씩 플랏
% 5-1) X,Y 축 스케일 일치시키기. 

% 1) 샘플별 파일 불러오기

Data_1_path = "C:\Users\admin\Desktop\켄텍 서류\과제 폴더\LGES\데이터\modeling_DC and EIS\12_6cm2_soc10_EIS # Sample 1";
Data_2_path = "C:\Users\admin\Desktop\켄텍 서류\과제 폴더\LGES\데이터\modeling_DC and EIS\12_6cm2_soc10_EIS # Sample 2";

File_1 = dir(fullfile(Data_1_path, '*.csv')); %%'.' '..' 없애기 위해 csv 파일만 지정해서 불러옴
File_2 = dir(fullfile(Data_2_path, '*.csv'));

% 2) 샘플 1,2 파일 합치기

File = [File_1; File_2]; 

% 3) 합쳐진 파일 SoC별 정리

%%못만들겠다. 잠시 보류!

File_sorted = File(sorted_indices);

% 4) 샘플별 anode, cathode, full 파일 분리해서 정리
File_full = File_sorted(contains({File.name}, 'full'));
File_cathode = File_sorted(contains({File.name}, 'cathode'));
File_anode = File_sorted(contains({File.name}, 'anode'));

