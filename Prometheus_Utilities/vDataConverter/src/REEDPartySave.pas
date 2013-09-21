unit REEDPartySave;

interface

procedure REEDSavePartyInfo(Party : string);

implementation
uses
	{Delphi}
	Classes,
	SysUtils,
	{Converter}
	Main;

procedure REEDSavePartyInfo(Party : string);
var
	Dir : String;
	PartyInfo : TStringList;
	datafile : TStringList;
	idx : byte;
begin
	PartyInfo := TStringList.Create;
	datafile := TStringList.Create;
	PartyInfo.CommaText := Party;
	MkDir(AppPath + 'gamedata\Parties\' + PartyInfo.Strings[0] + '\');
	Dir := (AppPath + 'gamedata\Parties\' + PartyInfo.Strings[0] + '\');

	datafile.Clear;
	datafile.Add('NAM : ' + PartyInfo.Strings[1]);
	datafile.Add('PID : ' + PartyInfo.Strings[0]);
	datafile.SaveToFile(Dir + 'Settings.txt');

	datafile.Clear;
	datafile.Add(' CID    : NAME');
	datafile.Add('-------------------------------------------------');
	for idx := 0 to 11 do begin
		if PartyInfo[idx+2] <> '0' then begin
			datafile.Add( Format('%7s : NA', [PartyInfo.Strings[idx+2]] ));
			CIDandPID.Add( Format('%s=%s', [ PartyInfo.Strings[idx+2] , PartyInfo.Strings[0] ]));
		end;
	end;
	datafile.SaveToFile(Dir + 'Members.txt');

	datafile.Free;
	PartyInfo.Free;

end;

end.
