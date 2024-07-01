
Folder_path_1 = ("C:\Users\admin\Desktop\켄텍 서류\과제 폴더\LGES\데이터\modeling_DC and EIS\12_6cm2_DC # Sample 1");
Folder_path_2 = ("C:\Users\admin\Desktop\켄텍 서류\과제 폴더\LGES\데이터\modeling_DC and EIS\12_6cm2_DC # Sample 2");

File_1 = dir(fullfile(Folder_path_1, '*.txt'));
File_2 = dir(fullfile(Folder_path_2, '*.txt'));

figure;
hold on;

for i = 1:length(File_1);
    % sample 1 플랏
    file_name = File_1(i).name;
    data_path = fullfile(Folder_path_1, file_name);
    data_e_1 = readmatrix(data_path);

    
    time_1 = data_e_1 (:,1);
    current_1 = data_e_1 (:,5); %full = 3 , anode = 4, cathode = 5
    
    % sample 2 플랏
    file_name = File_2(i).name;
    data_path = fullfile(Folder_path_2, file_name);
    data_e_2 = readmatrix(data_path);

    time_2 = data_e_2 (:,1);
    current_2 = data_e_2 (:,5); %full = 3 , anode = 4, cathode = 5

    plot (time_1,current_1,DisplayName = ['Sample 1 soc', num2str((i-1)*10) '~' num2str((i)*10)]);
    plot (time_2,current_2,DisplayName = ['Sample 2 soc', num2str((i-1)*10) '~' num2str((i)*10)]);
    title ('DC graph');
    grid on;
    xlabel ('time/s');
    ylabel ('Cathodecell/V'); %셀 별 맞게 변경
    legend(Location = "best");
end

