
Folder_path = ("C:\Users\admin\Desktop\켄텍 서류\과제 폴더\LGES\데이터\modeling_DC and EIS\12_6cm2_DC # Sample 1");

File = dir(fullfile(Folder_path, '*.txt'));


figure;
hold on;

for i = 1:length(File);
    file_name = File(i).name;
    data_path = fullfile(Folder_path, file_name);
    data_e = readmatrix(data_path);

    time = data_e (:,1);
    current = data_e (:,3);
    
    plot (time,current,DisplayName = ['soc', num2str((i-1)*10) '~' num2str((i)*10)]);
    title ('DC graph');
    grid on;
    xlabel ('time/s');
    ylabel ('Fullcell/V');
    legend(Location = "best");
end

