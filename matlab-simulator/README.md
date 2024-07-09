# FSMA_LoRa Simulator
This folder includes all files related to matlab simulator

## How to run?
- Run FSMA_MainSim.m file

## What are the key parameters?

```
% type of mac protocol
type_strings = ["FSMA", "ALOHA", "CSMA", "CSMA", "CSMA"]; 

% especially needed for CSMA gives how far the node can hear other node
cad_distance = [3000 0 30 1500 3000]*1e3;

% no of iterations for understading variation from mean and error bar generation 
params.nIterations = 5;

% Repeats for offer load values from 5 to 200 (x-axis) (typically we set offered_load = no of nodes/100)
nodesCountVals =  [5 10 20 30 40 50 60 80 100 125 150 175 200 250 300 400 500];

```
