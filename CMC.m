% 特プロ　課題�A
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

% EMG LP = 500 Hz, HP = 5 Hz
% EEG LP = 200 Hz, HP = 0.5 Hz

% EMG Sens HI (x1000)
% EEG Sens Low (x1000)

%被験者名
defaultanswer = {'Egashira'};
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
%【課題�A】EEG/EMGそれぞれの生波形を見て、必要であればハムカットフィルタなどの処理をしてみよう
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
%【課題�@】detrendを用いてそれぞれのchデータのトレンド除去をしてみよう／detrend前後のシグナルを比較してみよう
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

figure('Position',[1 1 400 700]);
subplot(4,1,1); %subplot(m,n,p):現在のFigureをm行n列のグリッドに分割し、pで指定された位置に図示
plot(time,Force);
ylabel('Force (V)','FontName','Arial','Fontsize',12);
xlabel('time (s)','FontName','Arial','Fontsize',12);

subplot(4,1,2);
plot(time,EMG,'LineWidth',1.5);
ylabel('rEMG (\muV)','FontName','Arial','Fontsize',12);
xlabel('time (s)','FontName','Arial','Fontsize',12);

subplot(4,1,3);
plot(time,rEMG);
ylabel('EMG (\muV)','FontName','Arial','Fontsize',12);
xlabel('time (s)','FontName','Arial','Fontsize',12);

subplot(4,1,4);
plot(time,EEG,'LineWidth',1.5);
ylabel('EEG (\muV)','FontName','Arial','Fontsize',12,'LineWidth',2);
xlabel('time (s)','FontName','Arial','Fontsize',12);
 
%figureを閉じるまでプログラムが一時停止
uiwait;

%解析対象区間を設定（解析のための60秒を選定）
defaultanswer = {'15','75'};
startend = inputdlg({'start','end'},'解析区間の60秒を設定してください',1,defaultanswer);
start_time = str2num(char(startend(1)));
end_time = str2num(char(startend(2)));

%解析対象区間の60秒分のデータを切り出し
Force = Force(start_time*fs+1:end_time*fs);
rEMG = rEMG(start_time*fs+1:end_time*fs);
EEG = EEG(start_time*fs+1:end_time*fs);

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

%【課題�B】Ushiyama et al., J Neurophysiol 2011の論文にある有意水準の式を確認
SL=1-(0.05/((f_50-f_3)+1))^(1/(num_window-1));

%CMCの定量評価
%【課題�C】15-35Hzのベータ帯におけるCMCの最大値（CMCmax）/その周波数（PF）を求める
C = Coh(15:35); %配列の15番目から35番目まで抜き出す
[CMCmax,pf] = max(C);
PF = pf + 13;

%【課題�D】15-35Hzのベータ帯におけるCMCの面積（CMCarea）を求める
CMCarea = sum(C);

%CMCの描画
figure1 = figure('Position',[1 1 400 700]);
subplot(3,1,1);
area(F,Coh);
%有意線をグラフ内に描画
hold on;
plot(linspace(0,fs/2,length(time)),repmat(SL,1,length(time)),'r','LineWidth',0.5);
hold off;
xlim([0,50]);%50Hzまで描画
ylim([0,0.6]);%上限は得られたデータによって適宜修正
yticks(0:0.1:0.6);
xlabel('Frequency(Hz)','FontName','Arial','Fontsize',12);
ylabel('Coherence','FontName','Arial','Fontsize',12);
title('CMC','FontName','Arial','Fontsize',20)



%【課題�E】pwelch関数を用いてEEGとrEMGのそれぞれのパワースペクトルを計算する
pEEG = pwelch(EEG,hanning(nfft),Overlap,nfft,fs);
pEMG = pwelch(rEMG,hanning(nfft),Overlap,nfft,fs);


%【課題�F】得られたEEGとEMGのスペクトルを描画して、CMCスペクトルと比較してみる
subplot(3,1,2);
plot(F,pEEG,'LineWidth',1);
xlim([0,50]);
ylim([0,0.16]);
xlabel('Frequency(Hz)','FontName','Arial','Fontsize',12);
ylabel('EEG PSD (\muV^2/Hz)','FontName','Arial','Fontsize',12);

subplot(3,1,3);
plot(F,pEMG,'LineWidth',1);
xlim([0,50]);
ylim([0,600]);
xlabel('Frequency(Hz)','FontName','Arial','Fontsize',12);
ylabel('EMG PSD (\muV^2/Hz)','FontName','Arial','Fontsize',12);


%ファイルの保存
output_filename = sprintf('%s_CMC',subject_name);
save(output_filename,'F','pEEG','pEMG','Coh',"CMCmax","CMCarea","PF");

% fileName = "result_filterd.txt";
% fileID = fopen(fileName, 'a'); %w:上書き a:末尾に追加

% %s:str型のデータ %f:浮動小数点
fprintf(fileID, '%s CMCmax: %0.4f, PF: %2.0f, CMCarea: %0.4f\n', subject_name, CMCmax, PF, CMCarea);

%Figureの保存
output_figname = sprintf('%s_CMC',subject_name);
saveas(figure1,output_figname,'fig');


