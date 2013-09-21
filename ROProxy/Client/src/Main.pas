unit Main;

interface

uses
	SysUtils,
	Graphics,
	Controls,
	Forms,
	StdCtrls,
	IdComponent,
	IdMappedPortTCP,
	IdBaseComponent,
	IdIntercept,
	ExtCtrls,
	ComCtrls,
	IdCustomTCPServer,
	IdContext,
	IdGlobal,
	IdSync,
	Classes;

type
	TMessageSync = class(TIdSync)
		Output : string;
//		constructor Create(AContext

	end;

type
	TForm1 = class(TForm)
		LoginProxy: TIdMappedPortTCP;
		Memo1: TMemo;
		LoginIntercept: TIdConnectionIntercept;
		CharaProxy: TIdMappedPortTCP;
		CharaIntercept: TIdConnectionIntercept;
		Label4: TLabel;
		OnOff: TButton;
		StatusBar1: TStatusBar;
		Label1: TLabel;
		GroupBox1: TGroupBox;
		Hostname: TLabeledEdit;
		LocalLoginPort: TLabeledEdit;
		LocalCharaPort: TLabeledEdit;
		ClearBtn: TButton;
		Label2: TLabel;
		SLoginPort: TLabeledEdit;
		OnOffLight: TShape;
		procedure LoginInterceptReceive(
			ASender: TIdConnectionIntercept; var ABuffer: TBytes);
		procedure LoginProxyOutboundConnect(AContext: TIdContext;
			AException: Exception);
		procedure OnOffClick(Sender: TObject);
		procedure CharaProxyOutboundConnect(AContext: TIdContext;
			AException: Exception);
		function LookUP : boolean;
		procedure Run;
		procedure Stop;
		procedure LoadINI;
		procedure SaveINI;
		procedure ClearBtnClick(Sender: TObject);
		procedure ProxyException(AContext: TIdContext;
			AException: Exception);
		procedure ProxyListenException(AThread: TIdListenerThread;
			AException: Exception);
		procedure CharaInterceptReceive(ASender: TIdConnectionIntercept;
			var ABuffer: TBytes);
		procedure FormCreate(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure CharaProxyConnect(AContext: TIdContext);
		procedure LoginProxyConnect(AContext: TIdContext);
    procedure OnOffLightMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure IdConnectionIntercept1Receive(
			ASender: TIdConnectionIntercept; var ABuffer: TBytes);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	Running : boolean = false;
	Form1: TForm1;
	SLoginHost: String;
	LoginPort: Word = 6900;
	SCharaHost: String;
	CharaPort: Word = 6121;
	CHost    : Cardinal;
	LHost    : Cardinal;
	Host     : string;
	AppPath  : string;


implementation
uses
	Winsock,
	Inifiles,
	Math;

{$R *.dfm}

function TForm1.LookUP : boolean;

	function GetIP(Hostname : string) : string;
	var
		h: PHostEnt;
	begin
		h := gethostbyname(PChar(Hostname));
		if h <> nil then
		begin
			with h^ do
			begin
				Result := format('%d.%d.%d.%d', [ord(h_addr^[0]), ord(h_addr^[1]),
						ord(h_addr^[2]), ord(h_addr^[3])]);
			end;
		end else
		begin
			Result := '0.0.0.0'
		end;

	end;

begin
	Result := true;
	//Check Connection Login Port
	if StrToIntDef(LocalLoginPort.Text, -1)  = -1 then
	begin
		Memo1.Lines.Add('Error: Invalid Integer for local login port.');
		Result := false;
	end else
	begin
		if not InRange(StrToInt(LocalLoginPort.Text),1,High(Word)) then
		begin
			Memo1.Lines.Add('Error: Integer not in range for local login port.');
			Result := false;
		end else
		begin
			LoginPort := StrToInt(LocalLoginPort.Text);
		end;
	end;
	//Check Connection Chara Port
	if StrToIntDef(LocalCharaPort.Text, -1)  = -1 then
	begin
		Memo1.Lines.Add('Error: Invalid Integer for local Character port.');
		Result := false;
	end else
	begin
		if not InRange(StrToInt(LocalCharaPort.Text),1,High(Word)) then
		begin
			Memo1.Lines.Add('Error: Integer not in range for local Character port.');
			Result := false;
		end else
		begin
			CharaPort := StrToInt(LocalCharaPort.Text);
		end;
	end;
	//Hostnames
	CHost := Cardinal(inet_addr(PChar(Hostname.Text)));
	LHost := Cardinal(inet_addr(PChar('localhost')));
	Host := GetIP(Hostname.Text);

	if (CHost = 0) or (Host = '0.0.0.0') then
	begin
		Memo1.Lines.Add('Invalid HostName/IP');
		Result := false;
	end;
end;

procedure TForm1.Run;
begin
	LoginProxy.MappedHost := Host;
	LoginProxy.MappedPort := StrToIntDef(SLoginPort.Text,6900);
	LoginProxy.DefaultPort := LoginPort;

	CharaProxy.MappedHost := Host;
	CharaProxy.DefaultPort := CharaPort;

	LoginProxy.Active := true;
	CharaProxy.Active := true;

	OnOff.Caption := 'Stop';
	Running := true;
	StatusBar1.Panels.Items[0].Text := 'Online';
end;

procedure TForm1.Stop;
begin
	LoginProxy.Active := false;
	CharaProxy.Active := false;
	OnOff.Caption := 'Start';
	Running := false;
	StatusBar1.Panels.Items[0].Text := 'Offline';
end;

procedure TForm1.LoadINI;
var
	ini : TInifile;
	Sect : TStringList;
begin
	ini := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
	Sect := TStringList.Create;
	//
	ini.ReadSectionValues('Server',Sect);
	SLoginPort.Text := Sect.Values['LoginPort'];
	//
	ini.ReadSectionValues('Proxy',Sect);
	Hostname.Text := Sect.Values['Hostname'];
	LocalLoginPort.Text := Sect.Values['LoginListen'];
	LocalCharaPort.Text := Sect.Values['CharaListen'];
	//
	Sect.Free;
	ini.Free;
end;

procedure TForm1.SaveINI;
var
	ini : TInifile;
begin
	ini := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
	ini.WriteString('Server','LoginPort',SLoginPort.Text);
	//
	ini.WriteString('Proxy','Hostname',Hostname.Text);
	ini.WriteString('Proxy','LoginListen',LocalLoginPort.Text);
	ini.WriteString('Proxy','CharaListen',LocalCharaPort.Text);
	ini.Free;
end;

//Login Server
procedure TForm1.LoginProxyConnect(AContext: TIdContext);
begin
	Memo1.Lines.Add('Login Proxy: Client Connected.');
end;

procedure TForm1.LoginProxyOutboundConnect(
	AContext: TIdContext; AException: Exception);
begin
	AContext.Connection.IOHandler.Intercept := LoginIntercept;
	Memo1.Lines.Add('Login Proxy: Client Connected to Server.');
end;

procedure TForm1.LoginInterceptReceive(
	ASender: TIdConnectionIntercept; var ABuffer: TBytes);
var
	ID : word;
	Port : word;
	AStream : TMemoryStream;
begin
	try
		AStream := TMemoryStream.Create;
		WriteTIdBytesToStream(AStream,ABuffer);
		AStream.Read(ID,2);
		if ID = $0069 then
		begin
			if AStream.Size > 47 then
			begin
				//Seek to the host position
				AStream.Seek(47,soFromBeginning);
				//Overwrite with localhost, so client loops back
				AStream.Write(LHost,4);
				//Read the remote port
				AStream.Read(Port,2);
				//Tell proxy to go to the remote port
				CharaProxy.MappedPort := Port;
				//backup 2
				AStream.Seek(51,soFromBeginning);
				//Overwrite the port so client loops back
				AStream.Write(CharaPort,2);
				Memo1.Lines.Add('Login Proxy: Character Server Select packet intercepted and modified.')
			end;
		end;
		ReadTIdBytesFromStream(AStream,ABuffer,AStream.Size);
	finally
		AStream.Free;
	end;
end;

//Exceptions
procedure TForm1.ProxyException(AContext: TIdContext;
	AException: Exception);
begin
	AContext.Connection.Disconnect;
end;

procedure TForm1.ProxyListenException(AThread: TIdListenerThread;
	AException: Exception);
begin
	AThread.Binding.CloseSocket;
end;

//Chara Server
procedure TForm1.CharaProxyConnect(AContext: TIdContext);
begin
	Memo1.Lines.Add('Character Proxy: Client Connected.');
end;

procedure TForm1.CharaProxyOutboundConnect(AContext: TIdContext;
	AException: Exception);
begin
	AContext.Connection.IOHandler.Intercept := CharaIntercept;
	Memo1.Lines.Add('Character Proxy: Client Connected to Server.');
end;

procedure TForm1.CharaInterceptReceive(
	ASender: TIdConnectionIntercept; var ABuffer: TBytes);
var
	ID : word;
	AStream : TMemoryStream;
begin
	try
		AStream := TMemoryStream.Create;
		WriteTIdBytesToStream(AStream,ABuffer);
		AStream.Read(ID,2);
		if ID = $0071 then
		begin
			//Seek to hostcardinal
			AStream.Seek(22,soFromBeginning);
			//Send them to the hostname
			AStream.Write(CHost,4);
			Memo1.Lines.Add('Character Proxy: Zone Server packet intercepted and modified.');
		end;
		ReadTIdBytesFromStream(AStream,ABuffer,AStream.Size);
	finally
		AStream.Free;
	end;
end;

//Misc
procedure TForm1.OnOffClick(Sender: TObject);
begin
	if not Running then
	begin
		if LookUP then
		begin
			Run;
			OnOffLight.Brush.Color := clLime;
		end;
	end else
	begin
		Stop;
		OnOffLight.Brush.Color := clRed;
	end;
end;

procedure TForm1.ClearBtnClick(Sender: TObject);
begin
	Memo1.Lines.Clear;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
	AppPath := ExtractFilePath(ParamStr(0));
	LoadINI;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	SaveINI;
end;

procedure TForm1.OnOffLightMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
	OnOffClick(Sender);
end;

procedure TForm1.IdConnectionIntercept1Receive(
	ASender: TIdConnectionIntercept; var ABuffer: TBytes);
begin
//
end;

end.
