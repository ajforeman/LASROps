# LASROps
Start LASR Servers via API

Originally written by Anand Vyas.
Modifications for easy SAS-lsm configuration by Andy Foreman.
Use this utility at your own risk.

Check the article originally published at SAS Communities!
https://communities.sas.com/t5/SAS-Communities-Library/Start-LASR-Servers-via-API/ta-p/646150

**How to use:**
* Start LASR Servers: `LASROps.sh start`
* Stop LASR Servers: `LASROps.sh stop`
* Check LASR Servers Status: `LASROps.sh status`

## Required setup configuration:

1) Download the LASROps.sh script and lasr_ops.sas program to a machine where SAS can be run.
2) Store the downloaded files in an accessible location. Recommended to create a subdirectory under SASConfig/Utilities/, such as SASConfig/Utilities/LASROps/ .
3) Set required user-defined variables inside the downloaded files:

A) Edit the LASROps.sh script. The top of the script contains a section for user-defined variables which must be set:

* $saslocation - The path to a SAS binary to run SAS code.
* $progpath - The location where the main lasr_ops.sas program has been saved on the local system.

B) Edit the lasr_ops.sas program. The top of the program contains a section for user-defined variables which must be set:

* metaserver - SAS Metadata Server hostname
* metaport - SAS Metadata Server port (default: 8561)
* metauser - SAS Metadata Server login user. This can be any user defined in SAS Metadata who has permissions to read Metadata.
* metapass - Password for the defined SAS Metadata Server login user. Storing the password in {SAS002} format is recommended.
* username- LASR Administrator login user. Usually lasradm, but this can be any user who has permissions to start and stop LASR Servers.
* pwd - Password for the defined LASR Administrator login user. Storing the password in {SAS002} format is recommended.

*For more details on these user-defined variables, refer to the comments inside the code near where they are set.*

### Additional Considerations

This utility assumes the executing user has a home directory, which is used to store a few .txt files that track LASR status. If the user does not have a home directory, these paths will need to be updated to a different location that is readable and writable:
* LASROps.sh - `cat` command, near bottom of file
* lasr_ops.sas - PROC EXPORT code's OUTFILE option, near bottom of file
