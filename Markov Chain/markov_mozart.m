%% TEAM MEMBERS 
% Akhilesh Sudhakar- 2013A7PS173P - Genetic Algorithm
% Jhanavi Sheth- 2013A7PS096P - Markov Chain Algorithm
% Sanket Shah- 2013A7PS119P - Neural Networks Algorithm

%%  For the sake of reading and storing midi files an open source midi
%   toolbox has been used.
%   Source: https://github.com/kts/matlab-midi/tree/master/src
%           http://kenschutte.com/midi - toolbox used


%% Initialisation of variables

%num is the maximum number of notes in the dataset
num=6207;

%transition matrix stores the probabilities of the notes in simple markov chain
transitionmatrix = zeros(num,num);

%% Reading the dataset and populating the transition matrix
for k=1:21
    s = ['moz' int2str(k) '.mid'];
    midi = readmidi(s);
    Notes = midiInfo(midi,0);
    [m,n] = size(Notes);
    for i=1:m-1
        transitionmatrix(Notes(i,3),Notes(i+1,3)) = transitionmatrix(Notes(i,3),Notes(i+1,3))+1;
    end
end

%% Converting the populated transition matrix into corresponding
%  probabilities
for i = 1:num
    sum=0;
    for j=1:num
        sum = sum+transitionmatrix(i,j);
    end
    if(sum>0)
        for j=1:num
            transitionmatrix(i,j) = transitionmatrix(i,j)/sum;
        end
    end
end

%% Generating a new melody from the transition matrix. Different starting
%  points would give different melodies. In fact the same starting note also
%  gives different melodies since the generation is random. For now the
%  velocity, time duration and starting time have been randomised but can
%  similarly be derived from markov chain.
newMelody = zeros(num,6);
newMelody(:,1) = 1;
newMelody(:,2) = 2;
newMelody(:,4) = 60;
newMelody(:,5) = 10 * rand(num,1);
newMelody(:,6) = newMelody(:,5) + .2 + rand(num,1); 

%a random starting note chosen
newMelody(1,3)=100;

%populates the chain of notes based on randomisation and the transition
%matrix populated.
for i=2:6207
    curr_row = transitionmatrix(newMelody(i-1,3),:);
    cum_distr = cumsum(curr_row);
    r = rand();
    newMelody(i,3) = find(cum_distr>r,1);
end

%% The new melody stored and written as a midi file
newMelody_midi = matrix2midi(newMelody);
writemidi(newMelody_midi, 'markov mozart.mid');




