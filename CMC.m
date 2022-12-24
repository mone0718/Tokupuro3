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

% EMG LP = 500 Hz, HP = 5 Hz
% EEG LP = 200 Hz, HP = 0.5 Hz

% EMG Sens HI (x1000)
% EEG Sens Low (x1000)

%�팱�Җ�
defaultanswer = {'Egashira'};
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

figure('Position',[1 1 400 700]);
subplot(4,1,1); %subplot(m,n,p):���݂�Figure��m�sn��̃O���b�h�ɕ������Ap�Ŏw�肳�ꂽ�ʒu�ɐ}��
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
 
%figure�����܂Ńv���O�������ꎞ��~
uiwait;

%��͑Ώۋ�Ԃ�ݒ�i��͂̂��߂�60�b��I��j
defaultanswer = {'15','75'};
startend = inputdlg({'start','end'},'��͋�Ԃ�60�b��ݒ肵�Ă�������',1,defaultanswer);
start_time = str2num(char(startend(1)));
end_time = str2num(char(startend(2)));

%��͑Ώۋ�Ԃ�60�b���̃f�[�^��؂�o��
Force = Force(start_time*fs+1:end_time*fs);
rEMG = rEMG(start_time*fs+1:end_time*fs);
EEG = EEG(start_time*fs+1:end_time*fs);

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
C = Coh(15:35); %�z���15�Ԗڂ���35�Ԗڂ܂Ŕ����o��
[CMCmax,pf] = max(C);
PF = pf + 13;

%�y�ۑ�D�z15-35Hz�̃x�[�^�тɂ�����CMC�̖ʐρiCMCarea�j�����߂�
CMCarea = sum(C);

%CMC�̕`��
figure1 = figure('Position',[1 1 400 700]);
subplot(3,1,1);
area(F,Coh);
%�L�Ӑ����O���t���ɕ`��
hold on;
plot(linspace(0,fs/2,length(time)),repmat(SL,1,length(time)),'r','LineWidth',0.5);
hold off;
xlim([0,50]);%50Hz�܂ŕ`��
ylim([0,0.6]);%����͓���ꂽ�f�[�^�ɂ���ēK�X�C��
yticks(0:0.1:0.6);
xlabel('Frequency(Hz)','FontName','Arial','Fontsize',12);
ylabel('Coherence','FontName','Arial','Fontsize',12);
title('CMC','FontName','Arial','Fontsize',20)



%�y�ۑ�E�zpwelch�֐���p����EEG��rEMG�̂��ꂼ��̃p���[�X�y�N�g�����v�Z����
pEEG = pwelch(EEG,hanning(nfft),Overlap,nfft,fs);
pEMG = pwelch(rEMG,hanning(nfft),Overlap,nfft,fs);


%�y�ۑ�F�z����ꂽEEG��EMG�̃X�y�N�g����`�悵�āACMC�X�y�N�g���Ɣ�r���Ă݂�
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


%�t�@�C���̕ۑ�
output_filename = sprintf('%s_CMC',subject_name);
save(output_filename,'F','pEEG','pEMG','Coh',"CMCmax","CMCarea","PF");

% fileName = "result_filterd.txt";
% fileID = fopen(fileName, 'a'); %w:�㏑�� a:�����ɒǉ�

% %s:str�^�̃f�[�^ %f:���������_
fprintf(fileID, '%s CMCmax: %0.4f, PF: %2.0f, CMCarea: %0.4f\n', subject_name, CMCmax, PF, CMCarea);

%Figure�̕ۑ�
output_figname = sprintf('%s_CMC',subject_name);
saveas(figure1,output_figname,'fig');


