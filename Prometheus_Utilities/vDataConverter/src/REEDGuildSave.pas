unit REEDGuildSave;
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
	Classes;

procedure REEDGuildSaveRoot(Guildinfo : TStringList);

implementation
uses
	{Delphi}
	SysUtils,
	{Converter}
	Main,
	Misc;

procedure REEDGuildSaveBasic(
	var ID : String;
	var Path : String;
	BaseLine : String
	);
var
	BaseInfo,
	datafile : TStringList;
begin
	BaseInfo := TStringList.Create;
	datafile := TStringList.Create;
	BaseInfo.CommaText := BaseLine;

	datafile.Add('NAM : ' + BaseInfo[ 1]);
	datafile.Add('GID : ' + BaseInfo[ 0]);
	datafile.Add('GLV : ' + BaseInfo[ 2]);
	datafile.Add('EXP : ' + BaseInfo[ 3]);
	datafile.Add('SKP : ' + BaseInfo[ 4]);
	datafile.Add('NT1 : ' + BaseInfo[ 5]);
	datafile.Add('NT2 : ' + BaseInfo[ 6]);
	datafile.Add('AGT : ' + BaseInfo[ 7]);
	datafile.Add('EMB : ' + BaseInfo[ 8]);
	datafile.Add('PSN : ' + BaseInfo[ 9]);
	datafile.Add('DFV : ' + BaseInfo[10]);
	datafile.Add('DRW : ' + BaseInfo[11]);

	//SET DIRECTORY STRUCTURE
	ID := BaseInfo[ 0];
	Path := (Path + ID + '\');
	MkDir(Path);

	datafile.SaveToFile(Path + 'Guild.txt');

	BaseInfo.Free;
	datafile.Free;
end;

function REEDGuildSaveMembers(ID, Path, BaseLine : string) : integer;
var
	BaseInfo,
	datafile : TStringList;
	idx : integer;
begin
	Result := 0;
	BaseInfo := TStringList.Create;
	datafile := TStringList.Create;
	BaseInfo.CommaText := BaseLine;

	datafile.Add(' CID    : PO : EXP        ');
	datafile.Add('--------------------------');

	for idx := 0 to 35 do begin
		if StrToIntDef(BaseInfo[idx*3],0) = 0 then continue;
		datafile.Add( Format('%7s : %2s : %10s',
			[ BaseInfo[idx*3],

			BaseInfo[1+idx*3],

			BaseInfo[2+idx*3]

			])
		);
		Inc(Result);
		CIDandGID.Add(BaseInfo[idx*3] + '=' + ID);
	end;
	datafile.SaveToFile(Path + 'Members.txt');

	BaseInfo.Free;
	datafile.Free;
end;

procedure REEDGuildSavePositions(Path, BaseLine : String);

	function CvtNm(number : string) : char;
	begin
		if number = '1' then Result := 'Y'
		else Result := 'N';
	end;

var
	BaseInfo,
	datafile : TStringList;
	idx : integer;
begin
	BaseInfo := TStringList.Create;
	datafile := TStringList.Create;
	BaseInfo.CommaText := BaseLine;
	datafile.Add(' ID : I : P : XP : NAME');
	datafile.Add('----------------------------------------------------------');

	for idx := 0 to 19 do
		datafile.Add(Format('%3d : %s : %s : %2s : %s',
			[	idx+1,
				CvtNm(BaseInfo[idx*4+1]),
				CvtNm(BaseInfo[idx*4+2]),
				BaseInfo[idx*4+3],
				BaseInfo[idx*4+0]
			]));


	datafile.SaveToFile(Path + 'Positions.txt');

	BaseInfo.Free;
	datafile.Free;
end;

procedure REEDGuildSaveSkills(Path, BaseLine : string);
var
	BaseInfo,
	datafile : TStringList;
	Total, idx : integer;
begin
	BaseInfo := TStringList.Create;
	datafile := TStringList.Create;
	BaseInfo.CommaText := BaseLine;

	datafile.Add(' SK ID : LV : SKILL NAME');
	datafile.Add('-------------------------------');
	Total := StrToIntDef(BaseInfo[0], -1 );
	if Total > 0 then begin
		BaseInfo.Delete(0);
		for idx := 0 to Total - 1 do begin
			datafile.Add(Format('%6s : %2s : NA',
				[	BaseInfo[idx*2],
					BaseInfo[idx*2+1]
				]));
		end;
	end;

	datafile.SaveToFile(Path + 'Skills.txt');

	BaseInfo.Free;
	datafile.Free;
end;

procedure REEDGuildSaveMisc(Path : String);
var
	datafile : TStringList;
begin
	MakeInventories(Path + 'Storage.txt','',True);

	datafile := TStringList.Create;
	datafile.Clear;
	datafile.Add(' GID    : T : GUILD NAME');
	datafile.Add('-----------------------------------------------------');
	datafile.SaveToFile(Path + 'Diplomacy.txt');

	datafile.Clear;
	datafile.Add(' CHARACTER NAME          : ACCOUNT NAME            : BAN REASON');
	datafile.Add('------------------------------------------------------------------------------------------------------');
	datafile.SaveToFile(Path + 'BanList.txt');

	datafile.Free;
end;

procedure REEDGuildSaveRoot(Guildinfo : TStringList);
var
	Path : string;
	ID : String;
	MemberTotal : integer;
begin
	Path := (AppPath + 'gamedata\Guilds\');
	ID := '';
	REEDGuildSaveBasic(ID, Path, Guildinfo[0]); //Line1
	MemberTotal := REEDGuildSaveMembers(ID, Path, Guildinfo[1]); //Line2
	if MemberTotal <> 0 then begin
		REEDGuildSavePositions(Path, Guildinfo[2]); //Line3
		REEDGuildSaveSkills(Path, Guildinfo[3]); //Line4
		REEDGuildSaveMisc(Path); //Making up for line 5 since its crap
	end else begin
		Form1.Memo1.Lines.Add(
			Format('Guild ID %s has no members and will not be converted', [ID])
		);
		DeleteFile(Path + 'Guild.txt');
		DeleteFile(Path + 'Members.txt');
		RmDir(Path);
	end;
end;


end.
