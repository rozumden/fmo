function framesToVideo(path)
%framesToVideo converts frame by frame images into a video
%
%Input:
%path ... path to folder containing frame by frame images

    files = dir(path);
    output = fullfile(path, 'output');
    out = VideoWriter(output);
    open(out);
    for i = 1:length(files)
        if files(i).isdir
            continue
        end
    
        try
            img = imread(fullfile(input, files(i).name));
            writeVideo(out, img);
        catch
        end        
    end
    close(out);
end
