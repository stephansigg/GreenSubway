% choose appropriate rows from orange input files created by 'createOrangeInputFilesForOrange.m'

function [] = parseMetroData(filenameInput,filenameInput2)
    %% Read input file provided

    fileInput = fopen(strcat(filenameInput,'.txt'));
    
    InputValuesOrig=textscan(fileInput,'%s %s %s %d \n'); 
    fclose(fileInput);
    
    
    [row column] = size(InputValuesOrig{1,4});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % restrict length for 700 because in the end the data is not continuous
    row = 10571; 
    minrow=550;
    InputValues= cell(1,4);
    InputValues{1,1}=InputValuesOrig{1,1}(minrow:row,1);
    InputValues{1,2}=InputValuesOrig{1,2}(minrow:row,1);
    InputValues{1,3}=InputValuesOrig{1,3}(minrow:row,1);
    InputValues{1,4}=InputValuesOrig{1,4}(minrow:row,1);
    [row column] = size(InputValues{1,4});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plot(InputValues{1,4}(:,1)); % all values over Time (no specified window size)
    
    %calculate slope
    Slope = zeros(row-1,1);
    for i=2:row
        Slope(i-1)=InputValues{1,4}(i,1)-InputValues{1,4}(i-1,1);
    end
    Mean = mean(InputValues{1,4}(:,1));
    Mean10 = zeros(row-10,1);
    for i=10:row
        Mean10(i-9,1) = mean(InputValues{1,4}(i-10+1:i,1));
    end
    Mean20 = zeros(row-20,1);
    for i=20:row
        Mean20(i-19,1) = mean(InputValues{1,4}(i-20+1:i,1));
    end
    Std = std(double(InputValues{1,4}(:,1)));
    Std10 = zeros(row-10,1);
    for i=10:row
        Std10(i-9,1) = std(double(InputValues{1,4}(i-10+1:i,1)));
    end
    Std20 = zeros(row-20,1);
    for i=20:row
        Std20(i-19,1) = std(double(InputValues{1,4}(i-20+1:i,1)));
    end
    CM3_20 = zeros(row-20,1);
    for i=20:row
        CM3_20(i-19,1) = moment(double(InputValues{1,4}(i-20+1:i,1)),3);
    end
    
    %Now with window and 1/2 overlap:
    Mean10_overlap5 = zeros(row/5,1);
    for i=1:row/5-5
        Mean10_overlap5(i,1) = mean(InputValues{1,4}(i*5-4:i*5+5,1));
    end
    Mean20_overlap10 = zeros(row/10,1);
    for i=1:row/10-10
        Mean20_overlap10(i,1) = mean(InputValues{1,4}(i*10-9:i*10+10,1));
    end
    Mean30_overlap15 = zeros(row/15,1);
    for i=1:row/15-15
        Mean30_overlap15(i,1) = mean(InputValues{1,4}(i*15-14:i*15+15,1));
    end

    Median20_overlap10 = zeros(row/10,1);
    for i=1:row/10-10
        Median20_overlap10(i,1) = median(InputValues{1,4}(i*10-9:i*10+10,1));
    end
    Median10_overlap5 = zeros(row/5,1);
    for i=1:row/5-5
        Median10_overlap5(i,1) = median(InputValues{1,4}(i*5-4:i*5+5,1));
    end
%     Std = std(double(InputValues{1,4}(:,1)));
%     Std10 = zeros(row-10,1);
%     for i=10:row
%         Std10(i-9,1) = std(double(InputValues{1,4}(i-10+1:i,1)));
%     end
%     Std20 = zeros(row-20,1);
%     for i=20:row
%         Std20(i-19,1) = std(double(InputValues{1,4}(i-20+1:i,1)));
%     end
%     CM3_20 = zeros(row-20,1);
%     for i=20:row
%         CM3_20(i-19,1) = moment(double(InputValues{1,4}(i-20+1:i,1)),3);
%     end
%     
    
    % Change Window size: 1hour windows
    % count how many new timesamples:
    
    
    count = 0;
    for i=2:row
        if (isequal(InputValues{1,3}{i,1}(1,1:2),InputValues{1,3}{i-1,1}(1,1:2)))
            %do nothing
        else
            %New value
            count=count+1;
        end
    end
    Hours = zeros(count,2);
    HoursFormatted = cell(count,1);
    HoursFormatted(:) = ('');
    Hours(1,1)=str2num(InputValues{1,3}{1,1}(1,1:2));
    HoursFormatted(1,1) = InputValues{1,3}(1,1);
    Hours(1,2)=InputValues{1,4}(1,1);
    counter=1;
    for i=2:row
        if (isequal(InputValues{1,3}{i,1}(1,1:2),InputValues{1,3}{i-1,1}(1,1:2)))
            Hours(counter,2)=Hours(counter,2)+InputValues{1,4}(i,1);
        else
            %New value
            counter=counter+1;
            Hours(counter,1)=str2num(InputValues{1,3}{i,1}(1,1:2));
            Hours(counter,2)=InputValues{1,4}(i,1);
            HoursFormatted(counter,1) = InputValues{1,3}(i,1);
        end
    end
    
    plot(Hours(:,2)); % new plot over the hours
    
%ANFIS TS Prediction
%x_t=Mean30_overlap15; %data to consider for prediction (adapt boundaries accordingly)
%x_t=Mean20_overlap10; %data to consider for prediction (adapt boundaries accordingly)
%x_t=Mean10_overlap5; %data to consider for prediction (adapt boundaries accordingly)
x_t=Mean20; %data to consider for prediction (adapt boundaries accordingly)

[rowXT columnXT] = size (x_t);
Center = floor(rowXT/2-12);

trn_data = zeros(Center, 5);
chk_data = zeros(Center, 5);

% prepare training data
trn_data(:, 1) = x_t(1:Center);
trn_data(:, 2) = x_t(7:Center+6);
trn_data(:, 3) = x_t(13:Center+12);
trn_data(:, 4) = x_t(19:Center+18);
trn_data(:, 5) = x_t(25:Center+24);

% prepare checking data
chk_data(:, 1) = x_t(Center+1:2*Center);
chk_data(:, 2) = x_t(Center+7:2*Center+6);
chk_data(:, 3) = x_t(Center+13:2*Center+12);
chk_data(:, 4) = x_t(Center+19:2*Center+18);
chk_data(:, 5) = x_t(Center+25:2*Center+24);

index = 1:Center; % ts starts with t = 0
plot(x_t(index));
xlabel('Time (sec)','fontsize',10); ylabel('x(t)','fontsize',10);
title('Mackey-Glass Chaotic Time Series','fontsize',10);

%We use GENFIS1 to generate an initial FIS matrix from training data. The command is quite simple since default values for MF number (2) and MF type ('gbellmf') are used:

fismat = genfis1(trn_data);

% The initial MFs for training are shown in the plots.
for input_index=1:4,
    subplot(2,2,input_index)
    [x,y]=plotmf(fismat,'input',input_index);
    plot(x,y)
    axis([-inf inf 0 1.2]);
    xlabel(['Input ' int2str(input_index)],'fontsize',10);
end

% calculate training results
%load mganfis
%%%%%[trn_fismat,trn_error] = anfis(trn_data, fismat,[],[],chk_data);
[trn_fismat,trn_error,stepsize,chk_fismat,chk_error] = anfis(trn_data, fismat,[],[],chk_data);

% plot final MF's on x, y, z, u
for input_index=1:4,
    subplot(2,2,input_index)
    [x,y]=plotmf(trn_fismat,'input',input_index);
    plot(x,y)
    axis([-inf inf 0 1.2]);
    xlabel(['Input ' int2str(input_index)],'fontsize',10);
end


% error curves plot
close all;
epoch_n = 10;
plot([trn_error chk_error]);
hold on; plot([trn_error chk_error], 'o'); hold off;
xlabel('Epochs','fontsize',10);
ylabel('RMSE (Root Mean Squared Error)','fontsize',10);
title('Error Curves','fontsize',10);

% plot difference predicted/actual
input = [trn_data(:, 1:4); chk_data(:, 1:4)];
anfis_output = evalfis(input, trn_fismat);
index = 13:2*Center+12;
plot([x_t(index) anfis_output]);
xlabel('Time','fontsize',10);
    
% ANFIS prediction error
diff = x_t(index)-anfis_output;
plot(diff);
xlabel('Time','fontsize',10);
title('ANFIS Prediction Errors','fontsize',10);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Once again, the prediction does not seem to be very reasonable yet:
%ANFIS TS Prediction
x_t=Mean30_overlap15; %data to consider for prediction (adapt boundaries accordingly)
%x_t=Mean20_overlap10; %data to consider for prediction (adapt boundaries accordingly)
%x_t=Mean10_overlap5; %data to consider for prediction (adapt boundaries accordingly)
%x_t=Mean20; %data to consider for prediction (adapt boundaries accordingly)

[rowXT columnXT] = size (x_t);
Periodicity = floor(1420/15);

trn_data = zeros(Periodicity, 3);
chk_data = zeros(Periodicity, 3);

% prepare training data
trn_data(:, 1) = x_t(1:Periodicity);
trn_data(:, 2) = x_t(Periodicity+1:2*Periodicity);
trn_data(:, 3) = x_t(2*Periodicity+1:3*Periodicity);
%trn_data(:, 4) = x_t(3*Periodicity+1:4*Periodicity);
%trn_data(:, 5) = x_t(4*Periodicity+1:5*Periodicity);

% prepare checking data
chk_data(:, 1) = x_t(5*Periodicity+1:6*Periodicity);
chk_data(:, 2) = x_t(6*Periodicity+1:7*Periodicity);
%chk_data(:, 3) = x_t(Center+13:2*Center+12);
%chk_data(:, 4) = x_t(Center+19:2*Center+18);
%chk_data(:, 5) = x_t(Center+25:2*Center+24);
chk_data(:, 3) = x_t(4*Periodicity+1:5*Periodicity);

%index = 1:Periodicity; % ts starts with t = 0
%plot(x_t(index));
%xlabel('Time (sec)','fontsize',10); ylabel('x(t)','fontsize',10);
%title('Train sequence','fontsize',10);

%We use GENFIS1 to generate an initial FIS matrix from training data. The command is quite simple since default values for MF number (2) and MF type ('gbellmf') are used:

fismat = genfis1(trn_data);

% The initial MFs for training are shown in the plots.
% for input_index=1:4,
%     subplot(2,2,input_index)
%     [x,y]=plotmf(fismat,'input',input_index);
%     plot(x,y)
%     axis([-inf inf 0 1.2]);
%     xlabel(['Input ' int2str(input_index)],'fontsize',10);
% end

% calculate training results
%load mganfis
%%%%%[trn_fismat,trn_error] = anfis(trn_data, fismat,[],[],chk_data);
[trn_fismat,trn_error,stepsize,chk_fismat,chk_error] = anfis(trn_data, fismat,[],[],chk_data);

% plot final MF's on x, y, z, u
% for input_index=1:4,
%     subplot(2,2,input_index)
%     [x,y]=plotmf(trn_fismat,'input',input_index);
%     plot(x,y)
%     axis([-inf inf 0 1.2]);
%     xlabel(['Input ' int2str(input_index)],'fontsize',10);
% end


% error curves plot
close all;
epoch_n = 10;
plot([trn_error chk_error]);
hold on; plot([trn_error chk_error], 'o'); hold off;
xlabel('Epochs','fontsize',10);
ylabel('RMSE (Root Mean Squared Error)','fontsize',10);
title('Error Curves','fontsize',10);

% plot difference predicted/actual
input2 = [trn_data(:, 1:2); chk_data(:, 1:2)];
anfis_output = evalfis(input2, trn_fismat);
index = 5*Periodicity+1:7*Periodicity;
plot([x_t(index) abs(anfis_output)]);
xlabel('Time','fontsize',10);
plot(abs(anfis_output));


% ANFIS prediction error
diff = x_t(index)-abs(anfis_output);
plot(diff);
xlabel('Time','fontsize',10);
title('ANFIS Prediction Errors','fontsize',10);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% plot difference predicted/actual
input3 = [chk_data(:, 1:4)];
anfis_output = evalfis(input3, trn_fismat);
index = 13:Center+12;
plot([x_t(index) anfis_output]);
xlabel('Time','fontsize',10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% matlab TS forecast:     
sys = ar(trn_data(:,1),2);
K = 1500;
p = predict(sys,trn_data(:,1),K);
plot(trn_data(:,1),'b',p,'r'), legend('measured','forecasted')
    
    
    fileInput = fopen(strcat(filenameInput2,'.txt'));
    
    InputValues2=textscan(fileInput,'%s %s %s %d \n'); 
    fclose(fileInput);
    InputValues2{1,4}(1,1)
    plot(InputValues2{1,4}(:,1)); % all values over Time (no specified window size)
    
    
    
    % Change Window size: 1hour windows
    % count how many new timesamples:
    [row column] = size(InputValues2{1,4});
    count = 0;
    for i=2:row
        if (isequal(InputValues2{1,3}{i,1}(1,1:2),InputValues2{1,3}{i-1,1}(1,1:2)))
            %do nothing
        else
            %New value
            count=count+1;
        end
    end
    Hours2 = zeros(count,2);
    HoursFormatted2 = cell(count,1);
    HoursFormatted2(:) = ('');
    Hours2(1,1)=str2num(InputValues2{1,3}{1,1}(1,1:2));
    HoursFormatted2(1,1) = InputValues2{1,3}(1,1);
    Hours2(1,2)=InputValues2{1,4}(1,1);
    counter=1;
    for i=2:row
        if (isequal(InputValues2{1,3}{i,1}(1,1:2),InputValues2{1,3}{i-1,1}(1,1:2)))
            Hours2(counter,2)=Hours2(counter,2)+InputValues2{1,4}(i,1);
        else
            %New value
            counter=counter+1;
            Hours2(counter,1)=str2num(InputValues2{1,3}{i,1}(1,1:2));
            Hours2(counter,2)=InputValues2{1,4}(i,1);
            HoursFormatted2(counter,1) = InputValues2{1,3}(i,1);
        end
    end
    
    plot(Hours2(:,2)); % new plot over the hours
    
    
end