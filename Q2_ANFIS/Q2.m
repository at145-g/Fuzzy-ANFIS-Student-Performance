
%   STUDENT PERFORMANCE 

clc;
clear;
close all;


data = readmatrix('student_performance_1000.xlsx');

data = data(:, [1 2 3 5]);

data = data / 100;

N = size(data,1);
idx = randperm(N);

train_size = round(0.8 * N);

train_data = data(idx(1:train_size), :);
test_data  = data(idx(train_size+1:end), :);

fis = genfis1(train_data, 2, 'gbellmf');
epoch_n = 50;

[trainedFis, trainError, stepSize, chkFis, chkError] = ...
    anfis(train_data, fis, epoch_n, [], test_data);

[~, best_epoch] = min(chkError);

fprintf('Best Epoch = %d\n', best_epoch);

figure;
plot(trainError,'LineWidth',2); hold on;
plot(chkError,'LineWidth',2);

xline(best_epoch,'--r','Best Epoch');

legend('Training Error','Testing Error','Best Epoch');
xlabel('Epoch');
ylabel('Error');
title('ANFIS Training vs Testing Error');
grid on;

bestFis = chkFis;

test_inputs = test_data(:,1:3);
actual_output = test_data(:,4);

predicted_output = evalfis(bestFis, test_inputs);

predicted_output = predicted_output * 100;
actual_output = actual_output * 100;

predicted_output = max(0, min(100, predicted_output));

test_rmse = sqrt(mean((predicted_output - actual_output).^2));

fprintf('Final Test RMSE = %.2f\n', test_rmse);

sample = [85 80 78] / 100;

pred = evalfis(bestFis, sample) * 100;
pred = max(0, min(100, pred));

fprintf('\nPredicted Score = %.2f\n', pred);

if pred < 50
    label = 'Poor';
elseif pred < 75
    label = 'Average';
else
    label = 'Good';
end

fprintf('Performance Level = %s\n', label);


writeFIS(bestFis,'student_anfis_final.fis');