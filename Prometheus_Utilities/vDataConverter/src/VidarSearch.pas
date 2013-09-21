unit VidarSearch;
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

	procedure VidarAccountSearch;
	procedure VidarCharacterSearch(ID : String; var ActiveChars : TActive);
	procedure VidarGuildSearch;
	procedure VidarPartySearch;
	procedure VidarCastleSearch;

implementation
uses
	{Delphi}
	SysUtils,
	{Converter}
	VidarLoad,
	REEDAccSave;

procedure VidarAccountSearch;
var
	AccountDir : string;
	searchResult : TSearchRec;
begin
	MkDir(AppPath + 'gamedata\Accounts');
	AccountDir := vDataDir + 'vPlayer\vAccount';
	SetCurrentDir(AccountDir);
	if FindFirst('*.vdf', faAnyFile, searchResult) = 0 then begin
		Repeat
			//if (searchResult.attr and faDirectory) = faDirectory
			//then Form1.ListBox1.Items.Add(searchResult.Name);
			//Form1.ListBox1.Items.Add(searchResult.Name);
			SetCurrentDir(AccountDir);//Set back to work with this shiznit.
			VidarAccountLoad(AccountDir + '\' + searchResult.Name);
		until FindNext(searchResult) <> 0;
	end;
	// Must free up resources used by these successful finds
	FindClose(searchResult);

end;

procedure VidarCharacterSearch(ID : String; var ActiveChars : TActive);
var
	CharacterDir : string;
	searchResult : TSearchRec;
begin
	CharacterDir := vDataDir + 'vCharacter\'+ID+'\';
	if not DirectoryExists(CharacterDir) then begin
		exit;
	end else begin
		MkDir(AppPath + 'gamedata\Accounts\' + ID + '\Characters\');
		SetCurrentDir(CharacterDir);
		if FindFirst('*.txt', faAnyFile, searchResult) = 0 then begin
			Repeat
				VidarCharacterLoad(ID,searchResult.Name,ActiveChars);
			until FindNext(searchResult) <> 0;
		end;
		REEDActiveCharSave(ID,ActiveChars);
		// Must free up resources used by these successful finds
		FindClose(searchResult);
	end;
end;

procedure VidarGuildSearch;
begin
	MkDir(AppPath + 'gamedata\Guilds\');
	if FileExists(vDataDir + 'vGuild\guild.txt') then begin
		VidarGuildLoad(vDataDir + 'vGuild\guild.txt');
	end;
end;

procedure VidarPartySearch;
begin
	MkDir(AppPath + 'gamedata\Parties\');
	if FileExists(vDataDir + 'vParty\party.txt') then begin
		VidarPartyLoad(vDataDir + 'vParty\party.txt');
	end;
end;

procedure VidarCastleSearch;
begin
	MkDir(AppPath + 'gamedata\Castles\');
	if FileExists(vDataDir + 'vCastle\gcastle.txt') then begin
		VidarCastleLoad(vDataDir + 'vCastle\gcastle.txt');
	end;
end;


end.
