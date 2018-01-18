function gtMaker(path)
%gtMaker makes binary masks from frame by frame images and saves them as 
%gt.mat in provided path
%
%Input:
%path ... path to folder containing frame by frame images

    gt_color = [255, 0, 0]; %specification of ground truth color in RGB

    gt = {};
    files = dir(path);
    files = files(~[files.isdir]);
    
    for i = 1:length(files)
        [~,name,~] = fileparts(files(i).name);
        try
            im = imread(fullfile(path, files(i).name)); 
            mask = im(:, :, 1) == gt_color(1) & ...
                   im(:, :, 2) == gt_color(2) & ...
                   im(:, :, 3) == gt_color(3);
            gt{str2double(name)} = mask;
        catch
            continue;
        end
    end    
    save(fullfile(path, 'gt.mat'), 'gt');    
end