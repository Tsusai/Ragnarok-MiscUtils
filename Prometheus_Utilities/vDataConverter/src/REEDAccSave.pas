unit REEDAccSave;
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
	{Converter}
	Main;

	procedure REEDAccountSaveBasic(AccInfo : String);
	procedure REEDActiveCharSave(ID : String; ActiveList : TActive);


implementation
uses
	{Delphi}
	SysUtils,
	Classes,
	{Converter}
	Misc,
	VidarSearch;

procedure REEDAccountStorage(AccID : String);
var
	StorageFile : TStringList;
	ItemLine : String;
begin
	if FileExists(vDataDir + 'vPlayer\vStorage\' + AccID + '.txt') then begin
		StorageFile := TStringList.Create;
		StorageFile.LoadFromFile(vDataDir + 'vPlayer\vStorage\' + AccID + '.txt');
		if StorageFile.Count = 2 then
			ItemLine := StorageFile.Strings[1]
		else ItemLine := '';
		StorageFile.Free;
	end else ItemLine := '';

	MakeInventories(AppPath + 'gamedata\Accounts\' + AccID + '\Storage.txt',ItemLine,True);
end;

procedure REEDActiveCharSave(ID : string; ActiveList : TActive);
var
	ActiveOut : TStringList;
	i : integer;
begin
	ActiveOut := TStringList.Create;
	for i := 0 to 8 do
		ActiveOut.Add(
			Format('SLOT%d : %s', [i+1, ActiveList.Name[i]])
		);

	ActiveOut.SaveToFile(AppPath + 'gamedata\Accounts\' + ID + '\ActiveChars.txt');
	ActiveOut.Free;
end;

procedure REEDAccountSaveBasic(AccInfo : String);
var
	Outfile : TStringList;
	CommaTxt : TStringList;
	FolderID : String;
	ActiveChars : TActive;
	idx : byte;
begin
	CommaTxt := TStringList.Create;
	CommaTxt.CommaText := AccInfo;
	FolderID := CommaTxt[0];
	Outfile := TStringList.Create;
	Outfile.Add('USERID : ' + CommaTxt[0]);
	Outfile.Add('USERNAME : ' + CommaTxt[1]);
	Outfile.Add('PASSWORD : ' + CommaTxt[2]);

	if (CommaTxt[3] = '0') then Outfile.Add('SEX : FEMALE')
	else if (CommaTxt[3] = '1') then Outfile.Add('SEX : MALE');

	Outfile.Add('EMAIL : ' + CommaTxt[4]);

	if (CommaTxt[5] = '1') then Outfile.Add('BANNED : YES')
	else Outfile.Add('BANNED : NO');

	Outfile.Add('ACCESSLEVEL : 0');
	Outfile.Add('LAST IP : ' + CommaTxt[6]);

	Outfile.SaveToFile(AppPath + 'gamedata\Accounts\' + FolderID + '\Account.txt');
	CommaTxt.Free;
	Outfile.Free;

	for idx := 0 to 8 do
		ActiveChars.Name[idx] := '';

	if Form1.AccCharaCheck.Checked then
		VidarCharacterSearch(FolderID,ActiveChars);

	REEDAccountStorage(FolderID);
	REEDActiveCharSave(FolderID, ActiveChars);
end;

end.
