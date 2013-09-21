unit REEDCastleSave;
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

procedure REEDSaveCastlesRoot(CastleLine : String);

implementation
uses
	{Delphi}
	Classes,
	SysUtils,
	{Converter}
	Main;

procedure REEDSaveCastlesRoot(CastleLine : String);
var
	GIdx : byte;
	CastleInfo,
	DataFile : TStringList;
begin

	CastleInfo := TStringList.Create;
	DataFile := TStringList.Create;
	CastleInfo.CommaText := CastleLine;

	DataFile.Add(Format('MAP : %s', [CastleInfo.Strings[1]]));
	DataFile.Add(Format('GID : %s', [CastleInfo.Strings[2]]));
	DataFile.Add(Format('GNM : %s', [CastleInfo.Strings[3]]));
	DataFile.Add(Format('GMA : %s', [CastleInfo.Strings[4]]));
	DataFile.Add(Format('GKA : %s', [CastleInfo.Strings[5]]));
	DataFile.Add(Format('EDE : %s', [CastleInfo.Strings[6]]));
	DataFile.Add(Format('ETR : %s', [CastleInfo.Strings[7]]));
	DataFile.Add(Format('DDE : %s', [CastleInfo.Strings[8]]));
	DataFile.Add(Format('DTR : %s', [CastleInfo.Strings[9]]));
	for GIdx := 0 to 7 do
	begin
		DataFile.Add(Format('GS%d : %s', [(GIdx +1), CastleInfo.Strings[ 10+GIdx ] ]));
	end;

	MkDir(AppPath + 'gamedata\Castles\' + CastleInfo.Strings[1] +'\');
	DataFile.SaveToFile(AppPath + 'gamedata\Castles\' + CastleInfo.Strings[1] +'\Castle.txt');
	DataFile.Free;
	CastleInfo.Free;
end;

end.
