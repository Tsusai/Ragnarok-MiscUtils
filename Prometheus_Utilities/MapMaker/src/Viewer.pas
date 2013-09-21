unit Viewer;
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
  Windows,
  Controls,
  Forms,
  ExtCtrls,
  StdCtrls,
  Classes;

type
  TForm2 = class(TForm)
    Image1: TImage;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
	Form2: TForm2;

implementation
uses
  Graphics,
  Dialogs,
  SysUtils;

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
var
	x : integer;
	y : integer;
	Size : TPoint;
	FileName : string;
	Data : TMemoryStream;
	Flag : Byte;
	TempStr : String;
begin
	if PromptForFileName(
		FileName,
		'Prometheus Map Files (*.pms)|*.pms',
		'',
		'Select a map file',
		'',
		false
		) then begin

		if FileExists(FileName) then begin
			Data := TMemoryStream.Create;
			Data.LoadFromFile(FileName);

			SetLength(TempStr,13);
			Data.Read(TempStr[1],13);
			if TempStr <> 'PrometheusMap' then Exit;

			Data.Read(Flag,1);
			if Flag <> 1 then exit;

			Data.Read(Size.X,4);
			Data.Read(Size.Y,4);

			Canvas.Refresh;
			Image1.Canvas.Brush := Brush;             //select brush
			Image1.Canvas.FillRect(Image1.ClientRect); //redraw form

			for y := 0 to Size.Y -1 do begin
				Image1.Canvas.MoveTo(0,Size.Y - y);
				for x := 0 to Size.X - 1 do begin
					Data.Read(Flag,1);
					if (Flag = 1) or (Flag = 5) then
						Image1.Canvas.Pen.Color := clBlack
					else if (Flag = 3) then
						Image1.Canvas.Pen.Color := clBlue
					else Image1.Canvas.Pen.Color := clWhite;
							Image1.Canvas.LineTo(x+1,Size.Y - y);
				end;
			end;
			Data.Free;
		end;
	end;
end;
end.
