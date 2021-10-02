# Classification-of-Arms-and-Legs-Movement-Intention-based-on-EEG-signals-using-CSP-in-MATLAP
## Data Set
http://www.bbci.de/competition/iii/desc_IVa.html
## PreProcessing
a bandpass filter with lower cutoff frequency 8 Hz and higher cutoff frequency 30 Hz ( appropriate for EEG signals )
## Data Prepration
Channels * SamplingFrequency * T
## Cross-validator
Leave-One-Out
## CSP Function
myCSP()
