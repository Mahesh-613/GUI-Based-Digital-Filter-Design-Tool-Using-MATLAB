function IIR_FILTER_GUI
    % Name: Mahesh Kumar Sahoo
    % Reg No: 23410191946

    clc;clear;close all;
    
    % Shared variables to store coefficients for the Pole-Zero plot and Filtering
    b1 = []; a1 = []; 
    b2 = []; a2 = []; 
    b3 = []; a3 = [];
    b4 = []; a4 = [];
    filtersDesigned = false; % Flag to check if filters are generated
    
    %   MAIN WINDOW 
    fig = uifigure('Name', 'IIR Filter Design','Position', [100 100 950 600]);
        
    %   MAIN GRID 
    main_grid = uigridlayout(fig, [1, 2]);
    main_grid.ColumnWidth = {'1x', '1.5x'};
    
    %   LEFT PANEL  
    left_grid = uigridlayout(main_grid, [15, 2]); % Increased rows to 13
    left_grid.RowHeight = {25,25,25,25,25,25,40,40,40,40,30,30,'1x'}; % Added height for new button
    left_grid.ColumnWidth = {150,'1x'};
    left_grid.Padding = [10 10 10 10];
    
    %   FILTER TYPE  
    uilabel(left_grid, 'Text', 'Filter Type:');
    typeDrop = uidropdown(left_grid,'Items', {'Lowpass', 'Highpass', 'Bandpass', 'Bandstop'});
        
    %   FILTER ORDER  
    uilabel(left_grid, 'Text', 'Filter Order (N):');
    orderEdit = uieditfield(left_grid,'numeric', 'Value', 4);
        
    %   CUTOFF  
    uilabel(left_grid, 'Text', 'Cutoff Freq:');
    cutoffEdit = uieditfield(left_grid,'text','Placeholder', 'e.g. 200 or 100 300 (Enter in Hz)');
        
    %   PASSBAND RIPPLE  
    uilabel(left_grid, 'Text', 'Passband Ripple:');
    rpEdit = uieditfield(left_grid,'numeric','Value', 1, 'Placeholder', 'Enter in dB');
        
    %   STOPBAND ATTENUATION  
    uilabel(left_grid, 'Text', 'Stopband Attenuation:');
    rsEdit = uieditfield(left_grid,'numeric','Value', 40, 'Placeholder', 'Enter in dB');
        
    %   SAMPLING FREQUENCY  
    uilabel(left_grid, 'Text', 'Sampling Freq:');
    fsEdit = uieditfield(left_grid,'numeric','value', 1000,'Placeholder', 'Enter in Hz');
        
    %   DESIGN BUTTON  
    designBtn = uibutton(left_grid,'Text', 'Design Filters','ButtonPushedFcn', @(btn,event) designFilter());
    designBtn.Layout.Row = 7;
    designBtn.Layout.Column = [1 2];
    designBtn.BackgroundColor = [0 0.4470 0.7410];
    designBtn.FontColor = [1 1 1];
    designBtn.FontWeight = 'bold';
    
    %   POLE-ZERO BUTTON  
    pzBtn = uibutton(left_grid,'Text', 'Show Pole-Zero Plot','ButtonPushedFcn', @(btn,event) plotPoleZero());
    pzBtn.Layout.Row = 8;
    pzBtn.Layout.Column = [1 2];
    pzBtn.BackgroundColor = [0.4660 0.6740 0.1880]; % MATLAB Green
    pzBtn.FontColor = [1 1 1];
    pzBtn.FontWeight = 'bold';
    
    %   HARDWARE CALCULATOR BUTTON
    hwBtn = uibutton(left_grid, 'Text', 'Calculate Hardware Components', 'ButtonPushedFcn', @(btn,event) calcHardware());
    hwBtn.Layout.Row = 9;
    hwBtn.Layout.Column = [1 2];
    hwBtn.BackgroundColor = [0.8500 0.3250 0.0980]; % MATLAB Orange
    hwBtn.FontColor = [1 1 1];
    hwBtn.FontWeight = 'bold';

    %   SIGNAL FILTERING TEST BUTTON (NEW)
    testSigBtn = uibutton(left_grid, 'Text', 'Test Filter on Signal', 'ButtonPushedFcn', @(btn,event) testSignalFilter());
    testSigBtn.Layout.Row = 10;
    testSigBtn.Layout.Column = [1 2];
    testSigBtn.BackgroundColor = [0.4940 0.1840 0.5560]; % MATLAB Purple
    testSigBtn.FontColor = [1 1 1];
    testSigBtn.FontWeight = 'bold';
    
    %   STATUS LABEL  
    statusLabel = uilabel(left_grid, 'Text','Status : Waiting','FontWeight','bold','FontSize',13);
    statusLabel.Layout.Row = 11;
    statusLabel.Layout.Column = [1 2];

    % Computation Time 
    timeLabel = uilabel(left_grid, 'Text','Time consumed for :','FontWeight','bold','FontSize',13);
    timeLabel.Layout.Row = [12 15];
    timeLabel.Layout.Column = [1 2];
    
    %   AXES  
    ax = uiaxes(main_grid);
    ax.Layout.Row = 1;
    ax.Layout.Column = 2;
    ax.FontSize = 12;
    grid(ax,'on');
    xlabel(ax,'Frequency (Hz)');
    ylabel(ax,'Magnitude (dB)');
    title(ax,'Comparison of IIR Filters');
    
    % DESIGN FILTER FUNCTION
    function designFilter()
        try
            n = orderEdit.Value;
            fc = str2num(cutoffEdit.Value);
            Rp = rpEdit.Value;
            Rs = rsEdit.Value;
            Fs = fsEdit.Value;
            filterType = typeDrop.Value;
            
            if isempty(fc)
                uialert(fig, 'Please enter cutoff frequency.', 'Input Error');
                return;
            end

            if ((filterType == convertCharsToStrings('Bandpass')) || (filterType == convertCharsToStrings('Bandstop'))) && isscalar(fc)
                uialert(fig, 'Please enter cutoff frequency as f1 f2 (e.g. 100 200, in Hz) for bandpass and bandstop filter', 'Input Error');
                return;
            end
            
            Wn = fc/(Fs/2);
            cla(ax);
            hold(ax,'on');
            
           t_butt = 0; t_cheby1 = 0; t_ellip = 0; t_cheby2 = 0;
        
        switch filterType
            case 'Lowpass'
                t = tic; [b1,a1] = butter(n,Wn,'low'); t_butt = toc(t);
                t = tic; [b2,a2] = cheby1(n,Rp,Wn,'low'); t_cheby1 = toc(t);
                t = tic; [b3,a3] = ellip(n,Rp,Rs,Wn,'low'); t_ellip = toc(t);
                t = tic; [b4,a4] = cheby2(n,Rp,Wn,'low'); t_cheby2 = toc(t);
            case 'Highpass'
                t = tic; [b1,a1] = butter(n,Wn,'high'); t_butt = toc(t);
                t = tic; [b2,a2] = cheby1(n,Rp,Wn,'high'); t_cheby1 = toc(t);
                t = tic; [b3,a3] = ellip(n,Rp,Rs,Wn,'high'); t_ellip = toc(t);
                t = tic; [b4,a4] = cheby2(n,Rp,Wn,'high'); t_cheby2 = toc(t);
            case 'Bandpass'
                t = tic; [b1,a1] = butter(n,Wn); t_butt = toc(t);
                t = tic; [b2,a2] = cheby1(n,Rp,Wn); t_cheby1 = toc(t);
                t = tic; [b3,a3] = ellip(n,Rp,Rs,Wn); t_ellip = toc(t);
                t = tic; [b4,a4] = cheby2(n,Rp,Wn); t_cheby2 = toc(t);
            case 'Bandstop'
                t = tic; [b1,a1] = butter(n,Wn,'stop'); t_butt = toc(t);
                t = tic; [b2,a2] = cheby1(n,Rp,Wn,'stop'); t_cheby1 = toc(t);
                t = tic; [b3,a3] = ellip(n,Rp,Rs,Wn,'stop'); t_ellip = toc(t);
                t = tic; [b4,a4] = cheby2(n,Rp,Wn,'stop'); t_cheby2 = toc(t);
        end
        
    
            %cell array of strings for a multi-line label
            timeText = {
                'Time consumed for filter coefficient calculation of :';
                sprintf('Butterworth   :  %.5f s', t_butt);
                sprintf('Chebyshev-I  :  %.5f s', t_cheby1);
                sprintf('Elliptic           :  %.5f s', t_ellip);
                sprintf('Chebyshev-II :  %.5f s', t_cheby2)
            };
            
            % Assign it to the label you created earlier
            timeLabel.Text = timeText;
            timeLabel.FontColor = [0.2, 0.35, 0.5];
            
            % Set flag to true so other buttons work
            filtersDesigned = true; 
            
            [H1,f] = freqz(b1,a1,1024,Fs);
            [H2,~] = freqz(b2,a2,1024,Fs);
            [H3,~] = freqz(b3,a3,1024,Fs);
            [H4,~] = freqz(b4,a4,1024,Fs);
            
            plot(ax,f,20*log10(abs(H1)), 'LineWidth',2);
            plot(ax,f,20*log10(abs(H2)), 'LineWidth',2);
            plot(ax,f,20*log10(abs(H3)), 'LineWidth',2);
            plot(ax,f,20*log10(abs(H4)), 'LineWidth',0.7);
            
            legend(ax, 'Butterworth', 'Chebyshev-I', 'Elliptic','Chebyshev-II', 'Location','best');
            title(ax, ['Comparison of ' filterType ' Filters']);
            xlabel(ax,'Frequency (Hz)');
            ylabel(ax,'Magnitude (dB)');
            grid(ax,'on');
            
            if all(abs(roots(a1)) < 1) && all(abs(roots(a2)) < 1) && all(abs(roots(a3)) < 1) && all(abs(roots(a4)) < 1)
                statusLabel.Text = 'Status : All Filters are Stable';
                statusLabel.FontColor = [0 0.5 0.1];
            else
                statusLabel.Text = 'Status : Unstable Filter Found';
                statusLabel.FontColor = [1 0 0];
            end
        catch ME
            uialert(fig, ME.message, 'Design Error');
        end
    end

    % POLE-ZERO PLOT FUNCTION
    function plotPoleZero()
        if ~filtersDesigned
            uialert(fig, 'Please design the filters first by clicking "Design Filters".', 'Missing Data');
            return;
        end
        
        pzFig = figure('Name','Pole-Zero Analysis', 'Position', [500 200 550 500]);
        
        subplot(2,2,1);
        zplane(b1,a1);
        title('Butterworth');
        
        subplot(2,2,2);
        zplane(b2,a2);
        title('Chebyshev-I');

        subplot(2,2,3);
        zplane(b4,a4); % Fixed this to correctly plot Chebyshev-II
        title('Chebyshev-II');
        
        subplot(2,2,4);
        zplane(b3,a3);
        title('Elliptic');
    end

    % HARDWARE CALCULATOR FUNCTION
    function calcHardware()
        if ~filtersDesigned
            uialert(fig, 'Please design the filters first by clicking "Design Filters".', 'Missing Data');
            return;
        end
        
        % Create modal window for selections
        hwFig = uifigure('Name', 'Hardware Complexity', 'Position', [350 250 350 300], 'WindowStyle', 'modal');
        hwGrid = uigridlayout(hwFig, [5, 2]);
        hwGrid.RowHeight = {30, 30, 40, 90, '1x'};
        
        uilabel(hwGrid, 'Text', 'Structure:');
        structDrop = uidropdown(hwGrid, 'Items', {'Direct Form I', 'Direct Form II'});
        
        uilabel(hwGrid, 'Text', 'Filter:');
        filtDrop = uidropdown(hwGrid, 'Items', {'Butterworth', 'Chebyshev-I', 'Elliptic','Chebyshev-II'});
        
        calcActionBtn = uibutton(hwGrid, 'Text', 'Calculate', 'ButtonPushedFcn', @(btn,event) showHardwareBlocks());
        calcActionBtn.Layout.Row = 3;
        calcActionBtn.Layout.Column = [1 2];
        
        resLabel = uilabel(hwGrid, 'Text', '', 'WordWrap', 'on', 'FontWeight', 'bold');
        resLabel.Layout.Row = 4;
        resLabel.Layout.Column = [1 2];
        
        function showHardwareBlocks()
            strType = structDrop.Value;
            fType = filtDrop.Value;
            
            if strcmp(fType, 'Butterworth')
                num = b1; den = a1;
            elseif strcmp(fType, 'Chebyshev-I')
                num = b2; den = a2;
            elseif strcmp(fType, 'Chebyshev-II')
                num = b4; den = a4;
            else
                num = b3; den = a3;
            end
            
            N_num = length(num) - 1;
            M_den = length(den) - 1;
            
            adders = N_num + M_den;
            multipliers = N_num + 1 + M_den;
            
            if strcmp(strType, 'Direct Form I')
                delays = N_num + M_den;
            else
                delays = max(N_num, M_den);
            end
            
            resultText = sprintf('Structure: %s\nFilter: %s\n\nAdders Required: %d\nMultipliers Required: %d\nDelay Elements Required: %d', ...
                                 strType, fType, adders, multipliers, delays);
            resLabel.Text = resultText;
        end
    end

   % SIGNAL FILTERING TEST FUNCTION (AUDIO INPUT)
    function testSignalFilter()
        if ~filtersDesigned
            uialert(fig, 'Please design the filters first by clicking "Design Filters".', 'Missing Data');
            return;
        end
        
        % Variables to store audio data locally within this function
        audioData = [];
        filteredAudio = [];
        audioFs = 44100; % Default, will be updated on load
        
        % Create new larger window for signal processing
        sigFig = uifigure('Name', 'Audio Filtering', 'Position', [200 100 800 650]);
        
        % Create a 5-row, 5-column grid to strictly control button sizes
        sigGrid = uigridlayout(sigFig, [5, 5]);
        sigGrid.RowHeight = {40, '1x', 30, '1x', 30};
        sigGrid.ColumnWidth = {'1x', 140, 160, 140, '1x'}; 
        
        % --- ROW 1: Controls ---
        loadBtn = uibutton(sigGrid, 'Text', 'Load Audio File', 'ButtonPushedFcn', @(btn,event) loadAudioFile());
        loadBtn.Layout.Row = 1; loadBtn.Layout.Column = 2;
        
        filtApplyDrop = uidropdown(sigGrid, 'Items', {'Butterworth', 'Chebyshev-I','Chebyshev-II', 'Elliptic'});
        filtApplyDrop.Layout.Row = 1; filtApplyDrop.Layout.Column = 3;
        
        runFilterBtn = uibutton(sigGrid, 'Text', 'Filter Audio', 'ButtonPushedFcn', @(btn,event) applyAudioFilter());
        runFilterBtn.BackgroundColor = [0.8500 0.3250 0.0980];
        runFilterBtn.FontColor = 'white';
        runFilterBtn.FontWeight = 'bold';
        runFilterBtn.Layout.Row = 1; runFilterBtn.Layout.Column = 4;
        
        % --- ROW 2: Original Audio Plot ---
        axNoisy = uiaxes(sigGrid);
        axNoisy.Layout.Row = 2;
        axNoisy.Layout.Column = [1 5];
        title(axNoisy, 'Original Audio Signal');
        xlabel(axNoisy, 'Time (s)');
        ylabel(axNoisy, 'Amplitude');
        grid(axNoisy, 'on');
        
        % --- ROW 3: Play Original Audio Button ---
        % Placed in column 3 to center it, inherently making it a smaller, fixed width
        playOrigBtn = uibutton(sigGrid, 'Text', 'Play original audio', 'ButtonPushedFcn', @(btn,event) playSound('original'));
        playOrigBtn.Layout.Row = 3; 
        playOrigBtn.Layout.Column = 3;
        playOrigBtn.Enable = 'off';
        
        % --- ROW 4: Filtered Audio Plot ---
        axFilt = uiaxes(sigGrid);
        axFilt.Layout.Row = 4;
        axFilt.Layout.Column = [1 5];
        title(axFilt, 'Filtered Audio Signal');
        xlabel(axFilt, 'Time (s)');
        ylabel(axFilt, 'Amplitude');
        grid(axFilt, 'on');
        
        % --- ROW 5: Play Filtered Audio Button ---
        playFiltBtn = uibutton(sigGrid, 'Text', 'Play filtered audio', 'ButtonPushedFcn', @(btn,event) playSound('filtered'));
        playFiltBtn.Layout.Row = 5; 
        playFiltBtn.Layout.Column = 3;
        playFiltBtn.Enable = 'off';
        
       
        % NESTED FUNCTIONS FOR AUDIO PROCESSING
        function loadAudioFile()
            [file, path] = uigetfile({'*.wav;*.mp3;*.m4a;*.ogg', 'Audio Files (*.wav, *.mp3, *.m4a, *.ogg)'}, 'Select an Audio File');
            if isequal(file, 0)
                return; % User canceled
            end
            
            try
                [audioData, audioFs] = audioread(fullfile(path, file));
                
                % Convert to mono if it is a stereo audio file
                if size(audioData, 2) > 1
                    audioData = mean(audioData, 2);
                end
                
                % Plot Original Audio
                t = (0:length(audioData)-1) / audioFs;
                plot(axNoisy, t, audioData, 'Color', [0.8 0.2 0.2]);
                title(axNoisy,'Original Audio With Noise');
                xlim(axNoisy, [0 max(t)]);
                
                % Update Buttons
                playOrigBtn.Enable = 'on';
                playFiltBtn.Enable = 'off';
                cla(axFilt); % Clear lower plot until filtered
                
            catch ME
                uialert(sigFig, ['Error loading audio: ' ME.message], 'Load Error');
            end
        end

        function applyAudioFilter()
            if isempty(audioData)
                uialert(sigFig, 'Please load an audio file first.', 'Missing Data');
                return;
            end
            
            fApplyType = filtApplyDrop.Value;
            
            % Select coefficients based on dropdown
            if strcmp(fApplyType, 'Butterworth')
                num = b1; den = a1;
            elseif strcmp(fApplyType, 'Chebyshev-I')
                num = b2; den = a2;
            elseif strcmp(fApplyType, 'Chebyshev-II')
                num = b4; den = a4;
            else
                num = b3; den = a3;
            end
            
            try
                % Apply the designed filter
                filteredAudio = filter(num, den, audioData);
                
                % Plot Filtered Audio
                t = (0:length(filteredAudio)-1) / audioFs;
                plot(axFilt, t, filteredAudio, 'Color', [0.2 0.4 0.8]);
                title(axFilt, ['Filtered Audio (using ' fApplyType ' filter)']);
                xlim(axFilt, [0 max(t)]);
                
                playFiltBtn.Enable = 'on';
            catch ME
                uialert(sigFig, ['Error during filtering: ' ME.message], 'Processing Error');
            end
        end

        function playSound(type)
            clear sound; % Stops any currently playing audio so they don't overlap
            if strcmp(type, 'original') && ~isempty(audioData)
                sound(audioData, audioFs);
            elseif strcmp(type, 'filtered') && ~isempty(filteredAudio)
                sound(filteredAudio, audioFs);
            end
        end
    end
end