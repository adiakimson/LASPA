% GUI for MATLAB analysis
% Created by: Karolina Joachimczyk
% WARNING - CANNOT BE COMPILED WITHOUT IDE AND NECESSARY TOOLKITS

function simple_gui()
    % Create a figure for the GUI
    hFig = figure('Position', [100, 100, 800, 600], 'MenuBar', 'none', 'Name', 'Log and Image Viewer', 'NumberTitle', 'off', 'Resize', 'off');
    
    % Create UI components
    uicontrol('Style', 'pushbutton', 'String', 'Load Log File', 'Position', [20, 540, 100, 30], 'Callback', @loadLogFile);
    uicontrol('Style', 'pushbutton', 'String', 'Browse Images', 'Position', [20, 500, 100, 30], 'Callback', @browseImages);
    uicontrol('Style', 'pushbutton', 'String', 'Show Analysis', 'Position', [20, 460, 100, 30], 'Callback', @showAnalysis);
    
    % Create axes for plotting
    hAxes1 = axes('Parent', hFig, 'Position', [0.2, 0.55, 0.75, 0.4]);
    hAxes2 = axes('Parent', hFig, 'Position', [0.2, 0.1, 0.75, 0.4]);
    
    % Initialize variables
    logData = [];
    imagePaths = {};
    
    % Load Log File callback function
    function loadLogFile(~, ~)
        [fileName, filePath] = uigetfile('*.txt', 'Select Log File');
        if isequal(fileName, 0)
            return;
        end
        
        logFilePath = fullfile(filePath, fileName);
        logData = readLogFile(logFilePath);
        msgbox('Log file loaded successfully');
    end
    
    % Browse Images callback function
    function browseImages(~, ~)
        [fileName, filePath] = uigetfile('*.jpg', 'Select Image File', 'MultiSelect', 'on');
        if isequal(fileName, 0)
            return;
        end
        
        if ischar(fileName)
            imagePaths = {fullfile(filePath, fileName)};
        else
            imagePaths = fullfile(filePath, fileName);
        end
        msgbox('Images loaded successfully');
    end
    
    % Show Analysis callback function
    function showAnalysis(~, ~)
        if isempty(logData)
            msgbox('Load a log file first');
            return;
        end
        
        % Extract data for analysis
        timestamps = datetime.empty;
        cpuTemps = [];
        co2Levels = [];
        temps = [];
        humidities = [];
        pressures = [];
        gasLevels = [];
        
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
            
            % Store values in arrays for plotting
            cpuTemps = [cpuTemps; cpuTemp];
            co2Levels = [co2Levels; co2];
            temps = [temps; temp];
            humidities = [humidities; humidity];
            pressures = [pressures; pressure];
        end
        
        % Plotting
        axes(hAxes1);
        plot(timestamps, cpuTemps, '-o', 'DisplayName', 'CPU Temp');
        xlabel('Date and Time');
        ylabel('Temperature (°C)');
        title('CPU Temperature Over Time');
        legend;
        grid on;
        
        axes(hAxes2);
        plot(timestamps, co2Levels, '-o', 'DisplayName', 'CO2 Levels');
        xlabel('Date and Time');
        ylabel('CO2 (ppm)');
        title('CO2 Levels Over Time');
        legend;
        grid on;
        
        % Display the first image if available
        if ~isempty(imagePaths)
            img = imread(imagePaths{1});
            figure;
            imshow(img);
            title('Selected Image');
        end
    end
    
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

end
