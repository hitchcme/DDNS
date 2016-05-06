function [TABLE] = Send_MacFQDNs(TABLE)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
HOSTNAME='BBB1.local'
USERNAME='root'
PASSWORD='odyssey2000'
FQDNRPATH='/root/.ddnswa/MACFQDNs'
FQDNPATH='./tmp/MACFQDNs'
mkdir('./tmp')
ssh2_conn = utils.SSH.scp_simple_put(HOSTNAME,USERNAME,PASSWORD,FQDNRPATH,FQDNPATH)
%copyfile('MACFQDNs','./tmp/MACFQDNs')
%delete('./MACFQDNs')

fid=fopen(FQDNPATH)
tline = fgetl(fid);
while ischar(tline)
	MAC = utils.misc.strsplit(tline,' ');
	FQDN = MAC(2)
	MAC(2) = []
	MNtblline=table(MAC,FQDN)
	if exist('TABLE','var')
		TABLE=[TABLE;MNtblline]
	else
		TABLE = MNtblline
	end
	tline = fgetl(fid);
	TABLE.MAC = TABLE.MAC
end
fclose all
end
