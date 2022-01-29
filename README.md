# Classification-of-Arms-and-Legs-Movement-Intention-based-on-EEG-signals-using-CSP-in-MATLAP
## Data Set
[Link](http://www.bbci.de/competition/iii/desc_IVa.html)
## PreProcessing
a bandpass filter with lower cutoff frequency 8 Hz and higher cutoff frequency 30 Hz ( appropriate for EEG signals )
## Data Prepration
Channels * SamplingFrequency * T
## Cross-validator
Leave-One-Out
## CSP Function
myCSP()
## results
Subject: Accuracy
1: 86.309%
2: 96.875%
3: 72.6190%
4: 66.0714%
5: 92.857%
