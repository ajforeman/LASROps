#!/bin/bash

#This script calls the lasr_ops SAS program. Change the below sasconfig location at your site.
#Version: 1.0 | Author: Anand Vyas

#Expected options are start, stop, status
option=$1

/sasconfig/Lev1/SASApp/BatchServer/sasbatch.sh -sysin /sasconfig/Lev1/lasr_ops.sas -set operation $option -log ~/

cat ~/lasr_status.txt

