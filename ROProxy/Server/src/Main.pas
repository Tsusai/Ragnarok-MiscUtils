unit Main;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, IdComponent, IdTCPServer, IdMappedPortTCP,
	IdBaseComponent, IdIntercept, ExtCtrls, Sockets, Math, ComCtrls, Inifiles;

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
		GroupBox2: TGroupBox;
		SLoginName: TLabeledEdit;
		SLoginPort: TLabeledEdit;
		SCharaPort: TLabeledEdit;
		SCharaName: TLabeledEdit;
		Button2: TButton;
		Label2: TLabel;
		procedure LoginInterceptReceive(
			ASender: TIdConnectionIntercept; AStream: TStream);
		procedure LoginProxyOutboundConnect(AThread: TIdMappedPortThread;
			AException: Exception);
		procedure OnOffClick(Sender: TObject);
		procedure CharaProxyOutboundConnect(AThread: TIdMappedPortThread;
			AException: Exception);
		function LookUP : boolean;
		procedure Refresh;
		procedure Run;
		procedure Stop;
		procedure LoadINI;
		procedure SaveINI;
		procedure UpdateConnected;
		procedure Button2Click(Sender: TObject);
		procedure ProxyException(AThread: TIdPeerThread;
			AException: Exception);
		procedure ProxyListenException(AThread: TIdListenerThread;
			AException: Exception);
		procedure CharaInterceptReceive(ASender: TIdConnectionIntercept;
			AStream: TStream);
		procedure FormCreate(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	Connected : integer = 0;
	Running : boolean = false;
	Form1: TForm1;
	SLoginHost: String;
	LoginPort: Word;
	SCharaHost: String;
	CharaPort: Word;
	HostAddr : Cardinal;
	STemp    : array [1..3] of string;
	AppPath : string;


implementation

{$R *.dfm}

function TForm1.LookUP : boolean;
var
	ASocket : TIpSocket;
	idx : byte;
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
	ASocket := TIpSocket.Create(Form1);
	ASocket.Active := true;
	//Hostnames
	STemp[1] := IntToStr(Cardinal(ASocket.GetSocketAddr(Hostname.Text,LocalLoginPort.Text).sin_addr.S_addr));
	STemp[2] := ASocket.LookupHostAddr(SLoginName.Text);
	STemp[3] := ASocket.LookupHostAddr(SCharaName.Text);
	for idx := 1 to 3 do
	begin
		if (STemp[idx] = '0') or (STemp[idx] = '0.0.0.1') then
		begin
			case idx of
			1: Memo1.Lines.Add('Error: invalid IP or Hostname WAN.');
			2: Memo1.Lines.Add('Error: invalid IP or Hostname Login Server.');
			3: Memo1.Lines.Add('Error: invalid IP or Hostname Character Server.');
			end;
			Result := false;
		end else
		begin
			case idx of
			1:
				begin
					HostAddr := Cardinal(STemp[idx]);
				end;
			2:
				begin
					SLoginHost := STemp[idx];
				end;
			3:
				begin
					SCharaHost := STemp[idx];
				end;
			end;
		end;
	end;
	ASocket.Free;
end;

procedure TForm1.Refresh;
var
	ASocket : TIpSocket;
begin
	ASocket := TIpSocket.Create(Self);
	HostAddr := Cardinal(ASocket.GetSocketAddr(Hostname.Text,LocalLoginPort.Text).sin_addr.S_addr);
	ASocket.Free;
end;

procedure TForm1.Run;
begin
	LoginProxy.MappedHost := SLoginHost;
	LoginProxy.MappedPort := StrToIntDef(SLoginPort.Text,6900);
	LoginProxy.DefaultPort := LoginPort;

	CharaProxy.MappedHost := SCharaHost;
	CharaProxy.MappedPort := StrToIntDef(SCharaPort.Text,6121);
	CharaProxy.DefaultPort := CharaPort;

	LoginProxy.Active := true;
	CharaProxy.Active := true;

	OnOff.Caption := 'Stop';
	Running := true;
	StatusBar1.Panels.Items[1].Text := 'Online';
end;

procedure TForm1.Stop;
begin
	LoginProxy.Active := false;
	CharaProxy.Active := false;
	OnOff.Caption := 'Start';
	Running := false;
	StatusBar1.Panels.Items[1].Text := 'Offline';
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
	SLoginName.Text := Sect.Values['LoginServer'];
	SLoginPort.Text := Sect.Values['LoginPort'];
	SCharaName.Text := Sect.Values['CharaServer'];
	SCharaPort.Text := Sect.Values['CharaPort'];
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
	ini.WriteString('Server','LoginServer',SLoginName.Text);
	ini.WriteString('Server','LoginPort',SLoginPort.Text);
	ini.WriteString('Server','CharaServer',SCharaName.Text);
	ini.WriteString('Server','CharaPort',SCharaPort.Text);
	//
	ini.WriteString('Proxy','Hostname',Hostname.Text);
	ini.WriteString('Proxy','LoginListen',LocalLoginPort.Text);
	ini.WriteString('Proxy','CharaListen',LocalCharaPort.Text);
	ini.Free;
end;

procedure TForm1.UpdateConnected;
const
	Msg = 'Users Routed: %d';
begin
	StatusBar1.Panels.Items[0].Text := Format(Msg, [Connected]);
end;

//Login Server
procedure TForm1.LoginProxyOutboundConnect(
	AThread: TIdMappedPortThread; AException: Exception);
begin
	AThread.OutboundClient.Intercept := LoginIntercept;
	Inc(Connected);
	UpdateConnected;
end;

procedure TForm1.LoginInterceptReceive(
	ASender: TIdConnectionIntercept; AStream: TStream);
var
	ID : word;
begin
	AStream.Read(ID,2);
	if ID = $0069 then
	begin
		if AStream.Size > 47 then
		begin
			AStream.Seek(47,soFromBeginning);
			AStream.Write(HostAddr,4);
			AStream.Write(CharaPort,2);
		end;
	end;
end;

//Exceptions
procedure TForm1.ProxyException(AThread: TIdPeerThread;
	AException: Exception);
begin
	AThread.Connection.Disconnect;
end;

procedure TForm1.ProxyListenException(AThread: TIdListenerThread;
	AException: Exception);
begin
	AThread.Binding.CloseSocket;
end;

//Chara Server
procedure TForm1.CharaProxyOutboundConnect(AThread: TIdMappedPortThread;
	AException: Exception);
begin
	AThread.OutboundClient.Intercept := CharaIntercept;
end;

procedure TForm1.CharaInterceptReceive(
	ASender: TIdConnectionIntercept; AStream: TStream);
var
	ID : word;
begin
	AStream.Read(ID,2);
	if ID = $0071 then
	begin
		AStream.Seek(22,soFromBeginning);
		AStream.Write(HostAddr,4);
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
		end;
	end else
	begin
		Stop;
	end;
end;

procedure TForm1.Button2Click(Sender: TObject);
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

end.
