#!/bin/bash

#This script calls the lasr_ops SAS program.
#Version: 1.0 | Author: Anand Vyas
#Modifications for easy SAS-lsm configuration by Andy Foreman  


# ***************************** USER DEFINED VARIABLES ******************************
#
#Path to a SAS binary .sh (default: SAS Batch Server, <SASConfig>/Lev1/<SASApp>/BatchServer/sasbatch.sh )
$saslocation = "/opt/sas/config/Lev1/SASAppVA/BatchServer/sasbatch.sh"
#Path to the lasr_ops.sas program (recommended: <SASConfig>/Utilities/LASROps/lasr_ops.sas )
$progpath = "/opt/sas/config/Utilities/LASROps/lasr_ops.sas"
#
# *************************** END USER DEFINED VARIABLES ****************************

#DO NOT EDIT PROGRAM BELOW THIS LINE

#Expected options are start, stop, status
option=$1

$saslocation -sysin $progpath -set operation $option -log ~/

cat ~/lasr_status.txt