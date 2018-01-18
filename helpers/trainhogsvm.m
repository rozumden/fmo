function svm = trainhogsvm(hogp,hogm)
X = hog2feature([hogp hogm]);
y = [ones(1,numel(hogp)) zeros(1,numel(hogm))]';
svm = fitcsvm(X,y);
