unit uclBookTransactions;
{
  Classes in this unit- TnsBookTransactions

  Purpose- To encapsulate all the functions related to the Book Transactions, Borrow or Return Transaction History(Update Transactions) and
           Edit Transaction History(edits done on book details) like
           Borrow Books, Return Books, Get all Edit Transaction History, and to GET all Transaction History of particular user
}
interface

uses
SysUtils, Classes, HTTPApp , ULKJSON , IBODataset, uclDataSet, uclBaseDataset, uclInnerTechDataSet,
   MSAccess, StdCtrls, DB, SDEngine;

type

  TnsBookTransactions = class
  private
    FDataSetForBorrow: TnsDataSet;
    FDataSet2ForBorrow: TnsDataSet;
    FDataSet3ForUpdateTransaction: TnsDataSet;
    FDataSet4ForEditTransactions: TnsDataSet;
    FnsquerryForUpdates: TnsQuery;

    function IsBookAvailabe(FDataSetForBorrow: TnsDataSet; LRecivedBookId: Integer): Boolean;

    function ToValidateTheBookIdInput(FDataSetForBorrow: TnsDataSet; LRecivedBookId: Integer): Boolean;

    function ToCheckIfMoreThan2BooksBorrowed(FDataSet2ForBorrow: TnsDataSet; LCookieCheckInt: Integer): Boolean;

  public
    FMSConnection : TMSConnection;
    constructor Create(p_Connection: TMSConnection); reintroduce;

    destructor Destroy; override;

    procedure AllValidationsforBorrowAndReturnBook(LRecivedBookId: Integer; LCookieCheckInt:Integer ; ForBorrow: Boolean = False );

    procedure AddRecordOfBorrow(LRecivedBookId: Integer; LCookieCheckInt: Integer; Response: TWebResponse; var LDueDate: TDateTime);

    procedure UpdateTransactionTable(var LTransactiontypestr:String; LRecivedBookId: Integer; LCookieCheckInt: Integer; Response: TWebResponse);

    procedure UpdateStatusOfBook(var LStatus:Boolean; LRecivedBookId: Integer; Response: TWebResponse);

    procedure DeleteRecordOfBorrowAfterReturn(LRecivedBookId: Integer; Response: TWebResponse);

    function GetAllTransactionsAsJSON(LResponseListVip: TlkJSONlist; LCookieCheckInt: Integer): tlkJSONList;

    function GetAllEditTransactionsAsJSON(LResponseListVip: TlkJSONlist):TlkJSONlist;


  end;//


implementation

//-----------------------------------------------------------------------------------------------------------------------

Constructor TnsBookTransactions.Create(p_Connection: TMSConnection);
begin
{*
  Intent: This constructor initializes a TnsBookTransactions object with the provided database connection.

  Parameters:
    - p_Connection: The database connection used by the TnsBookTransactions object.

  Result: It initializes the TnsBookTransactions object with the specified database connection and creates dataset components for different book transactions.
*}


  FMSConnection:= p_Connection;

  FDataSetForBorrow := TnsDataset.create(nil);
  FDataSetForBorrow.Connection:= FMSConnection;
  FDataSetForBorrow.UpdateTableName:= 'Books';
  FDataSetForBorrow.KeyFields:='book_id';

  FDataSet2ForBorrow:= TnsDataSet.Create(nil);
  FDataSet2ForBorrow.Connection:= FMSConnection;
  FDataSet2ForBorrow.UpdateTableName:= 'BorrowTransactions';
  FDataSet2ForBorrow.KeyFields:= 'borrow_id';

  FDataSet3ForUpdateTransaction:= TnsDataSet.Create(nil);
  FDataSet3ForUpdateTransaction.Connection:= FMSConnection;
  FDataSet3ForUpdateTransaction.UpdateTableName:= 'UpdateTransactions';
  FDataSet3ForUpdateTransaction.KeyFields:= 'update_id';

  FDataSet4ForEditTransactions:= TnsDataSet.Create(nil);
  FDataSet4ForEditTransactions.Connection:= FMSConnection;
  FDataSet4ForEditTransactions.UpdateTableName:= 'EditTransactions';
  FDataSet4ForEditTransactions.KeyFields:= 'edit_id';

  FnsquerryForUpdates := TnsQuery.Create(Nil);
  FnsquerryForUpdates.Connection := FmsConnection;

end;

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

destructor TnsBookTransactions.Destroy;
begin
  FreeAndNil(FDataSetForBorrow);
  FreeAndNil(FnsquerryForUpdates);
  
  inherited;
end;

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//to check the (check_out) status from Books table
function TnsBookTransactions.IsBookAvailabe;
var
LBookAvailableStatusBool: Boolean;

begin
{*
  Intent: This function is used to check the availability status of a book in the Books table.

  Parameters:
    - LReceivedBookId: The unique identifier of the book to check.


  Result: It returns True if the book is available (not checked out), False otherwise.
*}

{*
  Logic:
   - Close the dataset to prepare for loading a new dataset.
   - Construct the SQL query to select all fields from the Books table where the book_id matches the provided book_id.
   - Create parameter variables for the book_id parameter in the SQL query.
   - Open the dataset with the constructed SQL query.
   - Retrieve the value of the book_checkedout field from the dataset to determine the availability status.
   - If the book_checkedout field is False (not checked out), return True indicating that the book is available.
   - If the book_checkedout field is True (checked out), return False indicating that the book is not available.
*}

  FDataSetForBorrow.Close;
  FDataSetForBorrow.SQLSelect := 'SELECT * FROM Books WHERE book_id = (:p_val1)'  ;
  FDataSetForBorrow.CreateParamVariables;
  FDataSetForBorrow.ParamByName('p_val1').AsInteger:=  LRecivedBookId ;
  FDataSetForBorrow.Open;
  LBookAvailableStatusBool:= FDataSetForBorrow.FieldByName('book_checkedout').Asboolean ;

  if not (LBookAvailableStatusBool) then
  begin
    Result:= True;
  end
  else
  begin
    Result:= False;
  end;
end;

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//to validate the book input recieved with book id in database
function TnsBookTransactions.ToValidateTheBookIdInput;
begin
{*
  Intent: This method is used to validate the input book ID before performing book transactions.

  Parameters:
    - LReceivedBookId: The unique identifier of the book to check.


  Result: It returns True if the input book ID is valid, False otherwise.
*}

{*
  Logic:
   - Close the dataset associated with book transactions to prepare for a new query.
   - Construct the SQL query to select all fields from the Books table where the book_id matches the input book ID.
   - Create parameter variables and set the input book ID as a parameter value.
   - Open the dataset with the constructed SQL query.
   - Check if the dataset contains exactly one record because bookID is unique.
   - If the dataset contains exactly one record, return True indicating that the input book ID is valid.
   - If the dataset does not contain exactly one record, return False indicating that the input book ID is invalid.
*}
  FDataSetForBorrow.Close;
  FDataSetForBorrow.SQLSelect := 'SELECT * FROM Books WHERE book_id = (:p_val1)'  ;
  FDataSetForBorrow.CreateParamVariables;
  FDataSetForBorrow.ParamByName('p_val1').AsInteger:=  LRecivedBookId ;
  FDataSetForBorrow.Open;

  if (FDataSetForBorrow.RecordCount = 1) then
  begin
    Result:= True;
  end
  else
    Result:= False;
end;

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//checking if the user loged in has boroowed 2 books already
function TnsBookTransactions.ToCheckIfMoreThan2BooksBorrowed;
begin
{*
  Intent: This function is used to check if the logged-in user has borrowed more than 2 books already.

  Parameters:
    - LCookieCheckInt - Cookie value containig the user_id.


  Result: It returns True if the user has borrowed less than 2 books, False otherwise.
*}

{*
  Logic:
   - Close the dataset to prepare for loading a new dataset.
   - Construct the SQL query to select all records from the BorrowTransactions table where the user_id matches the logged-in user.
   - Create parameter variables for the user_id.
   - Open the dataset with the constructed SQL query.
   - Check if the dataset contains less than 2 records.
   - If the user has borrowed less than 2 books, return True.
   - Otherwise, return False.
*}
  FDataSet2ForBorrow.Close;
  FDataSet2ForBorrow.SQLSelect := 'SELECT * FROM BorrowTransactions WHERE user_id = (:p_val1)'  ;
  FDataSet2ForBorrow.CreateParamVariables;
  FDataSet2ForBorrow.ParamByName('p_val1').AsInteger:=  LCookieCheckInt ;
  FDataSet2ForBorrow.Open;
  //check if the particular user has borrowed 2 or less than two books, because one user can
  // only borrow max 2 books at a time.
  if (FDataSet2ForBorrow.RecordCount < 2)  then
  begin
    Result:= True;
  end
  else
    Result:= False;

end;

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// function calling all the individual validations

procedure  TnsBookTransactions.AllValidationsforBorrowAndReturnBook(LRecivedBookId: Integer; LCookieCheckInt:Integer ; ForBorrow: Boolean = False );
begin
{*
  Intent: This procedure performs all the necessary validations for borrowing or returning a book.

  Parameters:
    - LRecivedBookId: The ID of the book to be borrowed or returned.
    - LCookieCheckInt: The integer value for checking the cookie (user authentication).
    - ForBorrow: Specifies whether the operation is for borrowing a book. Default is False.

  Calling functions:
   - ToValidateTheBookIdInput
   - ToCheckIfMoreThan2BooksBorrowed
   - IsBookAvailable

  Result: It raises an exception if any of the validations fail.
*}

{*
  Logic:
   - Validate the book ID input by checking if the book exists in the library.
   - If ForBorrow is True, perform additional validations for borrowing a book:
     - Check if the user has already borrowed more than 2 books.
     - Verify if the book is available in the library to be borrowed.
   - If ForBorrow is False (indicating the operation is for returning a book), perform validation:
     - Check if the book is already available in the library (not checked out).
   - Raise exceptions with appropriate error messages if any validation fails.
*}


  //raise exception when the entered book id is not correct
  if not (ToValidateTheBookIdInput(FDataSetForBorrow, LRecivedBookId))then
  begin
    raise Exception.Create('Book with this id not found in library check if you have entered the correct id!');
    exit;
  end;

  // validation only when user want to boorw book
  if (ForBorrow) then
  begin
    //check if the particular user has borrowed 2 or less than two books, because one user can
    // only borrow max 2 books at a time.
    if not(ToCheckIfMoreThan2BooksBorrowed(FDataSet2ForBorrow,LCookieCheckInt))then
    begin
      raise Exception.Create('You cannot borrow more than 2 books , first return the borrowed books');
      exit;
    end;

    //checking if particular book is availabe in the library to be checked out
    if not (IsBookAvailabe(FDataSetForBorrow,LRecivedBookId)) then
    begin
      raise Exception.Create('Book is not Available in the Library Please check back later!');
      exit;
    end;
  end;

  // validation only when user want to borrow or return
  if not (ForBorrow) then
  begin
    //checking if particular book is  checkedout from the library to be checked-in
    if (IsBookAvailabe(FDataSetForBorrow,LRecivedBookId)) then
    begin
      raise Exception.Create('Book is already Available in the Library!');
      exit;
    end;
  end;

end;

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//inserting the record in BorrowTransactions table for borrowed book with user id and setting due date
procedure TnsBookTransactions.AddRecordOfBorrow;
begin
{*
  Intent: This procedure inserts a record into the BorrowTransactions table for a borrowed book with the specified user ID and sets the due date.

  Result: It inserts a record into the BorrowTransactions table with the borrower's user ID, book ID, transaction date, and due date.
*}

{*
  Logic:
   - Close the dataset to prepare for inserting a new record.
   - Construct the SQL query to select no records from the BorrowTransactions table.
   - Open the dataset with the constructed SQL query.
   - Calculate the due date for the borrowed book (5 days from the current date).
   - Insert a new record into the dataset.
   - Set the user_id, book_id, transaction_date, and due_date fields with the appropriate values.
   - Post the changes to the dataset.
   - Handle any exceptions by raising an error and canceling the dataset changes.
*}


  FDataSet2ForBorrow.Close;
  FDataSet2ForBorrow.SQLSelect := 'SELECT * FROM BorrowTransactions WHERE borrow_id = -1 '  ;
  FDataSet2ForBorrow.Open;
  LDueDate:= Now + 5;
  
  try

    FDataSet2ForBorrow.Insert;
    FDataSet2ForBorrow.FieldByName('user_id').AsInteger := LCookieCheckInt;
    FDataSet2ForBorrow.FieldByName('book_id').AsInteger := LRecivedBookId;
    FDataSet2ForBorrow.FieldByName('transaction_date').AsDateTime := Now;
    FDataSet2ForBorrow.FieldByName('due_date').AsDateTime := LDueDate ;

    FDataSet2ForBorrow.Post;

  except on E:Exception do
  begin
    raise Exception.Create(E.Message);
    FDataSet2ForBorrow.Cancel;
  end;
  end;

end;

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//updating the UpdateTransactions Table with the latest borrow record or return record
procedure TnsBookTransactions.UpdateTransactionTable;
begin
{*
  Intent: This procedure is used to update the UpdateTransactions table with the latest borrow or return record.

  Result: It inserts a new record into the UpdateTransactions table with the provided transaction details.
*}

{*
  Logic:
   - Clear the SQL statement of the query component.
   - Set the SQL statement to insert a new record into the UpdateTransactions table with user_id, book_id, transaction_type, and transaction_date fields.
   - Create parameter variables for user_id, book_id, transaction_type, and transaction_date.
   - Set parameter values based on the values received from external variables (LCookieCheckInt, LRecivedBookId, LTransactiontypestr, Now).
   - Execute the DML (Data Manipulation Language) statement to insert the record into the UpdateTransactions table.
   - Close the query component.
   - Handle any exceptions by raising an exception with the error message and exiting the procedure.
*}

  try

    FnsquerryForUpdates.SQL.Clear;

    FnsquerryForUpdates.SQL.Text:='INSERT INTO UpdateTransactions (user_id, book_id, transaction_type, transaction_date) VALUES (:user_id, :book_id, :transaction_type, :transaction_date)';
    FnsquerryForUpdates.CreateParamVariables;
    FnsquerryForUpdates.ParamByName('user_id').AsInteger := LCookieCheckInt;
    FnsquerryForUpdates.ParamByName('book_id').AsInteger := LRecivedBookId;
    FnsquerryForUpdates.ParamByName('transaction_type').AsString := LTransactiontypestr;
    FnsquerryForUpdates.ParamByName('transaction_date').AsDate := Now;

    FnsquerryForUpdates.ExecuteDML;
    FnsquerryForUpdates.Close;

  except on E:Exception do
  begin
    raise Exception.Create(E.Message);
  end;
  end;
end;

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//updating Books table to change the checkout status to true after borrow
procedure TnsBookTransactions.UpdateStatusOfBook;
begin
{*
  Intent: This procedure updates the checkout status of a book in the Books table after it has been borrowed.

  Result: It updates the checkout status of the book to true if the borrow operation is successful.
*}

{*
  Logic:
   - Clear the SQL command of the update query.
   - Set the SQL command to update the book_checkedout field in the Books table based on the book_id.
   - Create parameter variables for the book_id and status parameters.
   - Set the parameter values for book_id and status.
   - Execute the DML (Data Manipulation Language) query to update the database.
   - Close the query after execution.
   - If an exception occurs during the update process, raise an exception with the error message.
*}
  try
    FnsquerryForUpdates.SQL.Clear;
    FnsquerryForUpdates.SQL.Text:='UPDATE Books SET book_checkedout = :status WHERE book_id = :book_id;';
    FnsquerryForUpdates.CreateParamVariables;
    FnsquerryForUpdates.ParamByName('book_id').AsInteger := LRecivedBookId;
    FnsquerryForUpdates.ParamByName('status').AsBoolean := LStatus;
    FnsquerryForUpdates.ExecuteDML;
    FnsquerryForUpdates.Close;
  except on E:Exception do
  begin
    //Response.Content:= E.Message;
    raise Exception.Create(E.Message);
  end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------

//Delete record of borrow after the book is returned
procedure TnsBookTransactions.DeleteRecordOfBorrowAfterReturn(LRecivedBookId: Integer; Response: TWebResponse);
begin
{*
  Intent: This procedure is used to delete the record of a borrowed book after it is returned.

  Parameters:
   - LRecivedBookId: The ID of the book.

  Calling functions:
   - Not specified

  Result: It deletes the record of the borrowed book from the BorrowTransactions table.
*}

{*
  Logic:
   - Clear the SQL command and set it to delete the record from the BorrowTransactions table where the book_id matches the provided value.
   - Create parameter variables for the book_id parameter.
   - Execute the DML command to delete the record.
   - Close the dataset.
   - If an exception occurs during the process, raise an exception with the error message.
*}
  try
    FnsquerryForUpdates.SQL.Clear;
    FnsquerryForUpdates.SQL.Text:=' DELETE FROM BorrowTransactions WHERE book_id = :book_id;';
    FnsquerryForUpdates.CreateParamVariables;
    FnsquerryForUpdates.ParamByName('book_id').AsInteger := LRecivedBookId;
    FnsquerryForUpdates.ExecuteDML;
    FnsquerryForUpdates.Close;
  except on E:Exception do
  begin
    //Response.Content:= E.Message;
    raise Exception.Create(E.Message);
    exit;
  end;
  end;
end;

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//                                                     GET all trqansactions in JSON list
function TnsBookTransactions.GetAllTransactionsAsJSON(LResponseListVip: TlkJSONlist; LCookieCheckInt: Integer): tlkJSONList;

var
LResponseObjVip: TlkJSONobject;
LBookIDField: TField;
LTempTitleField: TField;
LTransactionTypeField: TField;
LTransactionDateField: TField;

begin
{*
  Intent: This function retrieves all transactions associated with a user and returns them as a JSON list.

  Parameters:
    - LResponseListVip: The JSON list object to store the transaction data.
    - LCookieCheckInt: The integer value representing the user's authentication cookie.

  Result: It returns a JSON list containing all transactions made by the authenticated user.
*}

{*
  Logic:
   - Construct and execute a SQL query to retrieve transactions with associated book titles using a join operation.
   - Check if the user has made any transactions. If not, raise an exception.
   - Iterate through each transaction record fetched from the database.
   - For each transaction, create a JSON object containing details such as Book ID, Book Title, Transaction Type, and Transaction Date.
   - Add the JSON object to the response list.
   - Return the JSON list containing all transactions.
*}



  //load the dataset with join queery to get book title
  FDataSet3ForUpdateTransaction.Close;
  FDataSet3ForUpdateTransaction.SQLSelect := 'SELECT UT.*, B.book_title FROM UpdateTransactions UT JOIN Books B ON UT.book_id = B.book_id WHERE UT.user_id = (:p_val1)' ;
  FDataSet3ForUpdateTransaction.CreateParamVariables;
  FDataSet3ForUpdateTransaction.ParamByName('p_val1').AsInteger:=  LCookieCheckInt ;
  FDataSet3ForUpdateTransaction.Open;

  try
    // check if the user loged in has made any transactions untill now
    if (FDataSet3ForUpdateTransaction.RecordCount =0) then
      raise Exception.Create('you have not made any book transactions ');

    FDataSet3ForUpdateTransaction.First;
    
    LBookIDField:= FDataSet3ForUpdateTransaction.FieldByName('book_id');
    LTempTitleField:= FDataSet3ForUpdateTransaction.FieldByName('book_title');
    LTransactionTypeField:= FDataSet3ForUpdateTransaction.FieldByName('transaction_type');
    LTransactionDateField:= FDataSet3ForUpdateTransaction.FieldByName('transaction_date');

    while not FDataSet3ForUpdateTransaction.Eof do
    begin
      LResponseObjVip:= TlkJSONobject.Create();

      LResponseObjVip.Add('Book ID :',LBookIDField.AsInteger);
      LResponseObjVip.Add('Book Title:',LTempTitleField.AsString);
      LResponseObjVip.Add('Transaction Type:',LTransactionTypeField.AsString);
      LResponseObjVip.Add('Transaction Date:', DateToStr(LTransactionDateField.AsDateTime));

      LResponseListVip.Add(LResponseObjVip);
      FDataSet3ForUpdateTransaction.Next;

    end;

    Result:= LResponseListVip;

  finally
    FDataSet3ForUpdateTransaction.Close;
  end;


end;

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//                                      GET all Edit transactions in JSON list
function TnsBookTransactions.GetAllEditTransactionsAsJSON(LResponseListVip: TlkJSONlist):TlkJSONlist;
var
LBookIDField: TField;
LModifiedField: TField;
LOldValueField: TField;
LEditDateField: TField;
LNewValueField: TField;
LResponseObjVip: TlkJSONobject;
LUserIDField: TField;
LbookidInt:Integer;
begin
{*
  Intent: This function retrieves all edit transactions from the database and formats them as a JSON list.

  Parameters:
    - LResponseListVip: The JSON list object to store the transaction data.

  Result: It returns a JSON list containing all edit transactions.
*}

{*
  Logic:
   - Construct and execute an SQL query to select all fields from the EditTransactions table.
   - Iterate over the dataset to extract each edit transaction.
   - Create a JSON object for each transaction containing the book ID, user ID, modified field, old value, new value, and edit date.
   - Add each JSON object to a JSON list.
   - Close the dataset after processing all transactions.
   - Return the JSON list containing all edit transactions.
*}


  FDataSet4ForEditTransactions.SQLSelect:='SELECT * FROM EditTransactions';
  FDataSet4ForEditTransactions.Open;
  try
    //check if there are any transactions
    if FDataSet4ForEditTransactions.RecordCount = 0 then
      raise Exception.Create('No transactions untill now');

    FDataSet4ForEditTransactions.First;
    LBookIDField:= FDataSet4ForEditTransactions.FieldByName('book_id');
    LModifiedField:=FDataSet4ForEditTransactions.FieldByName('modified_field');
    LOldValueField:=FDataSet4ForEditTransactions.FieldByName('old_value');
    LNewValueField:=FDataSet4ForEditTransactions.FieldByName('new_value');
    LEditDateField:=FDataSet4ForEditTransactions.FieldByName('edit_date');
    LUserIDField:=FDataSet4ForEditTransactions.FieldByName('user_id');

    while not FDataSet4ForEditTransactions.Eof do
    begin
      LResponseObjVip:= TlkJSONobject.Create();
      LbookidInt:= LBookIDField.AsInteger;
      //show book id only if change made to a book specifically
      if LbookidInt <> 0 then
        LResponseObjVip.Add('Book ID :',LBookIDField.AsInteger);

      LResponseObjVip.Add('User ID :',LUserIDField.AsInteger);
      LResponseObjVip.Add('Modified Field:',LModifiedField.AsString);
      LResponseObjVip.Add('Old Value:',LOldValueField.AsString);
      LResponseObjVip.Add('New Value:', LNewValueField.AsString);
      LResponseObjVip.Add('Edit Date:', DateToStr(LEditDateField.AsDateTime));

      LResponseListVip.Add(LResponseObjVip);
      FDataSet4ForEditTransactions.Next;
    end;
  finally
    FDataSet4ForEditTransactions.Close;
  end;
  Result:= LResponseListVip;

end;

end.
