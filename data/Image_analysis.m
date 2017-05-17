filename = uigetfile({'*.tif','TIFF Image (*.tif)'});
% disp(filename)
re = '_[0-9]+\.tif';
% [m,nm] = regexp(filename,re,'match','split');
% disp(m)
% disp(nm)
tiff1 = Tiff(filename,'r');

imageData = tiff1.read();
tiff1.close();
% size(imageData) % [512, 512]
% figure
% surf(imageData)
kData = real(fft(imageData));

figure
subplot(2,1,1);
plot(sum(kData))
hold on;
subplot(2,1,2);
plot(sum(kData,2)','r')
% semilogy(sum(kData,2),'r')
hold off
% imshow(imageData);