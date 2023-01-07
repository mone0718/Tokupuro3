% ���v���@�ۑ�A
% start from 2022/03  
%�@���`�����l���ɉ��̃f�[�^�������Ă��邩��K���m�F���邱��
% ch1 = Torque
% ch2 = EMG 
% ch3 = EEG Cz
% ch4 = EEG FCz
% ch5 = EEG C1
% ch6 = EEG CPz
% ch7 = EEG C2

% ch1:Torque ch2~6:EEG(ch2��Cz) ch7.8:EMG

% EMG LP = 500 Hz, HP = 1 Hz
% EEG LP = 100 Hz, HP = 0.5 Hz

% EMG Sens HI (x1000)
% EEG Sens Low (x1000)

%�팱�Җ�
defaultanswer = {'Yokota'};
subject = inputdlg({'subject'},'Input the answer',1,defaultanswer);
subject_name = char(subject(1));

%�T���v�����O���g��
fs = 1000;
%����
nfft = 1000;
%�t�[���G�ϊ�����Overlap�����w��i�R�q�[�����X�v�Z�̏ꍇ�͊�{0�j
Overlap = 0;

%��͂���f�[�^�imat�t�@�C���j��I�����A�ǂݍ���
[fname,pname]=uigetfile('*.mat','��͂���f�[�^��I�����Ă�������');
  FP=[fname pname];
  if fname==0;return;end
   %fname���t�@�C�����^pname�̓t�@�C���̂���ꏊ�i�f�B���N�g���j
   load([pname fname]);

%�t�B���^�����O
%�y�ۑ�A�zEEG/EMG���ꂼ��̐��g�`�����āA�K�v�ł���΃n���J�b�g�t�B���^�Ȃǂ̏��������Ă݂悤
data_filtered = data;
a = zeros(9,7); %9�s7��̑S�v�f0�̍s��
b = zeros(9,7);
for i = 1:9
    [b(i,:),a(i,:)] = butter(3,[i*50-1 i*50+1]/500,'stop');
    data_filtered = filtfilt(b(i,:),a(i,:),data_filtered);
end

%EEG���[�p�X 100Hz
[b_low,a_low] = butter(3,100/500,"low");
data_low_filtered = filtfilt(b_low,a_low,data_filtered);

%�v���f�[�^�̒�`
%EMG��1000��V��1V�Ȃ̂ŁA�}�C�N���{���g�P�ʂɕϊ��i1000�{�j
%EEG��100��V��1V�Ȃ̂ŁA�}�C�N���{���g�P�ʂɕϊ��i100�{�j
Force = data_filtered(:,1);
EMG = data_filtered(:,7); %������*1000
EEG_Cz = data_low_filtered(:,2)*100;
EEG_FCz = data_low_filtered(:,3)*100;
EEG_C1 = data_low_filtered(:,4)*100;
EEG_CPz = data_low_filtered(:,5)*100;
EEG_C2 = data_low_filtered(:,6)*100;
 

%EMG�̃g�����h�����i���ς������j
EMG = (EMG-mean(EMG))*1000;
%�S�g����
rEMG = abs(EMG);

%EEG�̃g�����h�����idetrend�֐���p����j
%�y�ۑ�@�zdetrend��p���Ă��ꂼ���ch�f�[�^�̃g�����h���������Ă݂悤�^detrend�O��̃V�O�i�����r���Ă݂悤
dEEG_Cz = detrend(EEG_Cz);
dEEG_FCz = detrend(EEG_FCz);
dEEG_C1 = detrend(EEG_C1);
dEEG_CPz = detrend(EEG_CPz);
dEEG_C2 = detrend(EEG_C2);

%���v���V�A�����o
%Cz�̔]�g����c��4ch�̔]�g�̕��ς��Ђ�
EEG = dEEG_Cz - (dEEG_FCz + dEEG_CPz + dEEG_C1 + dEEG_C2) / 4;
%EEG = EEG_Cz - (EEG_FCz + EEG_CPz + EEG_C1 + EEG_C2) / 4;


%���ԍs����쐬
time = 0:1/fs:length(Force)/fs-1/fs;


figure('Position',[1 1 400 800]);
subplot(4,1,1); %subplot(m,n,p):���݂�Figure��m�sn��̃O���b�h�ɕ������Ap�Ŏw�肳�ꂽ�ʒu�ɐ}��
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
 
%figure�����܂Ńv���O�������ꎞ��~
uiwait;

raw_default_interval = {'50'};
start_end_0 = inputdlg({'start'},'���f�[�^��Ԃ�ݒ肵�Ă�������',1,raw_default_interval);
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
% startend = inputdlg({'start'},'���f�[�^�J�n����',1,defaultanswer);
% start_time = str2double(char(startend(1)));

% rEMG = rEMG(start_time*fs+1:(start_time+0.5)*fs);
% EEG = EEG(start_time*fs+1:(start_time+0.5)*fs); 

interval_time = time - second_raw_data_start + 0.0000001;

%uiwait;

%%% EEG,EMG�̐��f�[�^
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


%��͑Ώۋ�Ԃ�ݒ�i��͂̂��߂�60�b��I��j
defaultanswer = {'15','75'};
startend = inputdlg({'start','end'},'��͋�Ԃ�60�b��ݒ肵�Ă�������',1,defaultanswer);
start_time = str2double(char(startend(1)));
end_time = str2double(char(startend(2)));

%��͑Ώۋ�Ԃ�60�b���̃f�[�^��؂�o��
Force = original_force(start_time*fs+1:end_time*fs);
rEMG = original_rEMG(start_time*fs+1:end_time*fs);
EEG = original_EEG(start_time*fs+1:end_time*fs);

%�R�q�[�����X���
[Coh,F] = mscohere(EEG,rEMG,hanning(nfft),Overlap,nfft,fs);

%�R�q�[�����X�̗L�Ӑ����v�Z(�{���t�F���[�j�␳�L�j
%���g������\
freq_resol = fs/nfft;
%��͑Ώۂ�3-50Hz�Ƃ���
f_3 = 1+floor(3/freq_resol);%��͑Ώۂ̉������g��...�����œ����o������Ԗڂ�F�s��̐��l���A3�ɂ����Ƃ��߂����Ƃ��m�F
f_50 = 1+floor(50/freq_resol);%��͑Ώۂ̏�����g��...�����œ����o������Ԗڂ�F�s��̐��l���A50�ɂ����Ƃ��߂����Ƃ��m�F
%��͑����̎Z�o�i��͋�Ԃ̃f�[�^���瑋��nfft�̃f�[�^�����������邩�H�j
num_window = floor(length(Force)/nfft);

%�y�ۑ�B�zUshiyama et al., J Neurophysiol 2011�̘_���ɂ���L�Ӑ����̎����m�F
SL=1-(0.05/((f_50-f_3)+1))^(1/(num_window-1));

%CMC�̒�ʕ]��
%�y�ۑ�C�z15-35Hz�̃x�[�^�тɂ�����CMC�̍ő�l�iCMCmax�j/���̎��g���iPF�j�����߂�
beta_C = Coh(15:35); %�z���15�Ԗڂ���35�Ԗڂ܂Ŕ����o��
[CMCmax,pf] = max(beta_C);
PF = pf + 13;

%�y�ۑ�D�z15-35Hz�̃x�[�^�тɂ�����CMC�̖ʐρi(beta_)CMCarea�j�����߂�
CMCarea = sum(beta_C);


%%% CMC,�p���[�X�y�N�g��
figure1 = figure('Position',[1 1 500 700]);
subplot(3,1,3);
area(F,Coh);
%�L�Ӑ����O���t���ɕ`��
hold on;
plot(linspace(0,fs/2,length(time)),repmat(SL,1,length(time)),'r','LineWidth',1.5);
hold off;

xlim([0,50]);%50Hz�܂ŕ`��
ylim([0,0.6]);%����͓���ꂽ�f�[�^�ɂ���ēK�X�C��
yticks([0,0.6]);
xlabel('Frequency(Hz)','FontName','Arial');
ylabel('Coherence','FontName','Arial');
title('CMC','FontName','Arial','FontSize',18);

fontsize = 21; 
h = gca; 
set(h,'fontsize',fontsize);




%�y�ۑ�E�zpwelch�֐���p����EEG��rEMG�̂��ꂼ��̃p���[�X�y�N�g�����v�Z����
pEEG = pwelch(EEG,hanning(nfft),Overlap,nfft,fs);
pEMG = pwelch(rEMG,hanning(nfft),Overlap,nfft,fs);

% %3-500Hz�ɂ�����EEG-PSD
% C = Coh(3:50);
% CMCarea = sum(C);

%3-500Hz�ɂ�����EMG-PSD
EMG_bPSD = sum(pEMG(15:35)) / sum(pEMG(3:500));

%��-PSD
%beta_PSD = beta_CMCarea / CMCarea;



%�y�ۑ�F�z����ꂽEEG��EMG�̃X�y�N�g����`�悵�āACMC�X�y�N�g���Ɣ�r���Ă݂�
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




%�t�@�C���̕ۑ�
output_filename = sprintf('%s_CMC',subject_name);
save(output_filename,'F','pEEG','pEMG','Coh',"CMCmax","CMCarea","PF",'EMG_bPSD');

fileName = "result_.txt";
fileID = fopen(fileName, 'a'); %w:�㏑�� a:�����ɒǉ�

% %s:str�^�̃f�[�^ %f:���������_
fprintf(fileID, '%s CMCmax: %0.4f, PF: %2.0f, CMCarea: %0.4f\n', subject_name, CMCmax, PF, CMCarea);

%Figure�̕ۑ�
output_figname = sprintf('%s_CMC',subject_name);
saveas(figure1,output_figname,'fig');


