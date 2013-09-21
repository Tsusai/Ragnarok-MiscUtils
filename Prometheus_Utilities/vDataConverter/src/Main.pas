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
	{Library}
	Classes,
	Forms,
	StdCtrls,
	Controls,
	ExtCtrls;

type
	TForm1 = class(TForm)
		Button1: TButton;
		Label1: TLabel;
		Memo1: TMemo;
		Label2: TLabel;
		GroupBox1: TGroupBox;
		vData2REED: TRadioButton;
		REED2vData: TRadioButton;
		GuildCheck: TCheckBox;
		PartyCheck: TCheckBox;
		CastleCheck: TCheckBox;
		GroupBox2: TGroupBox;
		AccOnlyCheck: TRadioButton;
		AccCharaCheck: TRadioButton;
    Label11: TLabel;
		procedure FormCreate(Sender: TObject);
		procedure Button1Click(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

type
	TActive = record
		Name : array [0..8] of string;
	end;

var
	Form1: TForm1;
	AppPath : String;
	vDatadir : string;
	CIDandGID : TStringList;
	CIDandPID : TStringList;

implementation
uses
	{Library}
	SysUtils,
	{$WARNINGS OFF}
	FileCtrl,
	{$WARNINGS ON}
	{Project}
	VidarSearch;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
	AppPath := ExtractFilePath(ParamStr(0));
end;

procedure TForm1.Button1Click(Sender: TObject);

	procedure LockGUI;
		begin
			Button1.Enabled := false;
			GuildCheck.Enabled := false;
			CastleCheck.Enabled := false;
			PartyCheck.Enabled := false;
			REED2vData.Enabled := False;
			vData2REED.Enabled := false;
			AccCharaCheck.Enabled := False;
			AccOnlyCheck.Enabled := false;
	end;

	begin
	if vData2Reed.Checked then begin
		if not SelectDirectory('Select your vData Folder', '', vDataDir) then
			Memo1.Lines.Add('Aborted')
		else begin
			if NOT (Copy(vDataDir, Length(vDataDir) - 4, 6) = 'vData') then
				Memo1.Lines.Add('Invalid directory')
			else begin
				{$IOChecks off}
				MkDir(AppPath + 'gamedata\');
				if IOResult <> 0 then
					Memo1.Lines.Add('Please delete the gamedata folder in this programs directory.')
				else begin
					{$IOChecks on}
					LockGUI;
					CIDandGID := TStringList.Create;
					CIDandPID := TStringList.Create;
					Memo1.Lines.Add('Starting');
					vDataDir := vDataDir + '\'; //add the trailing \

					if GuildCheck.Checked then begin
						Memo1.Lines.Add('Converting Guilds');
						VidarGuildSearch;
						Memo1.Lines.Add('-Done Converting Guilds');
					end;

					if CastleCheck.Checked then begin
						Memo1.Lines.Add('Converting Castles');
						VidarCastleSearch;
						Memo1.Lines.Add('-Done Converting Castles');
					end;

					if PartyCheck.Checked then begin
						Memo1.Lines.Add('Converting Parties');
						VidarPartySearch;
						Memo1.Lines.Add('-Done Converting Parties');
					end;

					if AccCharaCheck.Checked or AccOnlyCheck.Checked then begin
						if AccCharaCheck.Checked then
							Form1.Memo1.Lines.Add('Converting Accounts and Characters')
						else Form1.Memo1.Lines.Add('Converting Accounts');

						VidarAccountSearch;

						if AccCharaCheck.Checked then
							Form1.Memo1.Lines.Add('-Done Converting Accounts and Characters')
						else Form1.Memo1.Lines.Add('-Done Converting Accounts');

					end;

					Form1.Memo1.Lines.Add('****FINISHED****');
					CIDandGID.Free;
					CIDandPID.Free;
				end;
			end;
		end;
	end else if REED2vData.Checked then begin

	end else Memo1.Lines.Add('Please Select A Conversion Method');
end;

end.
