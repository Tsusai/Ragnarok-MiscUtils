unit VidarLoad;
(*------------------------------------------------------------------------------
Copyright (c) 2005, Matthew Mazanec (Tsusai), Kubia System Projects
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

		* Redistributions of source code must retain the above copyright notice,
			this list of conditions and the following disclaimer.
		* Redistributions in binary form must reproduce the above copyright notice,
			this list of conditions and the following disclaimer in the documentation
			and/or other materials provided with the distribution.
		* Neither the name of Kubia Systems nor the names of its contributors may be
			used to endorse or promote products derived from this software without
			specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
------------------------------------------------------------------------------*)

interface
uses
	{Delphi}
	{Converter}
	Main;

procedure VidarAccountLoad(AccountFile : string);
procedure VidarCharacterLoad(ID, CharacterFile : string; var ActiveList : TActive);
procedure VidarGuildLoad(GuildTxtFile : String);
procedure VidarPartyLoad(PartyTxtFile : String);
procedure VidarCastleLoad(CastleTxtFile : String);

implementation
uses
	{Delphi}
	SysUtils,
	Classes,
	{Converter}
	REEDAccSave,
	REEDCharaSave,
	REEDGuildSave,
	REEDPartySave,
	REEDCastleSave;


procedure VidarAccountLoad(AccountFile : string);  //loads filename
var
	AccID : Integer;
	AccStr : string;
	AccountData : TStringList;
	fileName : string;
begin

	fileName := ExtractFileName(AccountFile);
	AccStr := ChangeFileExt(fileName, '');
	AccID := StrToIntDef(AccStr, -1);
	if AccID <> -1 then begin
		MkDir(AppPath + 'gamedata\Accounts\' + AccStr + '\');
		AccountData := TStringList.Create;
		AccountData.LoadFromFile(AccountFile);
		REEDAccountSaveBasic(AccountData[0]);
		AccountData.Free;

	end;
end;

procedure VidarCharacterLoad(ID, CharacterFile : string; var ActiveList : TActive);
var
	CharaID : Integer;
	CharaStr : string;
	CharaFile : TStringList;
	Dir : string;
begin
	CharaStr := ChangeFileExt(CharacterFile, '');
	CharaID := StrToIntDef(CharaStr, -1);
	if CharaID <> -1 then begin
		MkDir(AppPath + 'gamedata\Accounts\' + ID + '\Characters\' + CharaStr + '\');
		Dir := (AppPath + 'gamedata\Accounts\' + ID + '\Characters\' + CharaStr + '\');
		CharaFile := TStringList.Create;
		CharaFile.LoadFromFile(CharacterFile);
		REEDCharacterSaveRoot(Dir, CharaStr, ActiveList, CharaFile);
		CharaFile.Free;
	end;
end;

procedure VidarGuildLoad(GuildTxtFile : String);
var
	idx : integer;
	guildset : TStringList;
	GuildFile : TStringList;
begin
	GuildFile := TStringList.Create;
	GuildFile.LoadFromFile(GuildTxtFile);
	if (Guildfile.Count mod 5) = 0 then begin
		guildset := TStringList.Create;
		for idx := 0 to ((guildfile.Count div 5) - 1) do begin
			guildset.Clear;
			guildset.Add(guildfile.Strings[0+idx*5]);
			guildset.Add(guildfile.Strings[1+idx*5]);
			guildset.Add(guildfile.Strings[2+idx*5]);
			guildset.Add(guildfile.Strings[3+idx*5]);
			guildset.Add(guildfile.Strings[4+idx*5]);
			REEDGuildSaveRoot(guildset);
		end;
		guildset.Free;
	end;
	GuildFile.Free;
end;

procedure VidarPartyLoad(PartyTxtFile : String);
var
	PartyList : TStringList;
	idx : integer;
begin
	PartyList := TStringList.Create;
	PartyList.LoadFromFile(PartyTxtFile);
	for idx := 0 to PartyList.Count - 1 do begin
		REEDSavePartyInfo(PartyList.Strings[idx]);
	end;
	PartyList.Free;
end;

procedure VidarCastleLoad(CastleTxtFile : String);
var
	CastleList : TStringList;
	idx : integer;
begin
	CastleList := TStringList.Create;
	CastleList.LoadFromFile(CastleTxtFile);
	for idx := 0 to CastleList.Count - 1 do begin
		REEDSaveCastlesRoot(CastleList.Strings[idx]);
	end;
	CastleList.Free;
end;


end.
