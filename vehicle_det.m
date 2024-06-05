%read video
Vid=VideoReader("Traffic4.mp4");
%to recognize the vehicle (numgaussians: specifies the no. of guassian modes)(numtrainingframes: to make the detection faster)
Obj_Detector=vision.ForegroundDetector('NumGaussians',3, 'NumTrainingFrames',50,'MinimumBackgroundRatio',0.65);
for i=1:149
    %reads frame from 'Vid' 149 times
    frame=readFrame(Vid);
    %pass the frame to the obj detector
    Object= step(Obj_Detector,frame);
end
%to show the frame
figure, imshow(frame);
title('This is the video frame');
%to show the object
figure, imshow(Object);
title('The object');
%to add a structure(square is the type of structure,size)
Structure= strel('square',3);
%object is where the noises are. Returns a noise free structure
NoiseFreeObj=imopen(Object,Structure);
%to show the noise free object
figure; imshow(NoiseFreeObj);
title('Object after removing noise');

%to ignore blobs <500pixels; returns the  coordinates of the object
BoundingBox=vision.BlobAnalysis('BoundingBoxOutputPort', true,'AreaOutputPort',false,'CentroidOutputPort',false,'MinimumBlobArea',500);

%step function to put the bounding box on the noise free object
Box=step(BoundingBox,NoiseFreeObj);
%to insert a rectangle while detecting:
detectedcar=insertShape(frame,"rectangle",Box,'Color','green');
%no. of cars=number of rectangles , done by size function, returning a
% number(1D data)
no.ofcars=size(Box, 1);
low_weight = 0;
heavy_weight = 0;
for i = 1:no.ofcars
    %(width*height)
    if Box(i, 3) * Box(i, 4) < 8000
        low_weight = low_weight + 1;
    else
        heavy_weight = heavy_weight + 1;
    end
end

%Insert text for number of low weight and heavy weight vehicles
detectedcar=insertText(detectedcar,[9 9], ['Low weight: ' num2str(low_weight)],'BoxOpacity', 1,'FontSize', 13);
detectedcar=insertText(detectedcar,[9 9], ['Heavy weight: ' num2str(heavy_weight)],'BoxOpacity', 1,'FontSize', 13);



figure, imshow(detectedcar);
title('Detected Cars');

playbackSpeed = 0.75;
%videoplayer to play the video
videoplayer=vision.VideoPlayer('Name','Detected Car');

%defining the aspect ratio and video resolution
videoplayer.Position(3:4)=[848, 384];

while hasFrame(Vid)

    frame=readFrame(Vid);
    Object= step(Obj_Detector,frame);
    NoiseFreeObj=imopen(Object,Structure);
    Box=step(BoundingBox,NoiseFreeObj);
    detectedcar=insertShape(frame,"rectangle",Box,'Color','green');
    no.ofcars =size(Box, 1);
    
low_weight = 0;
heavy_weight = 0;
for i = 1:no.ofcars
    %width*height
    if Box(i, 3) * Box(i, 4) < 8000
        low_weight = low_weight + 1;
    else
        heavy_weight = heavy_weight + 1;
    end
end
%to insert number of cars(LMV and HMV) on the frame.. BoxOpacity=1: fully
%non-transparent
detectedcar=insertText(detectedcar,[9 9], ['Low weight: ' num2str(low_weight)],'BoxOpacity', 1,'FontSize', 13);
detectedcar=insertText(detectedcar,[9 30], ['Heavy weight: ' num2str(heavy_weight)],'BoxOpacity', 1,'FontSize', 13);
    
    

    % play the video at a slower speed
    pause(1 / (Vid.FrameRate * playbackSpeed));
    step(videoplayer,detectedcar);
end

