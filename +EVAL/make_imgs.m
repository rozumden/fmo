EVAL.init();

[videos, initframes, tls_x, tls_y, widths, heights] = textread('first_bbx.txt','%s %d %f %f %f %f');

parfor i = 1:numel(videos)
    seq_file = videos{i};
    [~,seq_name,~] = fileparts(seq_file);
    vid = Video(folder, seq_file);

    if ~exist(seq_name, 'dir')
        mkdir(seq_name);
    end
    dlmwrite([seq_name '/init_rect.txt'], [tls_x(i) tls_y(i) widths(i) heights(i)], 'delimiter', ',');

    vid.k = initframes(i);
    frame_number = 0;
    while vid.has_next()
        frame = vid.get_next();
        imwrite(frame,[seq_name '/' sprintf('%05d.png', frame_number)]);
        frame_number = frame_number + 1;
    end
end