function [TABLE,NETSET,DHCPSRVS] = Get_MacFQDNs(USERNAME,PASSWORD)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
!ping -t BBB1.wtecs.net
HOSTNAME='BBB1.wtecs.net';

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
ssh2_conn = utils.SSH.scp_simple_get(HOSTNAME,USERNAME,PASSWORD,FQDNRPATH,LDPATH);

ssh2_conn = utils.SSH.scp_simple_get(HOSTNAME,USERNAME,PASSWORD,'/root/.ddnswa/domain','./.tmp/');
ssh2_conn = utils.SSH.scp_simple_get(HOSTNAME,USERNAME,PASSWORD,'/root/.ddnswa/SRVs','./.tmp/');

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

end

