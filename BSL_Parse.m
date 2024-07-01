% BSL Parsing Code
clc; clear; close all;


%% Interface

data_folder = 'G:\공유 드라이브\BSL-Data\LGES\2차 실험\OCP\데이터 변환\음극';

% Split the path using the directory separator
splitPath = split(data_folder, filesep); %data_folder 를 fileseparator를 통해 분해 --> 각 셀로 나뉨

% Find the index of "Data" (to be replaced)
index = find(strcmp('음극',splitPath), 1); %data가 있는 폴더를 splitpath의 인덱스로 1개만 찾음

% Replace the first "Data" with "Processed_Data"
splitPath{index} = 'Processed_Data_AHC'; % Splitpath의 index 번째 셀을 새로운 이름으로 지정

% Create the new save_path
save_path = strjoin(splitPath, filesep); %새로운 저장 경로 생성

% Create the directory if it doesn't exist
if ~exist(save_path, 'dir') %폴더 유무 확인 후, 없으면 새 폴더 생성
   mkdir(save_path)
end

I_1C = 6.9211*10^-3; %[A] (Capacity)
n_hd = 11; % headline number used in 'readtable' option. WonA: 14, Maccor: 3.
sample_plot = 5; %몇 번째 샘플을 플랏해서 확인할건지 지정

%% Engine
slash = filesep;
files = dir([data_folder slash '*.txt']); % select only txt files (raw data) %파일과 폴더를 나열

for i = 1:length(files)
    fullpath_now = [data_folder slash files(i).name]; % path for i-th file in the folder
    data_now = readtable(fullpath_now,'FileType','text',...
                    'NumHeaderLines',n_hd,'readVariableNames',0); % load the data

    data1.I = data_now.Var7;
    data1.V= data_now.Var8;
    data1.t2 = data_now.Var2; % experiment time, format in duration
    data1.t1 = data_now.Var4; % step time, format in duration
    data1.cycle = data_now.Var3; 
    data1.T = data_now.Var13;

     % datetime
     if isduration(data1.t2(1))
        data1.t = seconds(data1.t2); %Duration이면 시간 전체를 초로 변환
     else
        data1.t = data1.t2;
     end
%% 
%% 

     % absolute current
     data1.I_abs = abs(data1.I);

     % type
     data1.type = char(zeros([length(data1.t),1])); %비어있는 char 컬럼 생성
     data1.type(data1.I>0) = 'C';
     data1.type(data1.I==0) = 'R';
     data1.type(data1.I<0) = 'D';

     % step
     data1_length = length(data1.t);
     data1.step = zeros(data1_length,1);
     m  =1;
     data1.step(1) = m;
        for j = 2:data1_length
            if data1.type(j) ~= data1.type(j-1) % 스텝 구분 단계. CRD가 달라지면 스텝 바뀐 것
                m = m+1;
            end
            data1.step(j) = m;
        end

%% 


     %  check for error, if any step has more than one types
     vec_step = unique(data1.step); %겹치지 않는 배열만 반환
     num_step = length(vec_step); %Vec_step의 길이 (스텝 수만큼 나올 것)
     for i_step = 1:num_step
          type_in_step = unique(data1.type(data1.step == vec_step(i_step))); % Vec_step과 data1.step이 동일한 부분의 data1.type만을 가져와 unique적용해 겹치지 않는 배열로 반환 (예: Vec_step(i_step) = 1이면, data1.step 1에 해당하는 행의 data1.type만 불러옴
          
          if size(type_in_step,1) ~=1 || size(type_in_step,2) ~=1 %% size는 행렬 크기 반환. size(A,dim) dim = 1이면 행, 2면 열을 나타냄냄 (예: A = 2x3 행렬일 때, size(A,2) = 3, size(A,1) = 2), 행렬 중 하나라도 2개 이상의 숫자를 가지면 에러 반환, 위 type_in_stpe에서 unique시 두 개 이상의 성분이 한 행이나 열에 있기 때문에 에러.
              disp('ERROR: step assigment is not unique for a step')
              return
          end
     end


    % plot for selected samples
    if any(ismember(sample_plot,i)) %any: 0이면 0 반환, 아니면 1 반환. vector일 경우 0 or 1, 배열일 경우 열마다 반환. ismember: ismember(A,B) A의 요소 중 B에도 있는 요소를 반환 (예: A = [1 2 3 1], B = [1 3] ismember(A,B) = 1 0 1 1)
                                    %앞서 지정한 Sample plot과 i가 동일한 값을 가질 수 있으면
                                    %피규어 생성. (i는 file 갯수와 동일하므로 i가 가지는 수가
                                    %파일의 순서와 동일)
        figure
        title(strjoin(strsplit(files(i).name,'_'),' ')) %_로 구분된 파일 이름 분해 --> 공백으로 다시 파일 묶음 --> title로 설정
        hold on
        plot(data1.t/3600,data1.V,'-') %초를 시간으로 변경한 뒤, 전압에 대해 실선으로 플랏
        xlabel('time (hours)')
        ylabel('voltage (V)')

        yyaxis right %우측 이중 y축 설정
        plot(data1.t/3600,data1.I/I_1C,'-') %시간 vs I/C 그래프 나타냄. 여기서 I_1C는 앞서 용량을 지정해주었음. --> C_rate로 표현하기 위함
        yyaxis right
        ylabel('current (C)')

    end
%% 
    % make struct (output format)
    data_line = struct('V',zeros(1,1),'I',zeros(1,1),'t',zeros(1,1),'indx',zeros(1,1),'type',char('R'),...
    'steptime',zeros(1,1),'T',zeros(1,1),'cycle',0, 'cum_Q',0); % 1x1 Struct 생성 내부 총 8개의 필드. 전부 숫자로 채워둠. 왜 zeros(1,1)을 사용했는지 이유를 모르겠음. + Cum_Q 추가
    data = repmat(data_line,num_step,1); %repmat: 배열을 반복해서 생성 (예: repmat(A,1,2) 면 A배열을 1행 2열만큼 만듦, repmat(A,2) 면 A를 2x2 배열로 만듦 --> dataline은 한 줄, 이거를 step 수만큼 생성. 

    % fill in the struc
    n = 1; %초기 값 설정
    for i_step = 1:num_step

        range = find(data1.step == vec_step(i_step)); %범위는 vec_step의 i번째 스텝과 (단일 숫자로 나옴) 동일한 data1.step 행의 인덱스를 찾아서 그 부분만 1로 설정.  
        data(i_step).V = data1.V(range); % i번째 step의 데이터는 i번째에 해당하는 index를 갖는 Voltage만 가져와서 기입.
        data(i_step).I = data1.I(range); % 모두 동일한 방식 --> 결과적으로는 데이터 struct에 각 스텝 부분별로 나뉘어 데이터가 저장될 것. 
        data(i_step).t = data1.t(range);
        data(i_step).indx = range; %인덱스는 range와 동일
        data(i_step).type = data1.type(range(1)); %range(1)만 --> 어차피 다 동일하게 값이 들어가 있을 것이므로 첫 번째 type만 불러와서 사용. 
        data(i_step).steptime = data1.t1(range); 
        data(i_step).T = data1.T(range);
        data(i_step).cycle = data1.cycle(range(1)); %사이클도 type과 마찬가지. 
        data(i_step).cum_Q = abs(cumtrapz(data(i_step).t, data(i_step).I))

        % display progress
            if i_step> num_step/10*n %현재 step이 마지막 스텝/10*n 보다 크다면, (이 10이라는 숫자는 직접 스텝을 보고 지정해준건가?, 왜 들어간건지 모르겠음)
                 fprintf('%6.1f%%\n', round(i_step/num_step*100)); % 반올림(현재 스텝/최종 스텝)*100 하여 퍼센트로 나타나게 함.  fprintf 내부 구성: fprintf(formatspec, A1, ... , An) 처음은 형식 지정, A1 등은 출력 변수들. 
% 처음 % 형식 지정자 나타냄, 6:출력되는 값이 차지할 공간, .1: 소수점 첫째 자리까지 표현, f 실수 형식 의미. %% 는
% 형식지정자가 아닌 문자 %를 출력하기 위해 포함, \n: 줄 바꿈 --> 출력 후 새로운 줄로 이동
                 n = n+1; %이후 n값 증가 --> 다음 스텝 진행
            end
    end

    % save output data
    save_fullpath = [save_path slash files(i).name(1:end-4) '.mat']; %저장 경로 및 형식 지정, (1:end-4) 는 .txt 없애기 위함. 
    save(save_fullpath,'data') %data를 save_fullpath 파일명을 사용해서 저장

end



