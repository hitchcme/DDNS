function [TABLE,NETSET,DHCPSRVS] = Get_MacFQDNs(USERNAME,PASSWORD)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
HOSTNAME='BBB2.wtecs.net';

FQDNRPATH='/root/.ddnswa/MACFQDNs';
FQDNPATH='./.tmp/MACFQDNs'

DOMRPATH='/root/.ddnswa/domain';
DOMPATH='./.tmp/domain';

SRVsRPATH='/root/.ddnswa/SRVs';
SRVsPATH='./.tmp/SRVs';

LDPATH='./.tmp/';

if ~exist('./.tmp','dir')
	mkdir('./.tmp');
end



get_ganymed();
ssh2_conn = utils.SSH.scp_simple_get(HOSTNAME,USERNAME,PASSWORD,FQDNRPATH,LDPATH);
ssh2_conn = utils.SSH.scp_simple_get(HOSTNAME,USERNAME,PASSWORD,'/root/.ddnswa/domain','./.tmp/');
ssh2_conn = utils.SSH.scp_simple_get(HOSTNAME,USERNAME,PASSWORD,'/root/.ddnswa/SRVs','./.tmp/');
rem_ganymed();

fid=fopen(FQDNPATH);
tline = fgetl(fid);

while ischar(tline)
	MAC = utils.misc.strsplit(tline,' ');
	
	if ~isempty(MAC)
		if size(MAC,2) < 2
			MAC(2) = cellstr('');
		end
		FQDN = MAC(2);
		MAC(2) = [];
		MNtblline=table(MAC,FQDN);
		if exist('TABLE','var')
			TABLE=[TABLE;MNtblline];
		else
			TABLE = MNtblline;
		end
	end
	tline = fgetl(fid);
	end
fclose all;


% Read domain settings file to NETSET variable
fid=fopen(DOMPATH);
tline = fgetl(fid);
while ischar(tline)
	if ~exist('NETSET','var')
		NETSET = utils.misc.strsplit(tline,' ');
	else
		NETSET = [NETSET;utils.misc.strsplit(tline,' ')];
	end
	tline = fgetl(fid);
end


% Read DHCP servers file to DHCPSRVS Variable
fid=fopen(SRVsPATH);
tline = fgetl(fid);
while ischar(tline)
	
	if ~exist('DHCPSRVS','var')
		DHCPSRVS = cellstr(tline);
	else
		DHCPSRVS = [DHCPSRVS;cellstr(tline)];
	end
	tline = fgetl(fid);
end



function get_ganymed()
	if ispc
		DIRDELIM = '\';
	else
		DIRDELIM = '/';
	end
	THISFILE = strcat(mfilename,'.m');
	THISDIR = regexprep(strcat(mfilename('fullpath'),'.m'),THISFILE,'');
	GMPTH = strcat(THISDIR,DIRDELIM,'+utils',DIRDELIM,'+SSH',DIRDELIM,'ganymed-ssh2-build250.zip');
	GMPTH1 = strcat(THISDIR,DIRDELIM,'ganymed-ssh2-build250.zip');
	copyfile(GMPTH,GMPTH1);
	
function rem_ganymed()
	if ispc
		DIRDELIM = '\';
	else
		DIRDELIM = '/';
	end
	THISFILE = strcat(mfilename,'.m');
	THISDIR = regexprep(strcat(mfilename('fullpath'),'.m'),THISFILE,'');
	GMPTH1 = strcat(THISDIR,DIRDELIM,'ganymed-ssh2-build250.zip');
	delete(GMPTH1);
	