f=imread('C:\Users\Saurav\Desktop\_MINOR\MINOR FINAL\IMAGES\image8.png'); % Reading the number plate image.
figure;imshow(f);
f=imresize(f,[400 NaN]); % Resizing the image keeping aspect ratio same.
g=rgb2gray(f); % Converting the RGB (color) image to gray (intensity).
g=medfilt2(g,[3 3]); % Median filtering to remove noise.
se=strel('disk',1); % Structural element (disk of radius 1) for morphological processing.(don't know)
gi=imdilate(g,se); % Dilating the gray image with the structural element.
ge=imerode(g,se);% Eroding the gray image with structural element.
gdiff=imsubtract(gi,ge); % Morphological Gradient for edges enhancement.
gdiff=mat2gray(gdiff); % Converting the class to double.
gdiff=conv2(gdiff,[1 1;1 1]); % Convolution of the double image for brightening the edges.
gdiff=imadjust(gdiff,[0.5 0.7],[0 1],0.1); % Intensity scaling between the range 0 to 1.
B=logical(gdiff); % Conversion of the class from double to binary. 
% Eliminating the possible horizontal lines from the output image of regiongrow
% that could be edges of license plate.
er=imerode(B,strel('line',50,0));
out1=imsubtract(B,er);%subplot(2,2,1) , imshow(out1)
%subplot(1,2,1) , imshow(out1)
% Filling all the regions of the image.
F=imfill(out1,'holes');
% Thinning the image to ensure character isolation.
H=bwmorph(F,'thin',1);%subplot(2,2,1) , imshow(H)
H=imerode(H,strel('line',3,90));
% Selecting all the regions that are of pixel area more than 100.
final=bwareaopen(H,100);
figure;imshow(final);
 %final=bwlabel(final); % Uncomment to make compitable with the previous versions of MATLAB®
% Two properties 'BoundingBox' and binary 'Image' corresponding to these
% Bounding boxes are acquired.
Iprops=regionprops(final,'BoundingBox','Centroid','Image');
cen=cat(1,Iprops.Centroid);
% Selecting all the bounding boxes in matrix of order numberofboxesX4;
NR=cat(1,Iprops.BoundingBox);


%%%%%%%%%%%%%%%%  printing of all the founded bounding boxes  %%%%%%%%%%%%%
I={Iprops.Image};


for k=1:length(NR)
 % x=I{1,k};
  %figure;imshow(x);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  finding valid bounding boxes which may contains character or numbers... 
%[Q,W]=hist(NR(:,4)); % Histogram of the y-dimension widths of all boxes.

%[a,ix]=max(Q(:,2))

%%%%%%%%%%%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%

B={Iprops.BoundingBox};
if ~isempty(NR)
    noPlate=[];
    
    %%for k = 1 : length(NR)
       %thisBB = NR(k).BoundingBox;
       %rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
      % 'EdgeColor','r','LineWidth',2 )
    %%%end
    
    for k=1:length(NR)
        N=I{1,k}; % Extracting the binary image corresponding to the indices in 'r'.
        %figure; imshow(N);
        BB=B{1,k};
        rectangle('Position', [BB(1),BB(2),BB(3),BB(4)],...
       'EdgeColor','r','LineWidth',2 )
        letter=readLetter(N); % Reading the letter corresponding the binary image 'N'.

        noPlate=[noPlate letter]; % Appending every subsequent character in noPlate variable.
  end
figure;imshow(final);
d = fopen('noPlate.txt', 'wt'); % This portion of code writes the number plate
    fprintf(d,'%s\n',noPlate);      % to the text file, if executed a notepad file with the
    fclose(d);                      % name noPlate.txt will be open with the number plate written.
    winopen('noPlate.txt')

%speech sysnthesis
%userPrompt = 'What do you want the computer to say?';
%titleBar = 'Text to Speech';
String1 = 'characters from your image are successfully identified and they are';
%defaultString2 = 'characters are  !';
%caUserInput = inputdlg(userPrompt, titleBar, 1, {defaultString});
caUserInput = noPlate;
if isempty(caUserInput)
	return;
end; % Bail out if they clicked Cancel.

caUserInput = char(caUserInput); % Convert from cell to string.
NET.addAssembly('System.Speech');
obj = System.Speech.Synthesis.SpeechSynthesizer;
obj.Volume = 100;
Speak(obj, String1);
%Speak(obj, defaultString2);
Speak(obj, caUserInput);

    
    
else % If fail to extract the indexes in 'r' this line of error will be displayed.
    fprintf('Unable to extract the characters from the number plate.\n');
    fprintf('The characters on the number plate might not be clear or touching with each other or boundries.\n');
end

