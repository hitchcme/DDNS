function varargout = DDNSMACmanager(varargin)
% DDNSMACMANAGER MATLAB code for DDNSMACmanager.fig
%      DDNSMACMANAGER, by itself, creates a new DDNSMACMANAGER or raises the existing
%      singleton*.
%
%      H = DDNSMACMANAGER returns the handle to a new DDNSMACMANAGER or the handle to
%      the existing singleton*.
%
%      DDNSMACMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DDNSMACMANAGER.M with the given input arguments.
%
%      DDNSMACMANAGER('Property','Value',...) creates a new DDNSMACMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DDNSMACmanager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DDNSMACmanager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DDNSMACmanager

% Last Modified by GUIDE v2.5 06-May-2016 00:50:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DDNSMACmanager_OpeningFcn, ...
                   'gui_OutputFcn',  @DDNSMACmanager_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DDNSMACmanager is made visible.
function DDNSMACmanager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DDNSMACmanager (see VARARGIN)

% Choose default command line output for DDNSMACmanager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

[USERNAME,PASSWORD] = utils.SSH.logindlg;
handles.USERNAME = USERNAME;
handles.PASSWORD = PASSWORD;

[TABLE,NETSET,DHCPSRVS] = Get_MacFQDNs(USERNAME,PASSWORD);

TABLE.MAC = upper(TABLE.MAC);
handles.TABLE = TABLE;
MACARR = TABLE.MAC;
MACARR = char(transpose(regexprep(MACARR,':',' ')));
MACTBL = table(MACARR(:,1:2),MACARR(:,4:5),MACARR(:,7:8),MACARR(:,10:11),MACARR(:,13:14),MACARR(:,16:17));
MACTBL.Properties.VariableNames = {'D5' 'D4' 'D3' 'D2' 'D1' 'D0'};
MACTBL.D5 = cellstr(MACTBL.D5);
MACTBL.D4 = cellstr(MACTBL.D4);
MACTBL.D3 = cellstr(MACTBL.D3);
MACTBL.D2 = cellstr(MACTBL.D2);
MACTBL.D1 = cellstr(MACTBL.D1);
MACTBL.D0 = cellstr(MACTBL.D0);
MACTBL.SPACE = regexprep(regexprep(MACTBL.D0,'[A-Z]',''),'[0-9]','');
MACTBL.Name = TABLE.FQDN;

TABLE = MACTBL;

handles.uitable1.Data = table2array(TABLE);
handles.uitable2.Data = NETSET;
handles.uitable3.Data(:,2)=[];
handles.uitable3.Data = DHCPSRVS;
handles.DHCPSRVs = DHCPSRVS;
handles.NETSET = NETSET;
guidata(hObject, handles);
handles.uitable1.FontUnits;
handles.uitable1.FontSize = 12;
handles.uitable2.FontSize = 12;
handles.uitable3.FontSize = 12;
% UIWAIT makes DDNSMACmanager wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DDNSMACmanager_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in submit.
function submit_Callback(hObject, eventdata, handles)
% hObject    handle to submit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MACwv = handles.uitable1.Data(:,1:6);
MACwv(:,1:5) = strcat(MACwv(:,1:5),':');
MACwv(:,1) = cellstr(strcat(MACwv(:,1),MACwv(:,2),MACwv(:,3),MACwv(:,4),MACwv(:,5),MACwv(:,6)));
MACwv(:,2:6) = [];
NAMEwv = handles.uitable1.Data(:,8);
MAC = upper(MACwv);
FQDN = NAMEwv;

TABLE = table(MAC,FQDN);
LINES = cellstr(strcat(TABLE.MAC(:),{' '},TABLE.FQDN(:)));

fid = fopen('./.tmp/MACFQDNs_wf','wt');
tline = fgetl(fid);
for i=1:size(LINES,1)
	MACBITS = cell2mat(handles.uitable1.Data(i,1:6));
	NAME = cell2mat(handles.uitable1.Data(i,8));
	if size(MACBITS,2) < 12 && size(NAME,2) > 0
		LINES(i) = cellstr(strcat(handles.TABLE.MAC(i),{' '},handles.TABLE.FQDN(i)));
	elseif size(MACBITS,2) < 12 && size(NAME,2) == 0
		LINES(i) = cellstr('');
	end

	if size(LINES(i),2) > 0
		fprintf(fid, char(LINES(i)));
		fprintf(fid,'\n');
		tline = fgetl(fid);
	end
end
fclose all;
copyfile('./.tmp/MACFQDNs_wf','./.tmp/MACFQDNs');
delete('./.tmp/MACFQDNs_wf');



% Write DHCP Servers to file
fid = fopen('./.tmp/SRVs_wf','wt');
tline = fgetl(fid);
for i=1:size(handles.uitable3.Data,1)
	if size(handles.uitable3.Data(i),1) > 0
		char(handles.uitable3.Data(i));
		fprintf(fid, char(handles.uitable3.Data(i)));
		fprintf(fid,'\n');
		tline = fgetl(fid);
	end
end
fclose all;
copyfile('./.tmp/SRVs_wf','./.tmp/SRVs');
delete('./.tmp/SRVs_wf');

% Write Network Settings to file
fid = fopen('./.tmp/domain_wf','wt');
tline = fgetl(fid);
for i=1:size(handles.uitable2.Data,1)
	STR = char(strcat(handles.uitable2.Data(i,1),{' '},handles.uitable2.Data(i,2)));
	if size(STR,2) > 0
		fprintf(fid, STR);
		fprintf(fid,'\n');
		tline = fgetl(fid);
	end
end
fclose all;
copyfile('./.tmp/domain_wf','./.tmp/domain');
delete('./.tmp/domain_wf');


HOSTNAME = 'BBB1.local';

USERNAME = handles.USERNAME;
PASSWORD = handles.PASSWORD;


ssh2_conn = utils.SSH.scp_simple_put(HOSTNAME,USERNAME,PASSWORD,'./.tmp/MACFQDNs','/root/.ddnswa/');
ssh2_conn = utils.SSH.scp_simple_put(HOSTNAME,USERNAME,PASSWORD,'./.tmp/SRVs','/root/.ddnswa/');
ssh2_conn = utils.SSH.scp_simple_put(HOSTNAME,USERNAME,PASSWORD,'./.tmp/domain','/root/.ddnswa/');
TABLE = Get_MacFQDNs(USERNAME,PASSWORD);

TABLE.MAC = upper(TABLE.MAC);
handles.TABLE = TABLE;
MACARR = TABLE.MAC;
MACARR = char(transpose(regexprep(MACARR,':',' ')));
MACTBL = table(MACARR(:,1:2),MACARR(:,4:5),MACARR(:,7:8),MACARR(:,10:11),MACARR(:,13:14),MACARR(:,16:17));
MACTBL.Properties.VariableNames = {'D5' 'D4' 'D3' 'D2' 'D1' 'D0'};
MACTBL.D5 = cellstr(MACTBL.D5);
MACTBL.D4 = cellstr(MACTBL.D4);
MACTBL.D3 = cellstr(MACTBL.D3);
MACTBL.D2 = cellstr(MACTBL.D2);
MACTBL.D1 = cellstr(MACTBL.D1);
MACTBL.D0 = cellstr(MACTBL.D0);
MACTBL.SPACE = regexprep(regexprep(MACTBL.D0,'[A-Z]',''),'[0-9]','');
MACTBL.Name = TABLE.FQDN;

TABLE = MACTBL;

handles.uitable1.Data = table2array(TABLE);
guidata(hObject, handles);

handles.uitable1.FontSize = 12;
handles.uitable2.FontSize = 12;
handles.uitable3.FontSize = 12;

% --- Executes on button press in AddRecord.
function AddRecord_Callback(hObject, eventdata, handles)
% hObject    handle to AddRecord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.uitable1.Data(size(handles.uitable1.Data,1)+1,:) = cellstr('');

% --- Executes on button press in ImportRecord.
function ImportRecord_Callback(hObject, eventdata, handles)
% hObject    handle to ImportRecord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ImportRecord
