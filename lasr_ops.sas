/* ------------------------------------------------------------------------------------------------------------*/
/* This code performs the following actions: 																  */
/* 1 - Queries the metadata server and fetches the host, port, url, protocol configured for SAS EVM MT       */
/* 2 - Use the URL and perform different actions via API calls on LASR Servers                              */
/* --------------------------------------------------------------------------------------------------------*/
/* Version: 1.0 | Author: Anand Vyas                                                                      */
/* Modifications for easy SAS-lsm configuration by Andy Foreman                                          */
/* -----------------------------------------------------------------------------------------------------*/

/***************************** USER DEFINED VARIABLES ******************************/
/* Set these values before running the program or it will not work! */
/* Use PROC PWENCODE on passwords and define the encoded {SAS002} value for security. Plaintext is accepted, but is insecure! */

/* Define Metadata Server Connection. Provided metauser must be able to read metadata repository. */
options metaserver="meta.demo.sas.com"
metaport=8561
metauser="metademouser"
metapass="{SAS002}1A6872358C580064DDCD225ACC1";

/* LASR Administrator account username. E.g. lasradm account (or another user who can start/stop LASR servers) */
%let username=lasrdemouser;

/* LASR Administrator account password. */
%let pwd=;

/**************************** END USER DEFINED VARIABLES *****************************/

/* DO NOT EDIT PROGRAM BELOW THIS LINE */

/* Initialize some empty variables to fill in later */
%let operation= %sysget(operation);
%let protocol=;
%let host=;
%let port=;
%let service=;
%let st=;
%let tgturl=;
%let status=;

/* Get URL details from Metadata */
data _null_;
	length uri $256 upasnuri $256 ComType $256 srccnnuri $256 ConName $256 
		protocol $6 HostName $256 port $4 service $100;
	call missing(uri, upasnuri, ComType, srccnnuri, ConName, protocol, HostName, 
		port, service);
	nserverobj=1;
	nobj=metadata_getnobj("omsobj:SoftwareComponent?@Name contains 'Environment Mgr Mid-Tier'", 
		nserverobj, uri);

	do while (nobj>0);
		n=1;
		uprc=metadata_getnasn(uri, 'DeployedComponents', n, upasnuri);

		if uprc > 0 then
			do;
				rc=metadata_getattr(upasnuri, 'Name', ComType);

				if rc=0 then
					do;
						n=1;
						uprc=metadata_getnasn(upasnuri, 'SourceConnections', n, srccnnuri);

						if uprc > 0 then
							do;
								rc=metadata_getattr(srccnnuri, 'HostName', HostName);
								call symput('host', trim(HostName));
								rc=metadata_getattr(srccnnuri, 'CommunicationProtocol', protocol);
								call symput('protocol', trim(protocol));
								rc=metadata_getattr(srccnnuri, 'Service', service);
								call symput('service', trim(service));
								rc=metadata_getattr(srccnnuri, 'Port', port);
								call symput('port', trim(port));
							end;
					end;
			end;
		nserverobj+1;
		nobj=metadata_getnobj("omsobj:SoftwareComponent?@Name contains 'Environment Mgr Mid-Tier'", 
			nserverobj, uri);
	end;
run;

/* Get TGT and ST */
%let rooturl=&protocol.://&host.:&port.;
filename resp TEMP;
filename headers TEMP;

proc http method="POST" url="&rooturl/SASLogon/v1/tickets" 
		in="username=&username.%nrstr(&password)=&pwd" headerout=headers out=resp 
		HEADEROUT_OVERWRITE;
run;

%put CODE=&SYS_PROCHTTP_STATUS_CODE.;
%put MSG=&SYS_PROCHTTP_STATUS_PHRASE.;

data _null_;
	infile headers termstr=CRLF length=reclen scanover truncover;
	input @'Location:' tgt $varying500. reclen;
	search='cas';
	x=index(tgt, search);
	caslen=x+2;
	call symput('tgtlen', caslen);
run;

%put &tgtlen;

data _null_;
	infile headers termstr=CRLF length=c scanover truncover;
	varlen="&tgtlen";
	input @'Location:' tgt $varying500. varlen;
	call symput('tgturl', trim(tgt));
	%put &tgturl.;
run;

%put &tgturl.;
%let sturl= &rooturl.&service./j_spring_cas_security_check;
%put &sturl.;
%let inurl=&tgturl;

proc http method="POST" url="&inurl." in="service=&sturl." headerout=headers 
		out=resp HEADEROUT_OVERWRITE;
run;

%put CODE=&SYS_PROCHTTP_STATUS_CODE.;
%put MSG=&SYS_PROCHTTP_STATUS_PHRASE.;

data _null_;
	infile resp;
	input @;
	call symput('st', trim(_infile_));
	*%put &st.;
run;

proc http method="POST" 
		url="&rooturl.&service./j_spring_cas_security_check?ticket=&st." 
		headerout=headers out=resp HEADEROUT_OVERWRITE;
run;

%put CODE=&SYS_PROCHTTP_STATUS_CODE.;
%put MSG=&SYS_PROCHTTP_STATUS_PHRASE.;

proc http url="&rooturl.&service./sasui/lasr/servers" out=resp 
		headerout=headers;
run;

%put CODE=&SYS_PROCHTTP_STATUS_CODE.;
%put MSG=&SYS_PROCHTTP_STATUS_PHRASE.;
libname jsonout JSON fileref=resp;

data export_all(keep=id name no);
	set jsonout.items;
	no=_n_;
	name=trim(name);
run;

libname jsonout clear;

proc sql noprint;
	select count(id) into: lasrcount from export_all;
quit;

proc sql;
	create table basetable (Message char(100));
	run;

	/* Update status */
	%macro status(id, name);
	proc http method="GET" url="&rooturl.&service./sasui/lasr/servers/&id./status" 
			headerout=headers out=resp HEADEROUT_OVERWRITE;
	run;

	libname statout JSON fileref=resp;

	data _null_;
		set statout.alldata;
		where p1='status';
		call symput('status', trim(Value));
		%put &status.;
	run;

	libname statout clear;
%mend status;

/* Perform action on LASR Servers */
%macro lasr(operation);
	%if &operation=start %then
		%do;
			%let output=starting;
		%end;
	%else %if &operation=stop %then
		%do;
			%let output=stopping;
		%end;

	%Do i=1 %to &lasrcount.;

		/* do start */
		proc sql noprint;
			select id, name into :lasrid, :lasrname from export_all where no=&i.;
		quit;

		%if &operation ne status %then
			%do;
				%status(&lasrid., &lasrname.);

				%if &status. eq RUNNING && &operation eq start %then
					%do;
						%let out=UP;

						data lasrstatus_&i.;
							Message="&lasrname is already &out. ";
						run;

					%end;
				%else %if &status. eq STOPPED && &operation eq stop %then
					%do;
						%let out=DOWN;

						data lasrstatus_&i.;
							Message="&lasrname is already &status. ";
						run;

					%end;
				%else
					%do;

						proc http method="POST" 
								url="&rooturl.&service./sasui/lasr/servers/&lasrid.?state=&operation." 
								headerout=headers out=resp HEADEROUT_OVERWRITE;
						run;

						%put CODE=&SYS_PROCHTTP_STATUS_CODE.;
						%put MSG=&SYS_PROCHTTP_STATUS_PHRASE.;

						%if &SYS_PROCHTTP_STATUS_CODE. eq 200 %then
							%do;

								data lasrstatus_&i.;
									Message="&output &lasrname. ";
								run;

							%end;
						%else
							%do;

								data lasrstatus_&i.;
									Message="Failed to &operation. &lasrname. . ERROR: &SYS_PROCHTTP_STATUS_PHRASE.";
								run;

							%end;
					%end;
			%end;
		%else
			%do;
				%status(&lasrid., &lasrname.);

				%if &status.=RUNNING %then
					%do;
						%let out=UP;
					%end;
				%else
					%do;
						%let out=DOWN;
					%end;

				data lasrstatus_&i.;
					Message="&lasrname is &out. ";
				run;

			%end;
	%end;

	%Do i=1 %to &lasrcount.;

		/* do start */
		proc append base=basetable data=lasrstatus_&i. force;
		run;

	%end;

	/* do end */
	proc export data=basetable outfile="~/lasr_status.txt" replace;
		putnames=NO;
	run;

%mend lasr;

%lasr(&operation.);
