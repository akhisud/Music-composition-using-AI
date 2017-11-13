%%  For the sake of reading and storing midi files an open source midi
%   toolbox has been used.
%   Source: https://github.com/kts/matlab-midi/tree/master/src
%           http://kenschutte.com/midi - toolbox used


%% Initialisation 

num=2495;
samples=24;
attributes=8;
best= floor(samples/4);
worst=floor(samples/4); 
init=zeros(num,attributes,samples);
temp=zeros(num,attributes,samples);
population=zeros(num,attributes,samples);
Target= zeros(num,attributes);
pair=zeros(2,num);
x= zeros(num,attributes);
y= zeros(num,attributes);

%% Using each song as the target 
for trgt=1:samples
    
    %Converting each midi sample to matrix
    for k=1:samples
        s = ['chpn-p' int2str(k) '.mid'];
        midi = readmidi(s);
        Notes = midiInfo(midi,0);
        [m,n] = size(Notes);
        for i=1:m
            for j=1:n
                init(i,j,k) = Notes(i,j); 
            end    
        end         
    end

    s = ['chpn-p' int2str(trgt) '.mid'];
    midi = readmidi(s);
    Notes = midiInfo(midi,0);
    [m,n] = size(Notes);

    for i=1:m
        for j=1:n
            Target(i,j) = Notes(i,j); 

        end    
    end      
    population = init;
    
    %Iterations of the algorithm
    for iterations=1:5
        for chromosome=1:samples
            
            %finding euclidean distance of notes to target
            note_array = population(:,3,chromosome);
            pair(1,:)=note_array;
            pair(2,:)=Target(:,3);
            D = pdist(pair,'euclidean');
            distances_note(chromosome)=D;

            %finding euclidean distance of velocity to target
            velocity_array= population(:,4,chromosome);
            pair(1,:)=velocity_array;
            pair(2,:)=Target(:,4);
            D = pdist(pair,'euclidean');
            distances_velocity(chromosome)=D;
            
            %finding euclidean distance of time1 to target
            time1_array = population(:,5,chromosome);
            pair(1,:)=time1_array;
            pair(2,:)=Target(:,3);
            D = pdist(pair,'euclidean');
            distances_time1(chromosome)=D;
            
            %finding euclidean distance of time2 to target
            time2_array = population(:,6,chromosome);
            pair(1,:)=time2_array;
            pair(2,:)=Target(:,3);
            D = pdist(pair,'euclidean');
            distances_time2(chromosome)=D;
            
            
        end
        
        %summing all the euclidean distances 
        distances=(distances_note + distances_velocity+distances_time1+distances_time2);
        
        %sorting in ascending order of distance from target
        [distances is] = sort(distances,'ascend');
        temp=population;    

        for chromosome=1:samples
            population(:,:,chromosome)=temp(:,:,is(chromosome)); 
        end
        
        %picking the best one-fourth in the population
        for i=1:best
            to_permute(i)=i;
        end

        ix = randperm(best);
        permuted = to_permute(ix);
        chromosome =worst;     
        
        % making genetic crossovers 
        for i = 1 : best-1 
            crossover_point = randi([1 2495],1,1);
           
            % recombining the crossovers
            x(1:crossover_point,:) = population(1:crossover_point,:,permuted(i+1));
            y(1:crossover_point,:) = population(1:crossover_point,:,permuted(i));
            x(crossover_point:samples,:) = population(crossover_point:samples,:,permuted(i));
            y(crossover_point:samples,:) = population(crossover_point:samples,:,permuted(i+1));

            population(:,:,chromosome)=x;
            chromosome=chromosome+1;
            population(:,:,chromosome)=y;
            chromosome=chromosome+1;
            i=i+2;
        end   
    end
 for i=1:num
     z=randi([1 3],1,1);
     if z==3
         population(i,3,1)=randi([50 70],1,1);
     end
 end
         

    %% The output files:
    % Channel is randomized to select 1 or 2
    % Track is set to 0 
    % Notes, velocity, time1 and time2 are used from the newly formed
    % population
    new = zeros(num,6);
    new(:,1) = randi([1 2],1,1);
    new(:,2) = 0;
    new(:,3) = population(:,3,1);
    new(:,4) = population(:,4,1);
    new(:,5) = population(:,5,1);
    new(:,6) = population(:,6,1);


    %% Matrix converted to midi file to play

    newmidi = matrix2midi(new);
    writemidi(newmidi, ['output chopin' int2str(trgt) '.mid']);
end



