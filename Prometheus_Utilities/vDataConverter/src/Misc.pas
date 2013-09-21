unit Misc;
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
	{Library}
	//none
	{Project}
	Main;

procedure MakeInventories(Path, ItemLine : string; Storage : boolean = false);

implementation
uses
	{Project}
	Classes,
	SysUtils;

procedure MakeInventories(Path, ItemLine : string; Storage : boolean = false);
var
	datafile,
	ItemList : TStringList;
	Total : byte;
	idx : byte;
begin
	datafile := TStringList.Create;
	datafile.Clear;
	datafile.Add('    ID :   AMT : EQP : I :  R : A : CARD1 : CARD2 : CARD3 : CARD4 : NAME');
	datafile.Add('---------------------------------------------------------------------------------------------------------');
	if ItemLine <> '' then begin;
		ItemList := TStringList.Create;
		ItemList.CommaText := ItemLine;
		if StrToIntDef(ItemList[0],0) > 0 then begin
			Total := StrToInt(ItemList[0]);
			ItemList.Delete(0);
			//UPDATE WHEN PROMETHEUS IS DONE
			if (Not Storage and (Total > 100)) then Total := 100
			else if (Storage and (Total > 100)) then Total := 100;
			//END UPDATE AREA
			for idx := 0 to Total - 1 do begin
				datafile.Add(
					Format('%6s : %5s : %3s : %1s : %2s : %1s : %5s : %5s : %5s : %5s : NA',
					[	ItemList[ 0+idx*10],
						ItemList[ 1+idx*10],
						ItemList[ 2+idx*10],
						ItemList[ 3+idx*10],
						ItemList[ 4+idx*10],
						ItemList[ 5+idx*10],
						ItemList[ 6+idx*10],
						ItemList[ 7+idx*10],
						ItemList[ 8+idx*10],
						ItemList[ 9+idx*10]
					])
				);
			end;
		end;
		ItemList.Free;
	end;
	datafile.SaveToFile(Path);
	datafile.Free;
end;

end.


