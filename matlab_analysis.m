% MATLAB script to load logs, images, analyze data, and visualize
% Created by: Karolina Joachimczyk
% WARNING - CANNOT BE COMPILED WITHOUT IDE AND NECESSARY TOOLKITS

% Define file paths
logFilePath = 'path/to/your/logfile.txt';  % Path to your log file
imageFolderPath = 'path/to/your/images/';  % Folder containing your .jpg images

% Read and parse the log file
logData = readLogFile(logFilePath);

% Extract data for analysis
timestamps = datetime.empty;
cpuTemps = [];
co2Levels = [];
temps = [];
humidities = [];
pressures = [];
gasLevels = [];
pumpStatuses = [];
cameraStatuses = [];

for i = 1:length(logData)
    logEntry = logData(i);
    
    % Extract timestamp and data values from the log message
    tokens = split(logEntry.logMessage, ', ');
    
    % Assuming the date and time is in the first token
    timestampStr = tokens{1};
    timestamp = datetime(timestampStr, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
    timestamps = [timestamps; timestamp];
    
    % Extract other data values
    cpuTemp = extractValue(tokens{2});
    co2 = extractValue(tokens{3});
    temp = extractValue(tokens{4});
    humidity = extractValue(tokens{5});
    pressure = extractValue(tokens{6});
    gas = extractValue(tokens{7});
    pumpStatus = extractValue(tokens{8});
    cameraStatus = extractValue(tokens{9});
    
    % Store values in arrays for plotting
    cpuTemps = [cpuTemps; cpuTemp];
    co2Levels = [co2Levels; co2];
    temps = [temps; temp];
    humidities = [humidities; humidity];
    pressures = [pressures; pressure];
    gasLevels = [gasLevels; gas];
    pumpStatuses = [pumpStatuses; pumpStatus];
    cameraStatuses = [cameraStatuses; cameraStatus];
end

% Plotting
figure;
subplot(3,1,1);
plot(timestamps, cpuTemps, '-o', 'DisplayName', 'CPU Temp');
xlabel('Date and Time');
ylabel('Temperature (°C)');
title('CPU Temperature Over Time');
legend;
grid on;

subplot(3,1,2);
plot(timestamps, co2Levels, '-o', 'DisplayName', 'CO2 Levels');
xlabel('Date and Time');
ylabel('CO2 (ppm)');
title('CO2 Levels Over Time');
legend;
grid on;

subplot(3,1,3);
plot(timestamps, temps, '-o', 'DisplayName', 'Temperature');
hold on;
plot(timestamps, humidities, '-o', 'DisplayName', 'Humidity');
plot(timestamps, pressures, '-o', 'DisplayName', 'Pressure');
xlabel('Date and Time');
ylabel('Measurements');
title('Temperature, Humidity, and Pressure Over Time');
legend;
grid on;

% Function to read and parse the log file
function logData = readLogFile(filePath)
    fileID = fopen(filePath, 'r');
    if fileID == -1
        error('Failed to open log file.');
    end

    logData = [];
    tline = fgetl(fileID);
    while ischar(tline)
        % Split the log entry by commas and extract relevant data
        tokens = split(tline, ', ');
        if numel(tokens) >= 10
            logMessage = strjoin(tokens(1:end-2), ', ');
            photoCtr = str2double(tokens{end-1});
            wateringCtr = str2double(tokens{end});
            
            % Create a structure for each log entry
            logData(end+1).logMessage = logMessage;
            logData(end).photoCtr = photoCtr;
            logData(end).wateringCtr = wateringCtr;
        end
        tline = fgetl(fileID);
    end

    fclose(fileID);
end

% Function to extract numerical values from log entry
function value = extractValue(token)
    valueStr = extractAfter(token, ': ');
    if isempty(valueStr)
        value = NaN;
    else
        value = str2double(valueStr);
    end
end
