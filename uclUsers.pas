unit uclUsers;

{
  Classes in this unit- TnsUserManagement

  Purpose- To encapsulate all the functions related to the user and management of user
}
interface
uses
SysUtils, Classes, HTTPApp , ULKJSON , IBODataset, uclDataSet, uclBaseDataset, uclInnerTechDataSet,
   MSAccess, StdCtrls, DB, SDEngine;

type

  TnsUserManagement = class
  private
    FDataSetForUsers: TnsDataSet;

    procedure LoadDataSet(LUsernameField: String; LPasswordField: String; p_Filter: string = ''; p_ForAddUser: boolean  = false);

  public
    FMSConnection : TMSConnection;

    constructor Create(p_Connection: TMSConnection); reintroduce;

    destructor Destroy; override;

    function CheckIfUserExist(LUsernameField: String; LPasswordField:String; var LToken: Integer):Boolean;

  end;//


implementation

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Constructor TnsUserManagement.Create(p_Connection: TMSConnection);
begin

  FMSConnection:= p_Connection;

  FDataSetForUsers := TnsDataset.create(nil);
  FDataSetForUsers.Connection:= FMSConnection;
  FDataSetForUsers.UpdateTableName:= 'Users';
  FDataSetForUsers.KeyFields:='user_id';

end;

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

destructor TnsUserManagement.Destroy;
begin
  FreeAndNil(FDataSetForUsers);
  
  inherited;
end;

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// Procedure to Load dataset
procedure TnsUserManagement.LoadDataSet(LUsernameField: String; LPasswordField: String; p_Filter: string = ''; p_ForAddUser: boolean  = false);
var
  LSQL: string;
begin
{*
  Intent: This procedure is used to load a dataset with user records based on specified criteria.

  Parameters:
    - LUsernameField: The username field value to filter the dataset.
    - LPasswordField: The password field value to filter the dataset.
    - p_Filter: Optional filter criteria to apply to the dataset containg string to be added after WHERE in SQL statement .
    - p_ForAddUser: Specifies whether the dataset is being loaded for adding a new user or not (BOllean).

  Calling functions:
   -  internally by function CheckIfUserExist

  Result: It loads the dataset with user records based on the provided criteria.
*}

{*
  Logic:
   - Construct the SQL query to select all fields from the Users table.
   - If p_ForAddUser is True, modify the SQL query to select no records.
   - If p_Filter is not empty, append a WHERE clause to the SQL query based on the filter criteria.
   - If p_Filter is provided, set parameter values for the filter criteria.
   - Open the dataset with the constructed SQL query.
*}
  LSQL := 'SELECT * FROM Users';
  FDataSetForUsers.SqlSelect := LSQL;

  if p_ForAddUser then
  begin
    LSQL := LSQL + ' WHERE user_id = -1';
    FDataSetForUsers.SqlSelect := LSQL;
  end

  else if p_Filter <> '' then
  begin
    LSql := LSql + ' WHERE ' + p_Filter;
    FDataSetForUsers.SqlSelect := LSQL;
    FDataSetForUsers.CreateParamVariables;
    FDataSetForUsers.ParamByName('p_val1').AsString :=  LUsernameField ;
    FDataSetForUsers.ParamByName('p_val2').AsString :=  LPasswordField ;
  end;

  FDataSetForUsers.Open;
end;

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//                        function to check the user details in database returns false if not found and set token value = user_id


function TnsUserManagement.CheckIfUserExist(LUsernameField: String; LPasswordField:String; var LToken: Integer):Boolean;
var
LFilterstr: String;
begin
{*
  Intent: This function is used to check if a user exists in the database with the specified username and password.

  Parameters:
    - LUsernameField: The username field value to check.
    - LPasswordField: The password field value to check.
    - LToken: The token value set to the user_id if the user exists.


  Result: It returns True if the user exists in the database, False otherwise.
*}

{*
  Logic:
   - Construct the filter string to match the username and password in the Users table.
   - Close the dataset to prepare for loading a new dataset.
   - Call the LoadDataSet procedure to load the dataset with the filtered user record.
   - Check if the dataset contains any records.
   - If the dataset is empty, return False indicating that the user does not exist.
   - If the dataset contains records, return True indicating that the user exists.
   - Set LToken to the user_id value from the dataset if the user exists.
*}

  LFilterstr:= 'username = (:p_val1)  AND password = (:p_val2)';
  FDataSetForUsers.Close;
  Self.LoadDataSet(LUsernameField,LPasswordField,LFilterstr,false);

  if (FDataSetForUsers.RecordCount = 0) then
    result:= False
  else
    result:= True;
    //setting Ltoken when user exist in Database (token = user_id)
    LToken:= FDataSetForUsers.FieldbyName('user_id').AsInteger;
end;

end.
