LASROps.sh - Shell Wrapper to call the lasr_ops.sas program
lasr_ops.sas - SAS Program that does the work.

Run this using LASR Administrator account.
To integrate with sas.servers script provide sudo access with no password permission for the SAS Installer account to run as LASR Administrator.

NOTE: If you are running SAS on a windows machine change the outfile location to a path where the user has write access.
By default the option is for unix user home directory.

Example below:

Default:

proc export data=basetable outfile="~/lasr_status.txt" replace;
		putnames=NO;
	run;
	
Windows:

proc export data=basetable outfile="c:\lasr_status.txt" replace;
		putnames=NO;
	run;