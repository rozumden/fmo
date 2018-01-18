%Evaluation script
overlap_thr = 0.3;

%Sequence file names
sequences = {'ping_pong_side'
             'ping_pong_top'
             'tennis_serve_side'
             'tennis_serve_back'
             'hockey'
             'squash'
             'tennis1'
             'tennis2'
             'william_tell'
             };

%Sequence true names
names = {'ping\_pong\_side'
         'ping\_pong\_top'
         'tennis\_serve\_side'
         'tennis\_serve\_back'
         'hockey'
         'squash'
         'tennis\_1'
         'tennis\_2'
         'william\_tell'};

%Constants definition
TP = 1;
FP = 2;
TN = 3;
FN = 4;
     
 for s = 1:length(sequences)
    seq = sequences{s};
     
    detections = sprintf('output/%s.mat', seq);
    gt = sprintf('input/%s_gt.mat', seq);  
      
    load(detections);
    load(gt);
    num = min(length(gt), length(allMasks));
    state = [];
    overlaps = [];
    labels = [];

    for i = 1:num    
        overlaps(i) = 0;
        labels(i) = 0;

        gt_ = gt{i};
        det_ = allMasks{i};

        gtArea = sum(gt_(:));
        if gtArea > 0
            labels(i) = 1;
        end

        if isempty(det_) && gtArea > 0
            state(i) = FN;
            continue;
        elseif gtArea < 1 && ~isempty(det_)
            state(i) = FP;        
            continue;
        elseif gtArea < 1 && isempty(det_)
            state(i) = TN;
            continue;
        end

        union = gt_ | det_;
        intersection = gt_ & det_;

        overlap = sum(intersection(:)) / sum(union(:));
        overlaps(i) = overlap;

        if overlap >= overlap_thr
            state(i) = TP;
        else
            state(i) = FP;
        end
    end

    tp = sum(state == TP);
    fp = sum(state == FP);
    tn = sum(state == TN);
    fn = sum(state == FN);

    precision = tp / (tp+fp);
    recall = tp / (tp + fn);

    average = mean(overlaps(labels==1));    
    
    %Latex table row
    display(sprintf('%s & %i & %i & %i & %i & %0.1f\\%% & %0.1f\\%% & %0.1f\\%% \\\\', ...
                    names{s}, tp, fp, tn, fn, precision*100, recall*100,  average*100));
 end
