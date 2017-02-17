clear all;
%GaPバックグラウンド拘束あり

% ビニングのサイズ
bs = 2;

% 動画像の読み込み
load_name = './f1000df200t2000.tif';
%load_name = './data/10.tif';
info = imfinfo(load_name); % tifファイルの情報取得
% uint8かuint16か
if info(1,1).BitDepth == 8
    datatype = 'uint8';
elseif info(1,1).BitDepth == 16
    datatype = 'uint16';
end
NN = size(info,1); % 時間
FF = info(1,1).Height/bs*info(1,1).Width/bs;%ビニング後のピクセル数
IMG = zeros(info(1,1).Height,info(1,1).Width,NN);%動画像を格納する配列の用意

for k = 1:NN % 画像読み込み
    IMG(:,:,k) = imread(load_name,'Tiff',k);
end
% 整数を実数に変換
IMG = double(IMG);

% binning 
IMG2 = binning(IMG,bs);

V = [];
for k = 1:NN % ２次元配列に変換
    TM = reshape(IMG2(:,:,k),FF,1);
    V = cat(2,V,TM);
end

% 時間平均を計算
aveIMG = mean(V,2);
AVI = reshape(aveIMG,info(1,1).Height/bs,info(1,1).Width/bs);
% 時間平均画像をプロット
figure(1)
subplot(1,1,1);
imagesc(AVI);


% 変分ベイズ法による計算

% ハイパーパラメータ
KK = 12; % 細胞数
hyp_alpha = ones(KK,1);
hyp_beta = ones(KK,1);
hyp_nu = 2.0.*ones(1,KK);
hyp_mu = ones(1,KK);

hb = ones(1,NN);

% 初期値の設定 これの修正が必要
wb_t = aveIMG;
w_t = gamrnd(ones(FF,1)*hyp_nu,(ones(FF,1)*hyp_mu)./(ones(FF,1)*hyp_nu));
h_t = gamrnd(hyp_alpha*ones(1,NN),(hyp_beta*ones(1,NN))./(hyp_alpha*ones(1,NN)));

t=0;
while t<100
    h_t1 = inv(w_t'*w_t)*w_t'*(V-wb_t*hb);
    h_t1 = max(h_t1,0);
    
    w_t1 = (inv(h_t1*h_t1')*h_t1*(V-wb_t*hb)')';
    w_t1 = max(w_t1,0);
    w_t1 = w_t1./(ones(FF,1)*sqrt(sum(w_t1.^2,1)));   
    
    wb_t1 = (inv(hb*hb')*hb*(V-w_t1*h_t1)')';
    wb_t1 = max(wb_t1,0);
    
    
    w_t = w_t1;
    wb_t = wb_t1;
    h_t = h_t1;
    t = t+1; 
end;

%[Ch_t,Cw_t] = CC_h(ih,h_t,w_t);

% ROIをプロット 周辺事後確率
BACK = wb_t;
BACK_H = hb;
ROI = w_t;
ROI_H = h_t;

ddx = ceil((KK+1)/ 5).*2;
figure(2);
RR = reshape(BACK,info(1,1).Height/bs,info(1,1).Width/bs);
subplot(ddx,5,1);
imagesc(RR);
colormap(gray);
subplot(ddx,5,1+5)
plot(BACK_H);

for k=1:KK
    cc = floor(k./5).*10 + mod(k,5)+1;
    RR = reshape(ROI(:,k),info(1,1).Height/bs,info(1,1).Width/bs);
    subplot(ddx,5,cc);
    imagesc(RR);
    colormap(gray);
    subplot(ddx,5,cc+5);
    plot(ROI_H(k,:));
end;

% ROIをプロット 周辺事後確率 （人口画像）
BACK = wb_t;
BACK_H = hb;
ROI = w;
ROI_H = h;

ddx = ceil((KK+1)/ 5).*2;
figure(2);
RR = reshape(BACK,info(1,1).Height,info(1,1).Width);
subplot(ddx,5,1);
imagesc(RR);
colormap(gray);
subplot(ddx,5,1+5)
plot(BACK_H);

for k=1:KK
    cc = floor(k./5).*10 + mod(k,5)+1;
    RR = reshape(ROI(:,k),info(1,1).Height,info(1,1).Width);
    subplot(ddx,5,cc);
    imagesc(RR);
    colormap(gray);
    subplot(ddx,5,cc+5);
    plot(ROI_H(k,:));
end;

