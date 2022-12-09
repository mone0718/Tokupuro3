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

% EMG LP = ? Hz, HP = ? Hz
% EEG LP = ? Hz, HP = ? Hz

% EMG Sens HI (x1000)
% EEG Sens Low (x1000)

%被験者名
defaultanswer = {'Miyamoto'};
subject = inputdlg({'subject'},'Input the answer',1,defaultanswer);
subject_name = char(subject(1));

%サンプリング周波数
fs = 1000;
%窓長
nfft = 1000;
%フーリエ変換時のOverlap率を指定（コヒーレンス計算の場合は基本0）
Overlap = 0;

%解析するデータ（matファイル）を選択し、読み込む
[fname pname]=uigetfile('*.mat','解析するデータを選択してください')
  FP=[fname pname]
  if fname==0;return;end
   %fnameがファイル名／pnameはファイルのある場所（ディレクトリ）
   load([pname fname]);
 
 %計測データの定義
 %EMGは1000μV→1Vなので、マイクロボルト単位に変換（1000倍）
 %EMGは100μV→1Vなので、マイクロボルト単位に変換（100倍）
 Force = data(:,1);
 EMG = data(:,2)*1000;
 EEG_Cz = data(:,3)*100;
 EEG_FCz = data(:,4)*100;
 EEG_C1 = data(:,5)*100;
 EEG_CPz = data(:,6)*100;
 EEG_C2 = data(:,7)*100;
 
 
 %EMGのトレンド除去（平均を引く）
 EMG = (EMG-mean(EMG))*1000;
 %全波整流
 rEMG = abs(EMG);
 
 %EEGのトレンド除去（detrend関数を用いる）
 %【課題①】detrendを用いてそれぞれのchデータのトレンド除去をしてみよう／detrend前後のシグナルを比較してみよう

 
 
 %フィルタリング
 %【課題②】EEG/EMGそれぞれの生波形を見て、必要であればハムカットフィルタなどの処理をしてみよう
 
 
 
 %ラプラシアン導出
 %Czの脳波から残り4chの脳波の平均をひく
 EEG = EEG_Cz-(EEG_FCz+EEG_CPz+EEG_C1+EEG_C2)/4;
 
 %時間行列を作成
 time = 0:1/fs:length(Force)/fs-1/fs;
 
 figure1 = figure('Position',[1 1 500 700])
 subplot(3,1,1)
 plot(time,Force);
 ylabel('Force (V)','FontName','Arial','Fontsize',12);
 xlabel('time (s)','FontName','Arial','Fontsize',12);

 subplot(3,1,2)
 plot(time,rEMG);
 ylabel('EMG (\muV)','FontName','Arial','Fontsize',12);
 xlabel('time (s)','FontName','Arial','Fontsize',12);
 
 subplot(3,1,3)
 ylabel('EEG (\muV)','FontName','Arial','Fontsize',12);
 xlabel('time (s)','FontName','Arial','Fontsize',12);
 
%figureを閉じるまでプログラムが一時停止
 uiwait;

%解析対象区間を設定（解析のための60秒を選定）
defaultanswer = {'25','85'};
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
%周波数分解能%
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


%【課題⑤】15-35Hzのベータ帯におけるCMCの面積（CMCarea）を求める



%CMCの描画
figure1 = figure('Position',[1 1 500 500])
area(F,Coh);
hold on;
%有意線をグラフ内に描画
plot(linspace(0,fs/2,length(time)),repmat(SL,1,length(time)),'r','LineWidth',0.5);
hold off;
xlim([0,50]);%50Hzまで描画
ylim([0,0.5]);%上限は得られたデータによって適宜修正
yticks([0:0.1:0.5]);
xlabel('Frequency(Hz)','FontName','Arial','Fontsize',15);
ylabel('Coherence','FontName','Arial','Fontsize',15);
title('CMC','FontName','Arial','Fontsize',25)




%【課題⑥】pwelch関数を用いてEEGとrEMGのそれぞれのパワースペクトルを計算する



%【課題⑦】得られたEEGとEMGのスペクトルを描画して、CMCスペクトルと比較してみる




%ファイルの保存
output_filename = sprintf('%s_CMC',subject_name);
save(output_filename,'F','PEEG','PEMG','Coh');


