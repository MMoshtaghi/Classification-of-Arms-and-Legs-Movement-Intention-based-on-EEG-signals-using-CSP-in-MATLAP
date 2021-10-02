clear all;
%% load subject
subject = 1;
if (subject == 1)
    load data_set_IVa_aa.mat;
elseif (subject == 2)
    load data_set_IVa_al.mat;
elseif (subject == 3)
    load data_set_IVa_av.mat;
elseif (subject == 4)
    load data_set_IVa_aw.mat;
else (subject == 5)
    load data_set_IVa_ay.mat;
end

%% preprocessing
d = designfilt('bandpassiir','FilterOrder',10, ...
    'HalfPowerFrequency1',8,'HalfPowerFrequency2',30, ...
    'SampleRate',100);
cnt = double (cnt);
filtCNT_FsCh = filtfilt(d,cnt);
plot ( cnt(:,1) )
hold on
plot ( filtCNT_FsCh(:,1) )


%% Lable prepration
CountValidLable = 0;
TF = isnan(mrk.y);
for i = 1:1:280
    if ( TF(1,i)==1 )
        break
    end
    CountValidLable = CountValidLable + 1;
    if ( mrk.y(1,i) == 1 )
        TotalLable(i,1) = 1;
    elseif ( mrk.y(1,i) == 2 )
        TotalLable(i,1) = 0;
    end
end

%% Data Preperation
filtCNTtransChFs = filtCNT_FsCh';
for i = 1:1:CountValidLable
    segment_i = filtCNTtransChFs( : , [ (mrk.pos(1,i) + 51) : (mrk.pos(1,i) + 150) ] );
    if (i == 1)
        TotalDataChFsTr = segment_i;
    else
        TotalDataChFsTr = cat ( 3 , TotalDataChFsTr , segment_i );
    end
end

%% main Loop
TestClassResult = zeros( CountValidLable , 1 );
for trial = 1:1:CountValidLable
    TrainDataChFsTr = TotalDataChFsTr;
    TestData = TotalDataChFsTr ( : , : , trial );
    TestLable = TotalLable(trial,1);
    TrainDataChFsTr ( : , : , trial ) = [];
    TrainLable = TotalLable;
    TrainLable(trial,:) = [];
    
    %% Train Data Class 1 prepration
    a=0;
    TrainDataC1Num = 0;
    for i = 1:1:(CountValidLable-1)
        if ( TrainLable(i,1) == 1 )
            TrainDataC1Num = TrainDataC1Num + 1;
            if (a==0)
                TrainDataC1 = TrainDataChFsTr ( : , : , i );
                a=1;
            else
                TrainDataC1 = cat ( 3 , TrainDataC1 , TrainDataChFsTr ( : , : , i ) );
            end
        end
    end
    
    %% Train Data Class 2 prepration
    a=0;
    TrainDataC2Num = 0;
    for i = 1:1:(CountValidLable-1)
        if ( TrainLable(i,1) == 0 )
            TrainDataC2Num = TrainDataC2Num + 1;
            if (a==0)
                TrainDataC2 = TrainDataChFsTr ( : , : , i );
                a=1;
            else
                TrainDataC2 = cat ( 3 , TrainDataC2 , TrainDataChFsTr ( : , : , i ) );
            end
        end
    end
    %% calc weights & Features
    [ wCSPmax , wCSPmin ] = myCSP( TrainDataC1 , TrainDataC1Num , TrainDataC2 , TrainDataC2Num );
    FeatureTotal = zeros( CountValidLable , 2 );
    FeatureWmax = zeros( CountValidLable , 1 );
    FeatureWmin = zeros( CountValidLable , 1 );
    SpacialFiltWmax = zeros( 1 , 100 );
    SpacialFiltWmin = zeros( 1 , 100 );
    for i = 1:1:CountValidLable
        SpacialFiltWmax = wCSPmax' * TotalDataChFsTr(:,:,i);
        SpacialFiltWmin = wCSPmin' * TotalDataChFsTr(:,:,i);
        FeatureWmax( i , 1 ) = SpacialFiltWmax * SpacialFiltWmax';
        FeatureWmin( i , 1 ) = SpacialFiltWmin * SpacialFiltWmin';
    end
    FeatureTotal = cat( 2 , FeatureWmax , FeatureWmin );
    FeatureTrain = FeatureTotal;
    FeatureTrain ( trial , : ) = [];
    FeatureTest = FeatureTotal ( trial, : );
    FeatureTest = repmat( FeatureTest , (CountValidLable-1) , 1 );
    %% KNN Classifier
    FeatureTrTsDelta = ( FeatureTrain - FeatureTest ).^2 ;
    distancePow2 = FeatureTrTsDelta( : , 1 ) + FeatureTrTsDelta( : , 2 );
    KNN = 5;
    [~,KMinDistanceIndice] = mink(distancePow2,KNN);
    KNNLables = TrainLable(KMinDistanceIndice);
    KNNLableSum = sum(KNNLables);
    if ( (2*KNNLableSum) < KNN )
        TestClassResult(trial,1) = 0;
    else
        TestClassResult(trial,1) = 1;
    end
    
end

%% ERROR Calc
DeltaLableRes = abs( TestClassResult - TotalLable );
ERRORofAlgorithm = 100*(sum(DeltaLableRes) / CountValidLable);
ACCURACYofAlgorithm = 100-ERRORofAlgorithm;
display(ACCURACYofAlgorithm)

%% Function declaration
function [ wCSPmax , wCSPmin ] = myCSP( TrainDataC1 , TrainDataC1Num , TrainDataC2 , TrainDataC2Num )
    
    AppSpaCovMat1 = 0;
    for i = 1:1:TrainDataC1Num
        AppSpaCovMat1 = AppSpaCovMat1 + ( TrainDataC1(:,:,i) * (TrainDataC1(:,:,i))' ); 
    end
    AppSpaCovMat1 = AppSpaCovMat1 / TrainDataC1Num;
    
    AppSpaCovMat2 = 0;
    for i = 1:1:TrainDataC2Num
        AppSpaCovMat2 = AppSpaCovMat2 + ( TrainDataC2(:,:,i) * (TrainDataC2(:,:,i))' ); 
    end
    AppSpaCovMat2 = AppSpaCovMat2 / TrainDataC2Num;
    
    M = AppSpaCovMat2 \ AppSpaCovMat1 ;
    
    [eigenVector , eigenValue ] = eig(M , 'vector' );
    [~,MINeigenValueIndice] = min(eigenValue);
    [~,MAXeigenValueIndice] = max(eigenValue);
    wCSPmin = eigenVector( : , MINeigenValueIndice );
    wCSPmax = eigenVector( : , MAXeigenValueIndice );
end


