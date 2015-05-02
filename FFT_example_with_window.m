% Example Problem - Generating an FFT from a time signal - including windows
% Barukyah Shaparenko and John M. Cimbala

clear all
close all

% Given:

f_s = 100; % sampling frequency (Hz)
T = 3; % total actual sample time (s)

% The data points are provided below from an experiment.

%-------------------------------------------------------------------------
% Method 1: Explicit data values
%{
g = [-1.7527;-0.5650;0.8801;3.1924;1.2804;0.9006;-2.5214;-0.4022;-0.5707;3.2201;...
    1.6182;1.6789;-1.6800;-1.2799;-0.6754;1.6577;2.8238;1.3445;0.2188;-2.4080;...
    -0.3065;-0.1269;3.4371;1.3243;1.4993;-2.2204;-0.8385;-0.7018;2.3923;2.3541;...
    1.4472;-0.5389;-2.0954;-0.3373;0.4861;3.4043;1.1702;1.1327;-2.5331;-0.4727;...
    -0.5956;2.9921;1.8784;1.5123;-1.2921;-1.6372;-0.4200;1.2142;3.1516;1.1361;...
    0.5830;-2.5788;-0.2479;-0.2993;3.3843;1.4647;1.4632;-1.9404;-1.1379;-0.5031;...
    1.9807;2.7234;1.1986;-0.1127;-2.3873;-0.1655;0.1766;3.5180;1.1637;1.2459;...
    -2.4072;-0.6712;-0.5025;2.6665;2.2101;1.2855;-0.8562;-2.0011;-0.1830;0.8116;...
    3.4075;1.0069;0.8365;-2.6296;-0.3073;-0.3503;3.2047;1.7085;1.3196;-1.5749;...
    -1.4901;-0.2603;1.5459;3.0681;0.9810;0.2625;-2.5999;-0.0876;-0.0268;3.5108;...
    1.2836;1.2378;-2.1659;-0.9576;-0.3223;2.2687;2.5776;1.0368;-0.4276;-2.3220;...
    0.0043;0.4799;3.5548;0.9869;0.9764;-2.5523;-0.4817;-0.2863;2.9081;2.0285;...
    1.1155;-1.1554;-1.8696;-0.0190;1.1285;3.3595;0.8414;0.5497;-2.6941;-0.1145;...
    -0.1080;3.3703;1.5087;1.1153;-1.8304;-1.3144;-0.0945;1.8429;2.9446;0.8168;...
    -0.0435;-2.5741;0.1014;0.2506;3.5964;1.0825;0.9977;-2.3582;-0.7590;-0.1308;...
    2.5390;2.4113;0.8686;-0.7376;-2.2137;0.1780;0.7754;3.5589;0.7912;0.7141;...
    -2.6629;-0.2705;-0.0753;3.1193;1.8251;0.9263;-1.4359;-1.6979;0.1441;1.4335;...
    3.2692;0.6521;0.2644;-2.7102;0.0915;0.1445;3.4965;1.2824;0.9106;-2.0511;...
    -1.1085;0.0833;2.1231;2.7929;0.6387;-0.3359;-2.4978;0.2904;0.5265;3.6314;...
    0.8612;0.7718;-2.5072;-0.5253;0.0625;2.7757;2.2089;0.6895;-1.0183;-2.0713;...
    0.3590;1.0709;3.5055;0.5841;0.4551;-2.7312;-0.0399;0.1555;3.2861;1.5951;...
    0.7337;-1.6831;-1.5000;0.3309;1.7159;3.1453;0.4585;-0.0200;-2.6828;0.3079;...
    0.3899;3.5860;1.0483;0.7075;-2.2398;-0.8764;0.2679;2.3757;2.6035;0.4589;...
    -0.6147;-2.3949;0.4954;0.7921;3.6382;0.6334;0.5304;-2.6196;-0.2827;0.2611;...
    2.9759;1.9707;0.5130;-1.2770;-1.8909;0.5459;1.3436;3.4232;0.3691;0.2011;...
    -2.7549;0.2067;0.3736;3.4225;1.3449;0.5507;-1.8905;-1.2770;0.5102;1.9736;...
    2.9819;0.2649;-0.2821;-2.6196;0.5373;0.6310;3.6382;0.7961;0.4942;-2.3945;...
    -0.6221;0.4618;2.5994;2.3808;0.2766;-0.8754;-2.2452;0.7063;;1.0512;3.5907;...
    0.3854;0.3081;-2.6853;-0.0196;0.4589;3.1454;1.7110;0.3234;-1.5052;-1.6803;...
    0.7419;1.5967;3.2829;0.1547;-0.0389;-2.7274;0.4582;0.5815;3.5052;1.0675;0.3617];
%}

%-------------------------------------------------------------------------
%{
% Method 2: Import from Excel file
g = xlsread('FFT_Example_data_with_window.xls',1,'C55:C355');
%}

%-------------------------------------------------------------------------
% Method 3: Import from text file
fid1=fopen('FFT_Example_data_with_window.txt');
num_lines = 301;
read_data = textscan(fid1,'%f',num_lines);    
g = [read_data{1,:}];

% Calculated values:

DC = mean(g); % DC = mean value of input signal (V) (average of all the useful data)
N = f_s*T; % total actual number of data points
del_t = 1/f_s; % (s)
del_f = 1/T; % (Hz)
f_fold = f_s/2; % folding frequency = max frequency of FFT (Hz)
N_freq = N/2; % number of discrete frequencies

t = [0:del_t:T]'; % time, t (s)
frequency = [0:del_f:f_fold]'; % frequency (Hz)
g_uncoupled = g-DC; % uncoupled
u_Hann = 0.5*(1-cos(2*pi*t/T)); % u_Hanning(t)
g_Hann = g_uncoupled.*u_Hann; % g(t)*u_Hanning(t)
G_Hann = fft(g_Hann); % G(omega) with Hanning window
Magnitude_Hann = abs(G_Hann)*sqrt(8/3)/(N/2); % |F|*sqrt(8/3)/(N/2)
Magnitude_Hann(1) = Magnitude_Hann(1)/2 + DC; % (also divide the first one by 2, and add back the DC value)

locations(2:length(Magnitude_Hann)-1) = (Magnitude_Hann(2:end-1)>Magnitude_Hann(1:end-2))...
    & (Magnitude_Hann(2:end-1)>Magnitude_Hann(3:end))...
    & (Magnitude_Hann(2:end-1)>0.5);
A = Magnitude_Hann(locations(1:round(end/2)));
Freq = frequency(locations(1:round(end/2)));

%--------------------------------------------------------------------------

N_2 = 2^fix(log2(N)); % total useful number of data points
% [N_2 = nearest power of 2 less than or equal to actual N] (for Excel)
T_2 = N_2/f_s; % total useful sample time (s)
del_f_2 = 1/T_2; % (Hz)
N_freq_2 = N_2/2; % number of useful discrete frequencies

t_2 = [0:del_t:T_2]'; % time, t (s)
frequency_2 = [0:del_f_2:f_fold]'; % frequency (Hz)

DC_2 = mean(g(1:length(t_2)-1)); % DC = mean value of input signal (V) (average of all the useful data)
g_uncoupled_2 = g(1:length(t_2))-DC_2; % uncoupled
u_Hann_2 = 0.5*(1-cos(2*pi*t_2/T_2)); % u_Hanning(t)
g_Hann_2 = g_uncoupled_2.*u_Hann_2; % g(t)*u_Hanning(t)
G_Hann_2 = fft(g_Hann_2,N_2); % G(omega) with Hanning window
Magnitude_Hann_2 = abs(G_Hann_2)*sqrt(8/3)/(N_2/2); % |F|*sqrt(8/3)/(N/2)
Magnitude_Hann_2(1) = Magnitude_Hann_2(1)/2 + DC_2; % (also divide the first one by 2, and add back the DC value)

locations_2(2:length(Magnitude_Hann_2)-1) = (Magnitude_Hann_2(2:end-1)>Magnitude_Hann_2(1:end-2))...
    & (Magnitude_Hann_2(2:end-1)>Magnitude_Hann_2(3:end))...
    & (Magnitude_Hann_2(2:end-1)>0.5);
A_2 = Magnitude_Hann_2(locations_2(1:round(end/2)));
Freq_2 = frequency_2(locations_2(1:round(end/2)));

fprintf('\n----------------------\n');
fprintf('Answers:\n');
fprintf('Useful number of data points for FFT:\n');
fprintf('\tUseful N = \t\t\t\t\t\t\t\t%8g\t%10g\n',N,N_2);
fprintf('Calculations for the frequency spectrum:\n');
fprintf('\tFolding frequency = \t\t\t\t\t%8g Hz\t%10g Hz\n',f_fold,f_fold);
fprintf('\tFrequency resolution = del_f = 1/T = \t%8g Hz\t%10g Hz\n',del_f,del_f_2);
fprintf('Number of useful discrete frequencies = N/2 = %6g\t%10g\n',N/2,N_2/2);
fprintf('Frequency spectrum: See Figure 1.\n');
fprintf('Summary about the input signal:\n');
fprintf('\t\tDC offset ~ \t\t\t\t\t\t%8g V\t%10g V\n',Magnitude_Hann(1),Magnitude_Hann_2(1));
fprintf('\t\tfrequency ~ \t\t\t\t\t\t%8g Hz\t%10g Hz\n',Freq(1),Freq_2(1));
fprintf('\t\tAmplitude of first frequency ~ \t\t%8g V\t%10g V\n',A(1),A_2(1));
fprintf('\t\tSecond frequency ~ \t\t\t\t\t%8g Hz\t%10g Hz\n',Freq(2),Freq_2(2));
fprintf('\t\tAmplitude of second frequency ~ \t%8g V\t%10g V\n',A(2),A_2(2));

% Frequency Spectrum:
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(3)/4 scrsz(4)*1/8 scrsz(3)/2 scrsz(4)*4/5])
subplot(2,1,1)
hold on;
plot(frequency,Magnitude_Hann(1:length(frequency)),...
    '-bo','MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',2)
grid on;
xlabel('\bffrequency, \itf \rm\bf(Hz)')
ylabel('\bf|F|')
title({'\bfFFT Frequency Spectrum';['(all ' num2str(N) ' points)']},'FontSize',16)
hold off;

subplot(2,1,2)
hold on;
plot(frequency_2,Magnitude_Hann_2(1:length(frequency_2)),...
    '-bo','MarkerFaceColor','r','MarkerEdgeColor','r','LineWidth',2)
grid on;
xlabel('\bffrequency, \itf \rm\bf(Hz)')
ylabel('\bf|F|')
title({'\bfFFT Frequency Spectrum';['(using only ' num2str(N_2) ' points)']},'FontSize',16)
hold off;

site = '"http://www.mne.psu.edu/me345/Lectures/FFT_Example_data_with_window.xls"';
title = 'FFT_Example_data_with_window.xls';
fprintf(['\nView corresponding Excel file: <a href = ' site '>' title '</a>\n']);