
% load some data
[d,sr] = audioread('handel.wav');
disp('** Raw spectrogram:');
% Here's the function we want to cache.  I'm using a really high
% overlap to make it slow to compute.
tic; D = specgram(d,512,sr,512,504); toc
subplot(211)
imagesc(20*log10(abs(D))); axis xy
% The first time we do this with the cache, it has to evaluate the
% function so it is no faster:
disp('** Cache_results first time:');
% The function is passed as a function pointer (@funcname);
% arguments are passed as a struct array.
tic; D2 = CacheResults(@specgram, {d,512,sr,512,504}, '', '', 1); toc
disp(['Peak diff = ',num2str(max(abs(D2(:)-D(:))))]);
% the same result

% Now, if we do it again, it's much faster
disp('** Cache_results second time:');
tic; D2 = CacheResults(@specgram, {d,512,sr,512,504}, '', '', 1); toc
max(abs(D2(:)-D(:)));

% Doing it with a different first argument (even just a little bit
% different) leads to a different cache file:
disp('** Slightly different 1st arg data:');
tic; D3 = CacheResults(@specgram, {d(1:end-1),512,sr,512,504}, '', '', 1); toc
tic; D3 = CacheResults(@specgram, {d(1:end-1),512,sr,512,504}, '', '', 1); toc
subplot(212)
imagesc(20*log10(abs(D3))); axis xy