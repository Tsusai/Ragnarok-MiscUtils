program My2JanDump;

{$APPTYPE CONSOLE}

uses
	{$IFDEF MSWINDOWS}
	uMysqlVio in 'MySQL\uMysqlVio.pas',
	uMysqlCT in 'MySQL\uMysqlCT.pas',
	uMysqlErrors in 'MySQL\uMysqlErrors.pas',
	uMysqlNet in 'MySQL\uMysqlNet.pas',
	uMysqlNewPassword in 'MySQL\uMysqlNewPassword.pas',
	umysqlsha1 in 'MySQL\umysqlsha1.pas',
	uMysqlClient in 'MySQL\uMysqlClient.pas',
	{$ELSE}
	uMysqlVio in 'MySQL/uMysqlVio.pas',
	uMysqlCT in 'MySQL/uMysqlCT.pas',
	uMysqlErrors in 'MySQL/uMysqlErrors.pas',
	uMysqlNet in 'MySQL/uMysqlNet.pas',
	uMysqlNewPassword in 'MySQL/uMysqlNewPassword.pas',
	umysqlsha1 in 'MySQL/umysqlsha1.pas',
	uMysqlClient in 'MySQL/uMysqlClient.pas',
	{$ENDIF}
	SysUtils,
	Classes;

var
	AppPath : string;

procedure DumpTableData(var MySQLClient : TMySQLClient; TableList : TStringList);
var
	TableIdx : integer;
	DataIdx : integer;
	DataIdx2 : integer;
	Outfile : TStringList;
	QueryResult : TMySQLResult;
	Success : boolean;
	FieldLine : string;
	Outfilename : string;
	DataLine : string;

const FieldQuery = 'Show columns in %s;';

begin
	Outfile := TStringList.Create;
	try
		for TableIdx := 0 to TableList.Count - 1 do
		begin
			Outfilename := AppPath + '/Output/'+TableList.Strings[TableIdx]+'.txt';
			Writeln('Dumping all information from table ' + TableList.Strings[TableIdx]);
			OutFile.Clear;
			FieldLine := '';
			QueryResult :=
				MySQLClient.query(Format(FieldQuery, [TableList.Strings[TableIdx]]),
				true,Success);
			if not Success then Continue;
			if QueryResult.RowsCount > 0 then
			begin
				for DataIdx := 1 to QueryResult.RowsCount do
				begin
					FieldLine := FieldLine + QueryResult.FieldValue(0);
					if not (DataIdx = QueryResult.Rowscount) then
					begin
						FieldLine := FieldLine + ';';
						QueryResult.Next;
					end;
				end;
			end;

			Outfile.Add(FieldLine);

			QueryResult :=
				MySQLClient.Query('Select * from ' + TableList.Strings[TableIdx] + ';',true,success);
			for DataIdx := 1 to QueryResult.RowsCount do
			begin
				DataLine := '';

				//Read all fields
				for DataIdx2 := 0 to QueryResult.FieldsCount - 1 do
				begin
					DataLine := DataLine + QueryResult.FieldValue(DataIdx2);
					if not (DataIdx2 = QueryResult.FieldsCount - 1) then
					begin
						DataLine := DataLine + ';';
					end;
				end;
				Outfile.Add(DataLine);

				if not (DataIdx = QueryResult.RowsCount) then
				begin
					QueryResult.Next;
				end;
			end;
			OutFile.SaveToFile(Outfilename);
		end;
	finally
		Outfile.Free;
	end;
end;

procedure GetTablesAndCallDump(var MySQLClient : TMySQLClient);
var
	idx : integer;
	QueryResult : TMySQLResult;
	SuccessBool : boolean;
	TableList  : TStringList;
begin
	QueryResult := MySQLClient.query('Show tables;',true,SuccessBool);
	TableList := TStringList.Create;
	try
		for idx := 1 to QueryResult.RowsCount do
		begin
			TableList.Add(QueryResult.FieldValue(0));
			if (idx < QueryResult.Rowscount) then
			begin
				QueryResult.Next;
			end;
		end;
		DumpTableData(MySQLClient,TableList);
	finally
		TableList.Free;
	end;
	Writeln('Dump complete, press any key to exit');
	readln;
end;

procedure ConnectToMySQL;
var
	MySQLClient : TMySQLClient;
	User,Pass,Host,Port,Db : string;
begin
	MySQLClient := TMySQLClient.create;
	try
		Writeln('Enter the following, no default values are assumed!');
		Write('MySQL Host Location: ');
		Readln(Host);
		Write('MySQL Port (usually 3306): ');
		Readln(Port);
		Write('MySQL Username: ');
		Readln(User);
		Write('MySQL Password: ');
		Readln(Pass);
		Write('MySQL Database: ');
		Readln(Db);
		Writeln;
		Writeln('Connecting to MySQL...');
		if MySQLClient.connect(
			Host,User,Pass,Db,StrToIntDef(Port,3306)) then
		begin
			WriteLn('MySQL Connected Successfully.');
			Writeln('Beginning dump...this could take some time.');
			GetTablesAndCallDump(MySQLClient);
		end else
		begin
			Writeln('MySQL Failed to connect. Please try again');
			ReadLn;
		end;
	finally
		MySQLClient.close;
		MySQLClient.Free;
	end;
end;

begin
	AppPath := ExtractFilePath(ParamStr(0));
	If not DirectoryExists(AppPath + 'Output/') then
	begin
		CreateDir(AppPath + 'Output/');
	end;
	ConnectToMySQL;
end.
