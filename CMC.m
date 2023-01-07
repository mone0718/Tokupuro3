% 特プロ　課題②
% start from 2022/03  
%　何チャンネルに何のデータが入っているかを必ず確認すること
% ch1 = Torque
% ch2 = EMG 
% ch3 = EEG Cz
% ch4 = EEG FCz
% ch5 = EEG C1
% ch6 = EEG CPz
% ch7 = EEG C2

% ch1:Torque ch2~6:EEG(ch2がCz) ch7.8:EMG

% EMG LP = 500 Hz, HP = 1 Hz
% EEG LP = 100 Hz, HP = 0.5 Hz

% EMG Sens HI (x1000)
% EEG Sens Low (x1000)

%被験者名
defaultanswer = {'Yokota'};
subject = inputdlg({'subject'},'Input the answer',1,defaultanswer);
subject_name = char(subject(1));

%サンプリング周波数
fs = 1000;
%窓長
nfft = 1000;
%フーリエ変換時のOverlap率を指定（コヒーレンス計算の場合は基本0）
Overlap = 0;

%解析するデータ（matファイル）を選択し、読み込む
[fname,pname]=uigetfile('*.mat','解析するデータを選択してください');
  FP=[fname pname];
  if fname==0;return;end
   %fnameがファイル名／pnameはファイルのある場所（ディレクトリ）
   load([pname fname]);

%フィルタリング
%【課題②】EEG/EMGそれぞれの生波形を見て、必要であればハムカットフィルタなどの処理をしてみよう
data_filtered = data;
a = zeros(9,7); %9行7列の全要素0の行列
b = zeros(9,7);
for i = 1:9
    [b(i,:),a(i,:)] = butter(3,[i*50-1 i*50+1]/500,'stop');
    data_filtered = filtfilt(b(i,:),a(i,:),data_filtered);
end

%EEGローパス 100Hz
[b_low,a_low] = butter(3,100/500,"low");
data_low_filtered = filtfilt(b_low,a_low,data_filtered);

%計測データの定義
%EMGは1000μV→1Vなので、マイクロボルト単位に変換（1000倍）
%EEGは100μV→1Vなので、マイクロボルト単位に変換（100倍）
Force = data_filtered(:,1);
EMG = data_filtered(:,7); %ここの*1000
EEG_Cz = data_low_filtered(:,2)*100;
EEG_FCz = data_low_filtered(:,3)*100;
EEG_C1 = data_low_filtered(:,4)*100;
EEG_CPz = data_low_filtered(:,5)*100;
EEG_C2 = data_low_filtered(:,6)*100;
 

%EMGのトレンド除去（平均を引く）
EMG = (EMG-mean(EMG))*1000;
%全波整流
rEMG = abs(EMG);

%EEGのトレンド除去（detrend関数を用いる）
%【課題①】detrendを用いてそれぞれのchデータのトレンド除去をしてみよう／detrend前後のシグナルを比較してみよう
dEEG_Cz = detrend(EEG_Cz);
dEEG_FCz = detrend(EEG_FCz);
dEEG_C1 = detrend(EEG_C1);
dEEG_CPz = detrend(EEG_CPz);
dEEG_C2 = detrend(EEG_C2);

%ラプラシアン導出
%Czの脳波から残り4chの脳波の平均をひく
EEG = dEEG_Cz - (dEEG_FCz + dEEG_CPz + dEEG_C1 + dEEG_C2) / 4;
%EEG = EEG_Cz - (EEG_FCz + EEG_CPz + EEG_C1 + EEG_C2) / 4;


%時間行列を作成
time = 0:1/fs:length(Force)/fs-1/fs;


figure('Position',[1 1 400 800]);
subplot(4,1,1); %subplot(m,n,p):現在のFigureをm行n列のグリッドに分割し、pで指定された位置に図示
plot(time,Force,'LineWidth',1.5);
ylabel('Force (V)','FontName','Arial','Fontsize',12);
xlabel('time (s)','FontName','Arial','Fontsize',12);

subplot(4,1,2);
plot(time,rEMG,'LineWidth',1.5);
ylabel('EMG (\muV)','FontName','Arial','Fontsize',12);
xlabel('time (s)','FontName','Arial','Fontsize',12);

subplot(4,1,3);
plot(time,EMG,'LineWidth',1.5);
ylabel('rEMG (\muV)','FontName','Arial','Fontsize',12);
xlabel('time (s)','FontName','Arial','Fontsize',12);

subplot(4,1,4);
plot(time,EEG,'LineWidth',1.5);
ylabel('EEG (\muV)','FontName','Arial','Fontsize',12,'LineWidth',2);
xlabel('time (s)','FontName','Arial','Fontsize',12);
 
%figureを閉じるまでプログラムが一時停止
uiwait;

raw_default_interval = {'50'};
start_end_0 = inputdlg({'start'},'生データ区間を設定してください',1,raw_default_interval);
second_raw_data_start = str2double(char(start_end_0(1)));
second_raw_data_end = str2double(char(start_end_0(1)))+0.5;

ms_raw_data_start = second_raw_data_start * fs + 1;
ms_raw_data_end = second_raw_data_end * fs;

original_force = Force;
original_rEMG = rEMG;
original_EMG = EMG;
original_EEG = EEG;

time = time(ms_raw_data_start:ms_raw_data_end);
% Force = original_force(ms_raw_data_start:ms_raw_data_end);
% rEMG = original_rEMG(ms_raw_data_start:ms_raw_data_end);
EMG = original_EMG(ms_raw_data_start:ms_raw_data_end);
EEG = original_EEG(ms_raw_data_start:ms_raw_data_end);

% figure('Position',[1 1 400 800]);
% defaultanswer = {'50'};
% startend = inputdlg({'start'},'生データ開始時間',1,defaultanswer);
% start_time = str2double(char(startend(1)));

% rEMG = rEMG(start_time*fs+1:(start_time+0.5)*fs);
% EEG = EEG(start_time*fs+1:(start_time+0.5)*fs); 

interval_time = time - second_raw_data_start + 0.0000001;

%uiwait;

%%% EEG,EMGの生データ
figure('Position',[1 1 500 500]);

subplot(2,1,1);
plot(interval_time,EEG,'LineWidth',2);
xlim([0,0.5]);
ylim([-12,12]);
xticks(0:0.1:0.5);
yticks([-12,0,12]);
ylabel('EEG (\muV)','FontName','Arial');
%xlabel('time (s)','FontName','Arial');

fontsize = 22; 
h = gca; 
set(h,'fontsize',fontsize);

subplot(2,1,2);
plot(interval_time,EMG,'LineWidth',2);
xlim([0,0.5]);
ylim([-1000,1000]);
xticks(0:0.1:0.5);
yticks([-1000,0,1000]);
ylabel('EMG (\muV)','FontName','Arial');
xlabel('time (s)','FontName','Arial');

fontsize = 22; 
h = gca; 
set(h,'fontsize',fontsize);

uiwait;


%解析対象区間を設定（解析のための60秒を選定）
defaultanswer = {'15','75'};
startend = inputdlg({'start','end'},'解析区間の60秒を設定してください',1,defaultanswer);
start_time = str2double(char(startend(1)));
end_time = str2double(char(startend(2)));

%解析対象区間の60秒分のデータを切り出し
Force = original_force(start_time*fs+1:end_time*fs);
rEMG = original_rEMG(start_time*fs+1:end_time*fs);
EEG = original_EEG(start_time*fs+1:end_time*fs);

%コヒーレンス解析
[Coh,F] = mscohere(EEG,rEMG,hanning(nfft),Overlap,nfft,fs);

%コヒーレンスの有意水準計算(ボンフェローニ補正有）
%周波数分解能
freq_resol = fs/nfft;
%解析対象は3-50Hzとする
f_3 = 1+floor(3/freq_resol);%解析対象の下限周波数...ここで導き出される解番目のF行列の数値が、3にもっとも近いことを確認
f_50 = 1+floor(50/freq_resol);%解析対象の上限周波数...ここで導き出される解番目のF行列の数値が、50にもっとも近いことを確認
%解析窓数の算出（解析区間のデータから窓長nfftのデータ窓が何個得られるか？）
num_window = floor(length(Force)/nfft);

%【課題③】Ushiyama et al., J Neurophysiol 2011の論文にある有意水準の式を確認
SL=1-(0.05/((f_50-f_3)+1))^(1/(num_window-1));

%CMCの定量評価
%【課題④】15-35Hzのベータ帯におけるCMCの最大値（CMCmax）/その周波数（PF）を求める
beta_C = Coh(15:35); %配列の15番目から35番目まで抜き出す
[CMCmax,pf] = max(beta_C);
PF = pf + 13;

%【課題⑤】15-35Hzのベータ帯におけるCMCの面積（(beta_)CMCarea）を求める
CMCarea = sum(beta_C);


%%% CMC,パワースペクトル
figure1 = figure('Position',[1 1 500 700]);
subplot(3,1,3);
area(F,Coh);
%有意線をグラフ内に描画
hold on;
plot(linspace(0,fs/2,length(time)),repmat(SL,1,length(time)),'r','LineWidth',1.5);
hold off;

xlim([0,50]);%50Hzまで描画
ylim([0,0.6]);%上限は得られたデータによって適宜修正
yticks([0,0.6]);
xlabel('Frequency(Hz)','FontName','Arial');
ylabel('Coherence','FontName','Arial');
title('CMC','FontName','Arial','FontSize',18);

fontsize = 21; 
h = gca; 
set(h,'fontsize',fontsize);




%【課題⑥】pwelch関数を用いてEEGとrEMGのそれぞれのパワースペクトルを計算する
pEEG = pwelch(EEG,hanning(nfft),Overlap,nfft,fs);
pEMG = pwelch(rEMG,hanning(nfft),Overlap,nfft,fs);

% %3-500HzにおけるEEG-PSD
% C = Coh(3:50);
% CMCarea = sum(C);

%3-500HzにおけるEMG-PSD
EMG_bPSD = sum(pEMG(15:35)) / sum(pEMG(3:500));

%β-PSD
%beta_PSD = beta_CMCarea / CMCarea;



%【課題⑦】得られたEEGとEMGのスペクトルを描画して、CMCスペクトルと比較してみる
%figure('Position',[1 1 500 500]);
subplot(2,1,1);
plot(F,pEEG,'LineWidth',2);
xlim([0,50]);
ylim([0,0.15]);
%xlabel('Frequency(Hz)','FontName','Arial');
ylabel(['EEG PSD', char(10), '(\muV^2/Hz)'],'FontName','Arial');
title('EEG Power Spectral','FontName','Arial');

fontsize = 20; 
h = gca; 
set(h,'fontsize',fontsize);

subplot(2,1,2);
plot(F,pEMG,'LineWidth',2);
xlim([0,50]);
ylim([0,500]);
xlabel('Frequency(Hz)','FontName','Arial');
ylabel(['EMG PSD', char(10), '(\muV^2/Hz)'],'FontName','Arial');
title('EMG Power Spectral','FontName','Arial');

fontsize = 20; 
h = gca; 
set(h,'fontsize',fontsize);
%h.YLabel.FontSize = 26;




%ファイルの保存
output_filename = sprintf('%s_CMC',subject_name);
save(output_filename,'F','pEEG','pEMG','Coh',"CMCmax","CMCarea","PF",'EMG_bPSD');

fileName = "result_.txt";
fileID = fopen(fileName, 'a'); %w:上書き a:末尾に追加

% %s:str型のデータ %f:浮動小数点
fprintf(fileID, '%s CMCmax: %0.4f, PF: %2.0f, CMCarea: %0.4f\n', subject_name, CMCmax, PF, CMCarea);

%Figureの保存
output_figname = sprintf('%s_CMC',subject_name);
saveas(figure1,output_figname,'fig');


