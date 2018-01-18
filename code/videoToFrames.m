function videoToFrames(path)
%videoToFrame converts video to .png images frame by frame and saves them
%into new folder in same directory as video source
%
%Input:
%path ... path to video source

    in = VideoReader(path, 'CurrentTime', 0);
    [pathstr,name,~] = fileparts(path);
    output = fullfile(pathstr, sprintf('%s_out', name));
    mkdir(output);
    frameNum = 1;
    while hasFrame(in)
        frame = readFrame(in);
        imwrite(frame, fullfile(output, sprintf('%i.png', frameNum)));    
        frameNum = frameNum + 1;
    end
end
    