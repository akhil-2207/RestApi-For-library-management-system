{********************************************************************************
Copyright Technosolutions Corporation. 2002-2003. All Rights Reserved.
TITLE -
DESCRIPTION -
CREATED BY -
CREATED DT -
MODIFIED By -
*******************************************************************************}
unit uclInnerTechDataSet;
{.$DEFINE DELPHI5}

interface

uses{$IFNDEF DELPHI5}Variants, {$ENDIF}
  SysUtils, Windows, Messages, Classes, Db, uclBaseDataset,
  MSAccess, MemData;

type
  TnsInternalTechDataSet = class (TMSQuery, InsInternalTechDataset)
  private
    FLoadAllRecords: Boolean;
    function GetConnection: TComponent;
    procedure SetConnection(const Value: TComponent);
    function GetLoadAllRecords: Boolean;
    procedure SetLoadAllRecords(const Value: Boolean);
    function GetReadBuffer: Integer;
    procedure SetReadBuffer(const Value: Integer);
    function GetSQL: String;
    procedure SetSQL(const Value: String);
    function GetInnerDataset: TDataset;
    {funtion to return the sql after removing unwanted text such as CRLF and comments}
    function GetSQLAfterRemovingUnwantedText(p_SQL: String): String;
  protected
    function GetFieldClass(FieldType: TFieldType): TFieldClass; override;
    procedure InternalInitFieldDefs; override;
    procedure SetActive(Value: Boolean); override;
    procedure CreateFields; override;
  public
    constructor Create(AOwner: TComponent); override;
    {this method check whether client socket is active before
     allowing any dataset methods...
     it also takes into consideration stateless connection}
    procedure CheckConnection;
    {method to load parameters from internal tech dataset}
    procedure GetParameters(p_Params: TParams);
    {method to set parameters to internal tech dataset}
    procedure SetParameters(p_Params: TParams);
    {method to be used when fetching data in batches I.e. when LoadAllRecords is false
     Returns True if more records need to be fetched}
    function LoadNextBatch: Boolean;
    {returns True if batch fetching is support}
    function CanFetchInBatches: Boolean;
    {method to stop the execution on server/db}
    procedure BreakExecution;
    {method to load data in the internal dataset}
    procedure ExecuteSQL;

    {Connection property of this internal check dataset}
    property Connection: TComponent read GetConnection write SetConnection;
    {property to specify whether to load all records at once or load records in batch}
    property LoadAllRecords: Boolean read GetLoadAllRecords write SetLoadAllRecords;
    {property to specify the number of records to load in a single trip to server}
    property ReadBuffer: Integer read GetReadBuffer write SetReadBuffer;
  end;

  TnsInternalTechQuery = class (TnsInternalTechDataSet, InsInternalTechQuery)
  private
    {returns rows affected due to execution of DML statement}
    function GetRowsAffected: Integer;
    function GetInnerQuery: TComponent;
  protected
    {method to start transaction}
    procedure StartTransaction; virtual;
    {method to end transaction with commit or rollback}
    procedure EndTransaction(p_Commit: Boolean); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    {}
    procedure ExecuteDML;
    {execute all DML statements in batch}
    function ExecuteDMLsInBatch(p_List: TList; p_InTransaction: Boolean): Boolean;
  end;

implementation

//******************************************************************************
procedure TnsInternalTechDataSet.SetActive(Value: Boolean);
begin
  if Value and (Active <> Value) then
  begin
    CheckConnection;

    //replacing the CRLF as well as starting comment from the sql as they
    //are creating problem in parsing logic of IBO
    SQL.Text := GetSQLAfterRemovingUnwantedText(SQL.Text);
  end;//if...

  inherited;
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechDataSet.CheckConnection;
begin
  if Connection = nil then
    raise EnsConnection.Create('Connection not Assigned');

  if not TMSQuery(Self).Connection.Connected then
    raise EnsConnection.Create('Connection not Active or Disconnected from server');
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechDataSet.GetParameters(p_Params: TParams);
begin
  p_Params.Assign(Self.Params);
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechDataSet.SetParameters(p_Params: TParams);
var
  LIndex: Integer;
  LParam1: TMSParam;
  LParam2: TParam;
begin
  //ShowMessage('SetParameters start');
  if Self.GetSQL = '' then
    Exit;

  Self.Params.Clear;
  //create params
  Self.ParamCheck := True;
  Self.ParamCheck := False;

  for LIndex := 0 to Self.Params.Count-1 do
  begin
    LParam1 := Self.Params[Lindex];
    LParam2 := p_params.FindParam(LParam1.Name);
    if LParam2 <> nil then
      LParam1.Assign(LParam2);
  end;//for...
 // ShowMessage('SetParameters end');
end;
{------------------------------------------------------------------------------}

function TnsInternalTechDataSet.GetConnection: TComponent;
begin
  Result := inherited Connection;
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechDataSet.SetConnection(const Value: TComponent);
begin
  inherited Connection := Value as TCustomMSConnection;
end;
{------------------------------------------------------------------------------}

function TnsInternalTechDataSet.GetLoadAllRecords: Boolean;
begin
  Result := FetchAll;
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechDataSet.SetLoadAllRecords(const Value: Boolean);
begin
  FetchAll := Value;
end;
{------------------------------------------------------------------------------}

function TnsInternalTechDataSet.GetReadBuffer: Integer;
begin
  Result := FetchRows;
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechDataSet.SetReadBuffer(const Value: Integer);
begin
  if Value > 0 then
    FetchRows := Value;
end;
{------------------------------------------------------------------------------}

{ TnsInternalTechQuery }

constructor TnsInternalTechQuery.Create(AOwner: TComponent);
begin
  inherited;
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechQuery.EndTransaction(p_Commit: Boolean);
begin
  { TODO : to use the correct method to end the server transaction }
  if p_Commit then
    TMSQuery(Self).Connection.Commit
  else
    TMSQuery(Self).Connection.Rollback;
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechQuery.ExecuteDML;
begin
  ExecSQL;
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechDataSet.BreakExecution;
begin
  BreakExec;
  CloseCursor;
  Close;
end;
{------------------------------------------------------------------------------}

function TnsInternalTechDataSet.LoadNextBatch: Boolean;
begin
  Result := False;
end;
{------------------------------------------------------------------------------}

function TnsInternalTechDataSet.CanFetchInBatches: Boolean;
begin
  Result := False;
end;
{------------------------------------------------------------------------------}

constructor TnsInternalTechDataSet.Create(AOwner: TComponent);
begin
  inherited;

  FetchAll := False;
  FetchRows := 25;
  //create all strings with size > 255 as Memo
  //Options.LongStrings := False;
  Options.DefaultValues := False;//True;
  Options.QueryIdentity := False;
  Options.QueryRecCount := False;
  Options.QuoteNames := False;
  Options.RemoveOnRefresh := False;
  Options.StrictUpdate := False;
  Options.TrimFixedChar := False;
  //QueryRecCount - pending
  ReadOnly := True;
  UniDirectional := True;
  ParamCheck := False;
end;
{------------------------------------------------------------------------------}

function TnsInternalTechQuery.ExecuteDMLsInBatch(p_List: TList;
  p_InTransaction: Boolean): Boolean;
var
  LIndex: Integer;
  LDMLObj: TnsDMLObject;
  LAnyError: Boolean;
begin
  { TODO : need to work on better implementation }

  Result := False;
  LAnyError := False;

  if p_InTransaction then StartTransaction;
  try
    for LIndex := 0 to p_List.Count-1 do
    begin
      LDMLObj := TObject(p_List[LIndex]) as TnsDMLObject;

      LDMLObj.Error := '';
      Self.SQL.Text := LDMLObj.DMLStatement;
      Self.SetParameters(LDMLObj.Params);

      try
        ExecuteDML;
      except
        on E: Exception do
        begin
          LAnyError := True;

          //when in transaction...rollback all the records that were committed
          //however when not in transaction, all records will be processed
          if (p_List.Count > 1) and (not p_InTransaction) then
            LDMLObj.Error := E.Message
          else
            raise;
        end;//on...
      end;//try...except
    end;//for...

    if p_InTransaction then EndTransaction(True);
  except
    if p_InTransaction then EndTransaction(False);
    raise;
  end;//try...except

  //return True if not error any occurred
  Result := not LAnyError;
end;
{------------------------------------------------------------------------------}

function TnsInternalTechQuery.GetInnerQuery: TComponent;
begin
  Result := Self;
end;
{------------------------------------------------------------------------------}

function TnsInternalTechQuery.GetRowsAffected: Integer;
begin
  Result := inherited RowsAffected;
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechDataSet.ExecuteSQL;
begin
  Active := True;
end;
{------------------------------------------------------------------------------}

function TnsInternalTechDataSet.GetSQL: String;
begin
  Result := Self.SQL.Text;
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechDataSet.SetSQL(const Value: String);
begin
  Self.SQL.Text := Value;
end;
{------------------------------------------------------------------------------}

function TnsInternalTechDataSet.GetInnerDataset: TDataset;
begin
  Result := Self;
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechQuery.StartTransaction;
begin
  TMSQuery(Self).Connection.StartTransaction;
end;
{------------------------------------------------------------------------------}

function TnsInternalTechDataSet.GetFieldClass(
  FieldType: TFieldType): TFieldClass;
begin
  Result := inherited GetFieldClass(FieldType);
//  if FieldType = ftSmallint then
//    FieldType := ftInteger;
//
//  Result := DB.DefaultFieldClasses[FieldType];
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechDataSet.InternalInitFieldDefs;
begin
//  if not Prepared then
//  begin
//    Prepare;
//    if not Prepared then
//      DatabaseError( 'Unable to prepare statement' );
//  end;//if...
//
//  try
//    for I := 0 to SqlCmd.FieldDescs.Count-1 do
//    begin
//      if (SqlCmd.FieldDescs[I].FieldType = ftString) and (SqlCmd.FieldDescs[I].DataSize > 240) then
//      begin
//        SqlCmd.FieldDescs[I].FieldType := ftMemo;
//        SqlCmd.FieldDescs[I].DataSize := 0;
//        SqlCmd.FieldDescs[I].DataType := SQLTEXT;
//      end;//if...
//    end;//for...
//  except
//  end;//try...except}

  inherited;
end;
{------------------------------------------------------------------------------}

procedure TnsInternalTechDataSet.CreateFields;
begin
  inherited;

  //do nothing...

end;
{------------------------------------------------------------------------------}

function TnsInternalTechDataSet.GetSQLAfterRemovingUnwantedText(
  p_SQL: String): String;
var
  LSQLStr: String;
  LPosStart, LPosEnd: Integer;
begin
  //replacing the CRLF as well as starting comment from the sql as they
  //are creating problem in parsing logic of IBO

  //first removing CRLF
  Result := StringReplace(p_SQL, #13, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, ',', ' , ', [rfReplaceAll]);

  //checking for comment in first 50 characters of the sql
  LSQLStr := Copy(Result, 1, 50);

  //get the start position of the comment
  LPosStart := Pos('/*', LSQLStr);
  if LPosStart <= 0 then
    Exit;

  //get the end position of the comment
  LPosEnd := Pos('*/', LSQLStr);
  if LPosEnd <= LPosStart then
    Exit;

  //get the starting comment of the sql
  LSqlStr := Trim(Copy(LSQLStr, LPosStart, (LPosEnd + 2) - LPosStart));
  //removing the starting comment from the actual sql
  if LSqlStr <> '' then
    Result := StringReplace(Result, LSqlStr, '', []);
end;
{------------------------------------------------------------------------------}

initialization
  CONNECTION_COMPONENT_CLASS := 'TMSConnection';

  GInternalTechDataset := TnsInternalTechDataSet;
  GInternalTechQuery := TnsInternalTechQuery;

end.
