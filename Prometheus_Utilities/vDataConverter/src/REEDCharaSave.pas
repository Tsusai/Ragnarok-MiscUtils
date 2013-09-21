unit REEDCharaSave;
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
	Classes,
	{Converter}
	Main;

procedure REEDCharacterSaveRoot(CharaDir, CharaIDStr : String; var ActiveList : TActive; CharaFile : TStringList);

implementation
uses
	{Delphi}
	SysUtils,
	{Converter}
	Misc;


procedure RetrieveSpecialIDs(var datafile : TStringList; CharaID : String);
var
	ID : string;
begin
	if CIDandGID.IndexOfName(CharaID) <> -1 then
		ID := CIDandGID.ValueFromIndex[CIDandGID.IndexOfName(CharaID)]
	else ID := '0';
	datafile.Add('GID : ' + ID);
		if CIDandPID.IndexOfName(CharaID) <> -1 then
		ID := CIDandPID.ValueFromIndex[CIDandPID.IndexOfName(CharaID)]
	else ID := '0';
	datafile.Add('PID : ' + ID);
end;

procedure REEDCharacterSaveBase(Dir : String; var ActiveList : TActive; BaseLine : String);
var
	BaseInfo,
	datafile : TStringList;
begin
	BaseInfo := TStringList.Create;
	BaseInfo.CommaText := BaseLine;
	if BaseInfo.Count = 53 then begin
		datafile := TStringList.Create;
		datafile.Add('NAM : ' + BaseInfo[1]);
		datafile.Add('AID : ' + BaseInfo[52]);
		datafile.Add('CID : ' + BaseInfo[0]);
		datafile.Add('JID : ' + BaseInfo[2]);
		datafile.Add('BLV : ' + BaseInfo[3]);
		datafile.Add('BXP : ' + BaseInfo[4]);
		datafile.Add('STP : ' + BaseInfo[5]);
		datafile.Add('JLV : ' + BaseInfo[6]);
		datafile.Add('JXP : ' + BaseInfo[7]);
		datafile.Add('SKP : ' + BaseInfo[8]);
		datafile.Add('ZEN : ' + BaseInfo[9]);

		datafile.Add('ST1 : ' + BaseInfo[10]);
		datafile.Add('ST2 : ' + BaseInfo[11]);
		datafile.Add('OPT : ' + BaseInfo[12]);
		datafile.Add('KAR : ' + BaseInfo[13]);
		datafile.Add('MAN : ' + BaseInfo[14]);

		datafile.Add('CHP : ' + BaseInfo[15]);
		datafile.Add('CSP : ' + BaseInfo[16]);
		datafile.Add('SPD : ' + BaseInfo[17]);
		datafile.Add('HAR : ' + BaseInfo[18]);
		datafile.Add('C_2 : ' + BaseInfo[19]);
		datafile.Add('C_3 : ' + BaseInfo[20]);
		datafile.Add('WPN : ' + BaseInfo[21]);
		datafile.Add('SHD : ' + BaseInfo[22]);
		datafile.Add('HD1 : ' + BaseInfo[23]);
		datafile.Add('HD2 : ' + BaseInfo[24]);
		datafile.Add('HD3 : ' + BaseInfo[25]);
		datafile.Add('HCR : ' + BaseInfo[26]);
		datafile.Add('CCR : ' + BaseInfo[27]);

		datafile.Add('STR : ' + BaseInfo[28]);
		datafile.Add('AGI : ' + BaseInfo[29]);
		datafile.Add('VIT : ' + BaseInfo[30]);
		datafile.Add('INT : ' + BaseInfo[31]);
		datafile.Add('DEX : ' + BaseInfo[32]);
		datafile.Add('LUK : ' + BaseInfo[33]);

		datafile.Add('CNR : ' + BaseInfo[34]);

		datafile.Add('MAP : ' + BaseInfo[35]);
		datafile.Add('MPX : ' + BaseInfo[36]);
		datafile.Add('MPY : ' + BaseInfo[37]);

		datafile.Add('MSP : ' + BaseInfo[38]);
		datafile.Add('MSX : ' + BaseInfo[39]);
		datafile.Add('MSY : ' + BaseInfo[40]);

		datafile.Add('PLG : ' + BaseInfo[50]);
		datafile.Add('PLV : ' + BaseInfo[51]);

		RetrieveSpecialIDs(datafile,BaseInfo[0]);

		datafile.SaveToFile(Dir + 'Character.txt');

		ActiveList.Name[StrToInt(BaseInfo[34])] := BaseInfo[1];

		datafile.Free;
	end else
		Form1.Memo1.Lines.Add(
			Format('Error With Character ID %s on Possible Account ID %s',
			[ BaseInfo[0],
				BaseInfo[BaseInfo.Count - 1]
			])
		);
	Baseinfo.Free;
end;

procedure REEDCharacterSaveMemo(CharaDir, BaseLine : String);
var
	idx : byte;
	BaseInfo,
	datafile : TStringList;
begin
	BaseInfo := TStringList.Create;
	datafile := TStringList.Create;
	BaseInfo.CommaText := BaseLine;
	for idx := 0 to 2 do begin
		datafile.Add(Format('M%dN : %s', [idx+1, BaseInfo[41+(idx*3)]]));
		datafile.Add(Format('M%dX : %s', [idx+1, BaseInfo[42+(idx*3)]]));
		datafile.Add(Format('M%dY : %s', [idx+1, BaseInfo[43+(idx*3)]]));
	end;
	datafile.SaveToFile(CharaDir + 'ActiveMemos.txt');

	datafile.Free;
	Baseinfo.Free;

end;

procedure REEDCharacterSaveSkill(CharaDir, BaseLine : String);
var
	idx, Total : Integer;
	BaseInfo,
	datafile : TStringList;
begin
	BaseInfo := TStringList.Create;
	datafile := TStringList.Create;
	BaseInfo.CommaText := BaseLine;
	Total := StrToInt(BaseInfo[0]);
	BaseInfo.Delete(0);
	datafile.Add(' SID : LV : NAME');
	datafile.Add('----------------------------------');
	for idx := 0 to Total - 1 do
		datafile.Add(Format('%4s : %2s : %s', [BaseInfo[2*idx], BaseInfo[2*idx+1], 'NA']));
	datafile.SaveToFile(CharaDir + 'Skills.txt');

	datafile.Free;
	Baseinfo.Free;

end;

procedure REEDCharacterSaveFriends(CharaDir, CharaIDStr : String);
var
	datafile : TStringList;
	BaseFile : Textfile;
	Information : TStringList;
	NumberofF,idx : byte;
	Line : String;
begin
	datafile := TStringList.Create;
	if FileExists(vDataDir + 'vFriend\Friend.txt') then begin
		Information := TStringList.Create;
		AssignFile(BaseFile, vDataDir + 'vFriend\Friend.txt');
		Reset(BaseFile);
		while not EOF(BaseFile) do begin
			Readln(BaseFile, Line);
			Information.Clear;
			Information.CommaText := Line;
			if Information[0] = CharaIDStr then begin
				Information.Delete(0);
				NumberofF := StrToIntDef(Information[0], 0);
				if NumberofF > 0 then begin
					Information.Delete(0);
					if Information.Count = NumberofF then begin
						for idx := 0 to Information.Count - 1 do
							datafile.Add(Information[idx]);
					end;
				end;
			end;
		end;
		Close(BaseFile);
	end;
	datafile.SaveToFile(CharaDir + 'Friends.txt');
	datafile.Free;
end;

procedure REEDCharacterSaveItemAndCart(CharaDir, ItemLine, CartLine : String);
begin
	MakeInventories(CharaDir + 'Inventory.txt',ItemLine);
	MakeInventories(CharaDir + 'Cart.txt',ItemLine);
end;

procedure REEDCharacterSaveFlags(CharaDir, FlagLine : String);
var
	datafile : TStringList;
begin
	datafile := TStringList.Create;
	datafile.CommaText := FlagLine;
	datafile.Delete(0);
	datafile.SaveToFile(CharaDir + 'Variables.txt');
	datafile.Free;
end;

procedure REEDCharacterSaveRoot(CharaDir, CharaIDStr : String; var ActiveList : TActive; CharaFile : TStringList);
begin
	if CharaFile.Count = 5 then begin
		REEDCharacterSaveBase(CharaDir, ActiveList, CharaFile.Strings[0]); //Line1
		REEDCharacterSaveMemo(CharaDir, CharaFile.Strings[0]); //Line1
		REEDCharacterSaveSkill(CharaDir, CharaFile.Strings[1]); //Line2
		REEDCharacterSaveItemAndCart(CharaDir, CharaFile.Strings[2], CharaFile.Strings[3]); //lines 3 & 4
		REEDCharacterSaveFlags(CharaDir, CharaFile.Strings[4]); //Line 5
		REEDCharacterSaveFriends(CharaDir, CharaIDStr);
	end;
end;

end.
