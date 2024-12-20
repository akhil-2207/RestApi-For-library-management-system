unit uclUtils;

interface
uses
SysUtils, Classes, HTTPApp , ULKJSON , IBODataset, uclDataSet, uclBaseDataset, uclInnerTechDataSet,
   MSAccess, StdCtrls, DB, SDEngine;

function FieldValueByNameAs(p_JSONObj: TlkJSONObject;
                            p_FieldName: string;
                            p_FieldType: TlkJSONtypes;
                            p_DefaultValue: Variant;
                            var p_IsFieldExists: Boolean;
                            p_RaiseErrorOnFieldNotFound: Boolean = false;
                            p_RaiseErrorOnFieldMisMatch: Boolean = false): Variant;



function CapitalizeFirstLetter(const AStr: string): string;

function ToValidateIfTypeIsUser(var LCookieCheckInt: Integer; LTempCookievalStr: String; Request: TWebRequest; Response: TWebResponse; LResponseobj: tlkJSONObject ):Boolean;

function ToValidateIfTypeIsAdmin(var LCookieCheckInt: Integer; LTempCookievalStr: String; Request: TWebRequest; Response: TWebResponse; LResponseobj: tlkJSONObject ):Boolean;

///-------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------

implementation

function FieldValueByNameAs(p_JSONObj: TlkJSONObject;
                            p_FieldName: string;
                            p_FieldType: TlkJSONtypes;
                            p_DefaultValue: Variant;
                            var p_IsFieldExists: Boolean;
                            p_RaiseErrorOnFieldNotFound: Boolean = false;
                            p_RaiseErrorOnFieldMisMatch: Boolean = false): Variant;
var
  LFld: TlkJsonBase;
begin

  if p_JSONObj = nil then
    Assert(false, 'Mandatory parameter JSON Object is not initialized.');

  p_FieldName:= Trim(p_FieldName);
  if p_FieldName = '' then
    Assert(false, 'Mandatory parameter Field name is blank.');

  p_IsFieldExists:= false;
  Result := p_DefaultValue;


  LFld:= p_JSONObj.Field[p_FieldName];
  if LFld = nil then
  begin
    if p_RaiseErrorOnFieldNotFound then
      raise Exception.Create('Field ' + p_FieldName + ' does not exist in JSON parameters.');

    Exit;
  end;

  p_IsFieldExists:= true;

  if LFld.SelfType <> p_FieldType then
  begin
    if p_RaiseErrorOnFieldMisMatch then
      raise Exception.Create('Invalid JSON parameter. Field type mismatch. Field ' + p_FieldName +
        ' is supplied as ' + LFld.SelfTypeName + ', however, it is expected to be supplied as ' + '.');
    Exit;
  end;

  case LFld.SelfType of
    jsString: Result:= TlkJSONstring(LFld).Value;
    jsNumber: Result:= TlkJSONnumber(LFld).Value;
    jsBoolean: Result:= TlkJSONboolean(LFld).Value;
  end;//case..
end;


//-------------------------------------------------------------------------------------------------

function CapitalizeFirstLetter(const AStr: string): string;
begin
  // Check if the string is not empty
  if AStr <> '' then
    // Capitalize the first letter using AnsiUpperCase and concatenate the rest of the string
    Result := AnsiUpperCase(AStr[1]) + Copy(AStr, 2, Length(AStr) - 1)
  else
    // Return empty string if the input is empty
    Result := '';
end;

//--------------------------------------------------------------------------------------------------------------------------------------------------------------
//to check if user is loged in or admin is loged in or no one is logged in
function ToValidateIfTypeIsUser ;
begin
  LTempCookievalStr:= Request.CookieFields.Values['UserAuthorization'];
  LCookieCheckInt:= StrToIntDef(LTempCookievalStr, 0);

  //Assumed that all the users have id other than 1, because 1 is admin
  if(LCookieCheckInt >= 2) then
  begin
    Result:= True;
  end
  else if (LCookieCheckInt = 0) then
  begin
    raise Exception.Create('Please login to perform the operation !');
  end
  else
  begin
    Result:= False;
    LResponseobj.Add('success', False);
    LResponseobj.Add('message', 'Only Admin can perform this operation');
    Response.StatusCode := 401;
    Response.ContentType := 'application/json';
  end;
end;
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// to check admin is loged in
function ToValidateIfTypeIsAdmin ;
begin
  LTempCookievalStr:= Request.CookieFields.Values['AdminAuthorization'];
  LCookieCheckInt:= StrToIntDef(LTempCookievalStr, 0);

  //Assumed that admin is only one and has user id 1
  if(LCookieCheckInt = 1) then
  begin
    Result:= True;
  end
  else
  begin
    Result:= False;
    LResponseobj.Add('success', False);
    LResponseobj.Add('message', 'Only Admin can perform this operation');
    Response.StatusCode := 401;
    Response.ContentType := 'application/json';
  end;
end;
//------------------------------------------------------------------------------------------------------------------------------------------------------------------
end.





