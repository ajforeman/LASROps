# LASROps
Start LASR Servers via API

If you administer SAS platform with LASR Analytic Server, you might be aware that you need to login to SAS Visual Analytics Administrator using LASR Administrator account to start the server process.

 

One way to automate this process is to use PROC LASR and start the server process. In my post I am going to share how to automate this process via API calls using PROC HTTP.

 

This demonstration is based on SAS Visual Analytics Ver. 7.5 and SMP deployment which is on SAS 9.4 M6 release. There are a few changes in this release where SAS administration functionality has been extended to web based SAS Environment Manager. 

 

You can read more about what's new on the documentation link https://go.documentation.sas.com/?cdcId=bicdc&cdcVersion=9.4&docsetId=evadmfun&docsetTarget=evadmfun...

 

This code can be integrated with sas.servers script available on LAX/UNIX/zOS environments via a shell wrapper for seamless experience.

 

For Windows environments this code should be executed manually or if you use an automated batch file you can call this program as well.
Check this community article on how to Start/Stop all SAS Services in Windows using Batch File 

 

Below is the preview of how it looks when integrated with sas.servers

 

1) Check status

 

sas.servers_status.gif
Status of the services

 

2) Stop services

 

sas.servers_stop.gif
stopping sas services

 

3) Start services

 

sas.servers_start.gif
start sas services

 

Below is the preview of the shell wrapper called by sas.servers script. You can call this wrapper directly as well to perform operations on LASR servers.

 

Execution in the background happens via the LASR Administrator account 'lasradm'. I have given sudo permissions to SAS Installer account 'sas'  to perform this without asking for a password.

 

4) Check status

 

lasrops status.gif

 

5) Stop services

 

lasrops stop.gif

 

6) Start services

 

lasrops start.gif

 

It has some intelligence as well in-case you try to start the server if it's already started.

 

lasrops intelligence.gif

 

Using this approach would make the system start the LASR server in exactly the same way as you do via the user interface. This helps to apply all the enabled property options that you have made on the LASR servers.

 

For example, If you have set the reload-on-start option enabled, tables would be loaded back as the server starts.

 

I have tested this code on 3 different environments, two LAX and one WINX64 and it works error free. You should be ready to go once you provide the user, pass and operation (start/stop/status). Please download the code and script from the attachment.

 

Comments, Feedback and Suggestions are welcome!

 

Thanks,
Anand Vyas
Thakral One
