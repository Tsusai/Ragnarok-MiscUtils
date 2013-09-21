unit Main;
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
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, FileCtrl, ComCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    ProgressBar1: TProgressBar;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

	procedure TForm1.Button1Click(Sender: TObject);
	var
		ResTableFile,
		CopyTable : TStringList;
		idx : integer;
		ReadDir : string;
	Begin
		if SelectDirectory('Select your map folder (gats and rsws)', '', ReadDir) then begin
			ReadDir := ReadDir + '\';
			if FileExists(ReadDir + 'resnametable.txt') then begin
				ResTableFile := TStringList.Create;
				ResTableFile.Clear;
				CopyTable := TStringList.Create;
				CopyTable.Clear;
				CopyTable.Delimiter := '#';
				//Load the file
				ResTableFile.LoadFromFile(ReadDir + 'resnametable.txt');
				Form1.ProgressBar1.Max := ResTableFile.Count;
				//Start reading
				for idx := 0 to ResTableFile.Count - 1 do begin
					Application.ProcessMessages;
					Form1.ProgressBar1.Position := idx + 1;
					//delimit the line by # symbols.
					CopyTable.DelimitedText := ResTablefile[idx];
					//At least 2 strings, and with a .gnd extension
					if (CopyTable.Count < 2) or
						(ExtractFileExt(CopyTable[0]) <> '.gnd') then begin
						Continue;
					end;
					//Update the extensions
					CopyTable[0] := ChangeFileExt(CopyTable[0],'');
					CopyTable[1] := ChangeFileExt(CopyTable[1],'');
					//If the original file exists
					if FileExists(ReadDir + CopyTable[1] + '.gat') and
					FileExists(ReadDir + CopyTable[1] + '.rsw')then begin
						CopyFile(
							PChar(ReadDir + CopyTable[1] + '.gat'),
							PChar(ReadDir + CopyTable[0] + '.gat'),false);
						CopyFile(
							PChar(ReadDir + CopyTable[1] + '.rsw'),
							PChar(ReadDir + CopyTable[0] + '.rsw'),false);
					end;
				end;
				CopyTable.Free;
				ResTableFile.Free;
				ShowMessage('Copying complete');
			end else
			ShowMessage('Resnametable.txt not found in map folder, please extract from your client');
		end;
	end;

end.
