function out = average(back, front, n)
for j = 0:(n-1)
	out(:,:,:,j+1) = ((n-j)/n)*back + (j/n)*front;
end
