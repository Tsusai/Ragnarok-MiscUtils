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
	Windows,
	Forms,
	StdCtrls,
	ComCtrls,
	Classes,
	Controls;

type
	TForm1 = class(TForm)
		Label1: TLabel;
		Button2: TButton;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Label6: TLabel;
		Label7: TLabel;
		Label8: TLabel;
		Label9: TLabel;
		Label10: TLabel;
		ProgressBar1: TProgressBar;
    Button1: TButton;
    Label11: TLabel;
		procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

type
	TMapInfo = class
	protected
	public
		Name : String;
		Size : TPoint;
		RSWWaterHeight : Single;
		CellInfo : array of array of Byte;
	end;

var
	Form1: TForm1;
	MapList : TStringList;
	OutDir : string;
	ReadDir : string;
	Total, Partial, Cloned : Integer;

implementation
uses
	{$WARNINGS OFF}
	FileCtrl, //Specific to Win32...boo hoo
	{$WARNINGS ON}
	SysUtils,
	Viewer;

{$R *.dfm}

(*------------------------------------------------------------------------------
UpdateValues
Updates the counter displays
------------------------------------------------------------------------------*)
	procedure UpdateValues(Val : byte);
	begin
		case Val of
		1:
			begin
				Inc(Total);
			end;
		2:
			begin
				Inc(Partial);
			end;
		3:
			begin
				Inc(Cloned);
			end;
		end;
		Form1.Label10.Caption := IntToStr(Total);
		Form1.Label9.Caption := IntToStr(Partial);
		Form1.Label8.Caption := IntToStr(Cloned);
		Form1.Label7.Caption := IntToStr(Cloned + Total);
		Application.ProcessMessages;
	end;


(*------------------------------------------------------------------------------
Read RSW
Opens the map's RSW for reading.  Reads the offset at 0x00A8, which contains
the water height value.
~ 166  <WaterHeight> (4 bytes, float)
float = Single precision IEEE float (32-bit)
------------------------------------------------------------------------------*)
	procedure ReadRSW(MName : string);
	var
		AMap : TMapInfo;
		Data : TMemoryStream;
		Temp : single;
	begin
		AMap := TMapInfo.Create;
		AMap.Name := MName;
		Data := TMemoryStream.Create;
		Data.LoadFromFile(ReadDir + MName + '.rsw');

		Data.Seek($A6,soFromBeginning); //offset
		Data.Read(Temp,4);
		AMap.RSWWaterHeight := Temp;
		Maplist.AddObject(AMap.Name,AMap);
		Data.Free;
	end;


(*------------------------------------------------------------------------------
Read GAT
Opens the map's GAT for reading.
float = Single precision IEEE float (32-bit)
.gat -- Tiles = Altitude, walkable
~   0  <Header> (4 bytes) |47 52 41 54 {GRAT}|
~   4  <?Version?> (2 bytes, ?16-bit integer?) |01 02|
~   6  <X_size> (4 bytes, unsigned (?) 32-bit integer)
~  10  <Y_size> (4 bytes)
-- Tiles linear
|- Tile offset: (y * X_size + x) * 20 + 14
~  14  <Tile> (20 bytes)
       [  0] <y1> (4 bytes, float)
       [  4] <y2> (4 bytes, float)
       [  8] <y3> (4 bytes, float)
       [ 12] <y4> (4 bytes, float)
         _______
         | 1| 2|
         |--|--|
         | 3| 4|
         -------
			 [ 16] <type> (4 bytes, 32-bit integer) |0=walkable:1:5|
------------------------------------------------------------------------------*)
	procedure ReadGAT(MName : string);
	var
		AMap : TMapInfo;
		Data : TMemoryStream;
		FileTypeStr : String;
		Outer,inner : integer;
		MapBit : integer;
		CellHeight : array [0..3] of single;
	begin
		Data := TMemoryStream.Create;
		Data.LoadFromFile(ReadDir + MName + '.gat');

		//GAT Authenticity
		SetLength(FileTypeStr, 4);
		Data.Read(FileTypeStr[1], 4);

		if (FileTypeStr <> 'GRAT') then begin
			if Assigned(Data) then Data.Free;
			Exit; //CRW - 2004/04/21 - Safe
		end;

		//Check to see if the map object was made by the water reader,
		//If so, use that map, else make a new one.
		if MapList.IndexOf(MName) = -1 then begin
			AMap := TMapInfo.Create;
			AMap.Name := MName;
			Maplist.AddObject(AMap.Name,AMap);
		end else AMap := MapList.Objects[MapList.IndexOf(MName)] as TMapInfo;

		if AMap = nil then AMap := TMapInfo.Create;

		Data.Seek(2,soFromCurrent);
		Data.Read(AMap.Size.X, 4);
		Data.Read(AMap.Size.Y, 4);

		MapBit := 0;
		SetLength(AMap.CellInfo, AMap.Size.X, AMap.Size.Y);
		for Outer := 0 to AMap.Size.Y - 1 do begin
			for Inner := 0 to AMap.Size.X - 1 do begin
				//Read the Cellheight info and tile flag
				Data.Read(CellHeight[0], 4);
				Data.Read(CellHeight[1], 4);
				Data.Read(CellHeight[2], 4);
				Data.Read(CellHeight[3], 4);
				Data.Read(MapBit, 4);

				//Water check.  If we have water info, start the update.
				if (AMap.RSWWaterHeight <> 0) and (MapBit = 0) then begin
					if ((CellHeight[0]) >= AMap.RSWWaterHeight) or
					((CellHeight[1]) >= AMap.RSWWaterHeight) or
					((CellHeight[2]) >= AMap.RSWWaterHeight) or
					((CellHeight[3]) >= AMap.RSWWaterHeight) then begin
						AMap.CellInfo[Inner][Outer] := 3;
					end else begin
						AMap.CellInfo[Inner][Outer] := 0;
					end;
				end else begin
					AMap.CellInfo[Inner][Outer] := MapBit;
				end;

			end;
		end;
		Data.Free; //Free the data
	end;


(*------------------------------------------------------------------------------
Write Map
Writes into the proprietary map format.
<X Size 4b> <Y Size 4b> {<Cell 1b>}*(X Size * Y Size)
------------------------------------------------------------------------------*)
	procedure WriteMap(index : Integer);
	var
		AMap : TMapInfo;
		Data : TMemoryStream;
		XAxis, YAxis : integer;
		Ver : Byte;
	begin
		if MapList.Count = 0 then exit;
		AMap := MapList.Objects[index] as TMapInfo;
		if AMap = nil then exit;

		Data := TMemoryStream.Create;
		Data.Clear;
		Data.Write('PrometheusMap',13);
		Ver := 1;
		Data.Write(Ver,1); //Version
		Data.Write(AMap.Size.X,4); //Write the X Size
		Data.Write(AMap.Size.Y,4); //Write the Y Size
		for YAxis := 0 to AMap.Size.Y - 1 do
			for XAxis := 0 to AMap.Size.X - 1 do
				Data.Write(AMap.CellInfo[XAxis][YAxis],1); //Write the MapBit
		Data.SaveToFile(OutDir + AMap.Name + '.pms');
		Data.Free;

	end;


(*------------------------------------------------------------------------------
CloneMaps
Reads the resnametable.txt then procedes to copy the map that is listed
FakeName.ext#Original.ext#
------------------------------------------------------------------------------*)
	procedure CloneMaps;
	var
		ResTableFile,
		CopyTable : TStringList;
		FromFile,
		ToFile : TFileStream;
		idx : integer;
	Begin
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
			Form1.ProgressBar1.Position := idx + 1;
			//delimit the line by # symbols.
			CopyTable.DelimitedText := ResTablefile[idx];
			//At least 2 strings, and with a .gnd extension
			if (CopyTable.Count < 2) or
				(ExtractFileExt(CopyTable[0]) <> '.gnd') then
				Continue;
				//Update the extensions
				CopyTable[0] := ChangeFileExt(CopyTable[0],'.pms');
				CopyTable[1] := ChangeFileExt(CopyTable[1],'.pms');
				//If the original file exists
				if FileExists(OutDir + CopyTable[1]) then begin
					//Load the original, write the copy
					FromFile := TFileStream.Create(OutDir + CopyTable[1], fmOpenRead);
					ToFile := TFileStream.Create(OutDir + CopyTable[0], fmOpenRead or fmCreate);
					ToFile.CopyFrom(FromFile,FromFile.Size);
					FromFile.Free;
					ToFile.Free;
					UpdateValues(3);  //Display Update
				end;
		end;
		CopyTable.Free;
		ResTableFile.Free;
	end;


	procedure TForm1.Button2Click(Sender: TObject);
	var
		searchResult : TSearchRec;
		MapName : string;
		FileList : TStringList;
		idx : integer;
	begin
		if (SelectDirectory('Select the folder with your GAT, and RSW map files,'+
		 ' and resnametable.txt file', '', ReadDir)) and
		 (SelectDirectory('Output where?','', OutDir)) then begin

			Button2.Enabled := false;

			if Length(ReadDir) > 3 then
				ReadDir := ReadDir + '\';
			if Length(OutDir) > 3 then
				OutDir := OutDir + '\';

			SetCurrentDir(ReadDir);
			MapList := TStringList.Create;
			FileList := TStringList.Create;
			MapList.Clear;
			FileList.Clear;
			Total := 0;
			Partial := 0;
			Cloned := 0;

			Label2.Caption := 'Starting...';
			Application.ProcessMessages;
			if FindFirst('*.gat', faAnyFile, searchResult) = 0 then begin
				Repeat
					MapName := ChangeFileExt(searchResult.Name, '');
					FileList.Add(MapName);
				until FindNext(searchResult) <> 0;
			end;
			// Must free up resources used by these successful finds
			FindClose(searchResult);

			if FileList.Count > 0 then begin
				ProgressBar1.Max := FileList.Count;
				Label2.Caption := 'Reading Map Information';
				for idx := 0 to FileList.Count -1 do begin
					UpdateValues(1); //Display Update
					ProgressBar1.Position := (idx+1);
					if FileExists(ReadDir + FileList.Strings[idx] + '.rsw') then begin
						ReadRSW(FileList.Strings[idx]);
						UpdateValues(2); //Display Update
					end;
					ReadGAT(FileList.Strings[idx]);
				end;

				ProgressBar1.Position := 0;
				ProgressBar1.Max := Maplist.Count;
				Label2.Caption := 'Saving Map Information';
				for idx := 0 to MapList.Count -1 do begin
					Application.ProcessMessages;
					ProgressBar1.Position := (idx+1);
					WriteMap(idx);
				end;

				if FileExists(ReadDir + 'resnametable.txt') then begin
					ProgressBar1.Position := 0;
					Label2.Caption := 'Duplicating Needed Map Information';
					CloneMaps;
				end;

				Label2.Caption := 'Complete';

			end;
			MapList.Free;
			FileList.Free;
		end;
		Button2.Enabled := true;

	end;

procedure TForm1.Button1Click(Sender: TObject);
begin
	Form2.Show;
end;

end.

