unit uclMainAPIunit;
{
  Classes in this unit- TnsBookTransactions

  Purpose- To encapsulate all the functions related to the Book Transactions and Transaction History like
            Borrow Books, Return Books and to GET all Transaction History of particular user
}
interface

uses
  SysUtils, Classes, HTTPApp , ULKJSON , IBODataset, uclDataSet, uclBaseDataset, uclInnerTechDataSet,
   MSAccess, StdCtrls, DB, SDEngine;

type
  TWebModule1 = class(TWebModule)
    SDDatabase1: TSDDatabase;
    SDTable1: TSDTable;
    procedure WebModule1WebActionItem1Action(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebActionItem2Action(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebActionItem3Action(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebActionItem4Action(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebActionItem6Action(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebActionItem7Action(Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1WebActionItem8Action(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1GET_Transaction_historyAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModule1GET_Edit_HistoryAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);

  private
    MyCookie : TCookie;
    //procedure EstDBConnection;

  public
    { Public declarations }
    FMSConnection : TMSConnection;
    procedure EstDBConnection;
  end;
  
var
  WebModule1: TWebModule1;

implementation
uses
uclUtils,
uclAllBooks,
uclUsers,
uclBookTransactions;

{$R *.DFM}
//-----------------------------------------------------------------------------------------------------
//                                                            Establish connection with database
procedure TWebModule1.EstDBConnection;
begin   
  //if FMSConnection = nil then
 // begin
    //FMSConnection := TMSConnection.Create(TWebModule1);
    FMSConnection := TMSConnection.Create(nil);

    FMSConnection.Server := 'NOVATECH113';
    FMSConnection.Username := 'sa';
    FMSConnection.Password := 'manager';
    FMSConnection.Database := 'LibraryDB';
    FMSConnection.Connect;
  //end;//
  //nsDataSet1.TechDataSet.Connection := FmsConnection;
  //nsDataSet2.TechDataSet.Connection := FmsConnection;
  //nsQuery1.Connection := FmsConnection;
end;

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                            //  GET all authors, Edit Author, Add Author    Path- /authors

procedure TWebModule1.WebModule1WebActionItem1Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);

var
LBookManagementObj: TnsBookManagement;
LResponseListVip: TlkJSONlist;
LCookieCheckInt: Integer;
LTempCookievalStr: String;
LResponseobj: TlkJSONobject;

begin
{*
  Intent: Handles requests to get all authors, add a new author, or edit an existing author.

  Parameters:
    - Sender: The TObject triggering the action.
    - Request: The TWebRequest object containing the request data.
    - Response: The TWebResponse object to handle the response data.
    - Handled: Boolean value indicating if the request has been handled.

  Result: Responds to the request with the appropriate action (get all authors, add author, edit author) or returns an error message.
*}

{*
  Logic:
   - Establish connection with the database.
   - Create an instance of the TnsBookManagement class.
   - Handle the request method type (GET, POST, PUT).
   - For GET requests:
     - Check if the user is authenticated as an admin.
     - Retrieve all author details as JSON and send the response.
   - For POST requests:
     - Check if the user is authenticated as an admin.
     - Add a new author to the database and send a success message.
   - For PUT requests:
     - Check if the user is authenticated as an admin.
     - Edit an existing author's details in the database and send a success message.
   - Handle other HTTP methods with an error message.
*}


  //Establish Connection with Database
  Self.EstDBConnection;
  //Create instance of bookmanagement class
  LBookManagementObj:= TnsBookManagement.Create(FMSConnection);
  LResponseListVip:= TlkJSONlist.Create;
  LResponseobj:= TlkJSONobject.Create;
  try
    case Request.MethodType of
      //Get all Authors
    mtGet:
      begin
        // Handle GET request
        LResponseListVip:= TlkJSONlist.Create;
        try
          try
            if not ToValidateIfTypeIsAdmin(LCookieCheckInt, LTempCookievalStr, Request, Response, LResponseobj) then
            begin
              Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
              exit;
            end;

            //Calling function to Get All Author Details
            LBookManagementObj.GetAllAuthorsAsJSON(LResponseListVip);

            Response.ContentType:= 'application/json';
            Response.Content:=TlkJSON.GenerateText(LResponseListVip as TlkJSONbase);

          except on E:Exception do
          begin

            LResponseobj.Add('success', False);
            LResponseobj.Add('message',E.Message );
            Response.ContentType := 'application/json';
            Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
            exit;
          end;
          end;

        finally
          LResponseListVip.Free;
        end;//
      end;

      //Add new Author
    mtPost:
      begin
        // Handle POST request
        try

        //validation to check if admin is logged in
        if not ToValidateIfTypeIsAdmin(LCookieCheckInt, LTempCookievalStr, Request, Response, LResponseobj) then
        begin
          Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
          exit;
        end;

        //Calling function to Add Author
        LBookManagementObj.AddAuthorinDB(Request, Response);

        //success Message when adding Author is done
        LResponseobj.Add('success', True);
        LResponseobj.Add('message', ' Author Added Successfully');
        LResponseobj.Add('Status Code',200);
        Response.StatusCode := 200;
        Response.ContentType := 'application/json';
        Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;

        except on E:Exception do
        begin
          LResponseobj.Add('success', False);
          LResponseobj.Add('message',E.Message );
          Response.ContentType := 'application/json';
          Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
          exit;
        end;
        end;
      end;

      //Edit Author Details
    mtPut:
      begin
        try
          //validation to check if admin is logged in
          if not ToValidateIfTypeIsAdmin(LCookieCheckInt, LTempCookievalStr, Request, Response, LResponseobj) then
          begin
            Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
           exit;
          end;

        //Calling function to edit Author name
        LBookManagementObj.EditAuthorInDB(Request, Response, LCookieCheckInt);

        //success Message when Editing Author is done
        LResponseobj.Add('success', True);
        LResponseobj.Add('message', ' Author Edited Successfully');
        LResponseobj.Add('Status Code',200);
        Response.StatusCode := 200;
        Response.ContentType := 'application/json';
        Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;

        except on E:Exception do
        begin
          LResponseobj.Add('success', False);
          LResponseobj.Add('message',E.Message );
          LResponseobj.Add('Status Code', 401);
          Response.ContentType := 'application/json';
          Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
          exit;
        end;
        end;
      end;

     //case finish
    // Handle other HTTP methods if needed
    else
      begin
        // Handle other types of requests
        Response.Content := 'Unsupported HTTP method';
        Response.StatusCode := 405; // Method Not Allowed
      end;
    end;
  finally
    LBookManagementObj.Free;
    LResponseListVip.Free;
    LResponseobj.Free;
  end;

end;

//-------------------------------------------------------------------------------------------------------

                                                    //  path-/book   GET ALL Books or post ALL Books

procedure TWebModule1.WebModule1WebActionItem2Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);

var
  LResponseListVip: TlkJSONlist;
  LResponseobj: TlkJSONobject;
  LBookManagement: TnsBookManagement;
  LCookieCheckInt: Integer;
  LTempCookievalStr: String;
  
begin
{*
  Intent: This procedure handles GET and POST requests related to books.

  Parameters:
    - Sender: The TObject that triggered the action.
    - Request: The TWebRequest object containing the request details.
    - Response: The TWebResponse object used to send the response.
    - Handled: Boolean value indicating whether the request has been handled.

  Calling functions:
   - ToValidateIfTypeIsAdmin in the same unit (for POST requests)
   - AddBookInDB (for POST requests)
   - GetAllBooksAsJSON(for GET request)
   
  Result: It processes GET requests to retrieve details of all books in the library and POST requests to add books.
*}

{*
  Logic:
   - Establish database connection and create an instance of TnsBookManagement.
   - Handle GET requests:
     - Call GetAllBooksAsJSON method of TnsBookManagement to get details of all books in the library.
     - Generate JSON response containing book details on success.
     - Return appropriate error message if an exception occurs.
   - Handle POST requests:
     - Validate if the user is an admin using ToValidateIfTypeIsAdmin function.
     - Call AddBookInDB method of TnsBookManagement to add a book to the database.
     - Generate success message on successful addition of the book.
     - Return appropriate error message if an exception occurs.
   - Handle other HTTP methods by returning an error message indicating unsupported method.
*}

//                                                      case statements for Get and POST books     (tested :okay)

  //data set with connection created
  Self.EstDBConnection;
  LBookManagement := TnsBookManagement.Create(FMSConnection);
  LResponseobj:= TlkJSONobject.Create();
  try
    //to get all books
    case Request.MethodType of
    mtGet:
      begin
        // Handle GET request
        LResponseListVip:= TlkJSONlist.Create;
        try
          try

            //Calling Function to Get Details Of All Books In Library
            LBookManagement.GetAllBooksAsJSON( LResponseListVip, '');

            // on success
            Response.StatusCode := 200;
            Response.ContentType := 'application/json';
            Response.Content:= TlkJSON.GenerateText(LResponseListVip as TlkJSONbase) ;

          except on E:Exception do
          begin

            LResponseobj.Add('success', False);
            LResponseobj.Add('message',E.Message );
            Response.ContentType := 'application/json';
            Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
            exit;
          end;
          end;

        finally

          LResponseListVip.Free;
          LResponseobj.Free;
        end;//
      end;

      // to Add Books
    mtPost:
      begin
        // Handle POST request
        try

        //validation to check if admin is logged in
        if not ToValidateIfTypeIsAdmin(LCookieCheckInt, LTempCookievalStr, Request, Response, LResponseobj) then
        begin
          Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
          exit;
        end;

        //Calling function to Add Books
        LBookManagement.AddBookInDB(Request, Response);

        //success Message when adding book is done
        LResponseobj.Add('success', True);
        LResponseobj.Add('message', ' Books Added Successfully');
        LResponseobj.Add('Status Code',200);
        Response.StatusCode := 200;
        Response.ContentType := 'application/json';
        Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;

        except on E:Exception do
        begin
          LResponseobj.Add('success', False);
          LResponseobj.Add('message',E.Message );
          Response.ContentType := 'application/json';
          Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
          exit;
        end;
        end;
      end;
     //case finish
    // Handle other HTTP methods if needed
    else
    begin
      // Handle other types of requests
      Response.Content := 'Unsupported HTTP method';
      Response.StatusCode := 405; // Method Not Allowed
    end;
    end;
  finally
    LBookManagement.Free;
    LResponseobj.Free;
  end;


end;


//---------------------------------------------------------------------------------------------------------------------------------
                                                           //path-/bookfilter GET Books in Filter Search    (tested:okay)
procedure TWebModule1.WebModule1WebActionItem3Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  LJsonObj: TlkJSONobject;
  LBookManagement: TnsBookManagement;
  LIsPresent: Boolean;
  LResponseListVip: TlkJSONlist;
  LAuthorField: String;
  LTitleField: String;
  LCategoryField: String;
  LResponseobj: TlkJSONobject;


begin
{*
  Intent: This procedure handles the filtering of books based on specified criteria.

  Parameters:
    - Request: The HTTP request object containing filter criteria.
    - Response: The HTTP response object to return the filtered book details.
    - Handled: Indicates whether the request has been handled.

  Calling functions:
   -  GetFilterSearchedBooksAsJSONList

  Result: It returns a JSON response containing the details of books filtered according to the applied criteria.
*}

{*
  Logic:
   - Establish a database connection.
   - Parse the JSON request content to extract filter criteria such as Author, Title, and Category.
   - Capitalize the first letter of the Category field.
   - Perform basic input field checks to ensure only one field or the Author and Category fields are filled for searching books accordingly.
   - Call the GetFilterSearchedBooksAsJSONList function of TnsBookManagement to retrieve the details of books based on the applied filters.
   - Generate a JSON response containing the details of filtered books and set the response content type.
   - Handle any exceptions that occur during the process and return an appropriate error response with status code 401.
*}



  Self.EstDBConnection;
  LJsonObj:= TlkJSON.parsetext(Request.Content) as TlkJSONobject;
  LBookManagement := TnsBookManagement.Create(FMSConnection);
  LResponseListVip:= TlkJSONlist.Create;
  LResponseobj:= TlkJSONobject.Create();
  try
    try
      LAuthorField:= FieldValueByNameAs(LJsonObj, 'Author', jsString,DEFAULT_VALUE_OFSTRING_FORVALIDATION,LIsPresent,True,True);
      LTitleField:= FieldValueByNameAs(LJsonObj, 'Title', jsString,DEFAULT_VALUE_OFSTRING_FORVALIDATION, LIsPresent,True,True);
      LCategoryField:= FieldValueByNameAs(LJsonObj, 'Category', jsString,DEFAULT_VALUE_OFSTRING_FORVALIDATION, LIsPresent,True,True);
      //function to capitalize first letter 
      CapitalizeFirstLetter(LCategoryField);

      //Basic input field checks 
      if (LAuthorField <> DEFAULT_VALUE_OFSTRING_FORVALIDATION)and(LTitleField <> DEFAULT_VALUE_OFSTRING_FORVALIDATION)and
          (LCategoryField <> DEFAULT_VALUE_OFSTRING_FORVALIDATION) then
        raise Exception.Create('Please Fill Only One Field or the author and category field to Search Book Accordingly');

      if (LAuthorField = DEFAULT_VALUE_OFSTRING_FORVALIDATION)and(LTitleField = DEFAULT_VALUE_OFSTRING_FORVALIDATION)and
          (LCategoryField = DEFAULT_VALUE_OFSTRING_FORVALIDATION) then
        raise Exception.Create('Please Fill Atleast Only One Field or the author and category field to Search Book Accordingly');


      // Calling function to Get the book details according to filters
      LBookManagement.GetFilterSearchedBooksAsJSONList(LAuthorField,LCategoryField,LTitleField,LResponseListVip);

      //JSON List containing the details of book according to the applied filters
      Response.ContentType := 'application/json';
      Response.Content := TlkJson.GenerateText(LResponseListVip);

    except on E:Exception do
    begin
      LResponseobj.Add('success', False);
      LResponseobj.Add('message',E.Message );
      Response.ContentType := 'application/json';
      LResponseobj.Add('Status Code',401);
      Response.StatusCode := 401;
      Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
      exit;
    end;
    end;

  finally
    LJsonObj.Free;
    LBookManagement.Free;
    LResponseListVip.Free;
    LResponseobj.Free;
  end;

   
end;

//------------------------------------------------------------------------------------------------------------------------------------
                                                    // GET path- /login //User Login.

procedure TWebModule1.WebModule1WebActionItem4Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);

var
LJsonObj: TlkJSONobject;
LResponseObj: TlkJSONobject;
LUsernameField: String;
LPasswordField: String;
LIsPresent: Boolean;
LToken: Integer;
UserManagement: TnsUserManagement;

begin
{*
  Intent: This procedure handles user login by verifying the provided username and password against the database.

  Parameters:
    - Request: The HTTP request object containing the username and password in the request content.
    - Response: The HTTP response object to send the login response.
    - Handled: Boolean flag indicating whether the request has been handled.

  Calling functions:
   - Not specified

  Result: It validates the provided username and password, sets the appropriate cookie for user authentication,
           and sends the login response indicating success or failure.
*}

{*
  Logic:
   - Parse the request content to extract the username and password.
   - Create a new instance of TnsUserManagement to handle user management operations.
   - Check if both username and password are provided. If not, raise an exception.
   - Call the CheckIfUserExist function to verify the existence of the user in the database.
   - If the user does not exist, send a login response indicating failure.
   - If the user exists, set the appropriate cookie based on the user's role (admin or regular user).
   - Send a login response indicating success.
*}


//                                                               revised code of user login                  (tested okay)

  Self.EstDBConnection;
  LJsonObj:= TlkJSON.parsetext(Request.Content) as TlkJSONobject;
  LResponseObj:= TlkJSONobject.Create();
  UserManagement:= TnsUserManagement.Create(FMSConnection);
  try
    LUsernameField:= FieldValueByNameAs(LJsonObj, 'Username', jsString, DEFAULT_VALUE_OFSTRING_FORVALIDATION, LIsPresent, True, True);
    LPasswordField:= FieldValueByNameAs(LJsonObj, 'Password', jsString, DEFAULT_VALUE_OFSTRING_FORVALIDATION, LIsPresent, True, True);

    try
      if (LUsernameField = DEFAULT_VALUE_OFSTRING_FORVALIDATION) or (LPasswordField = DEFAULT_VALUE_OFSTRING_FORVALIDATION) then
      begin
          raise Exception.Create('An error occurred: Please provide values in both Username and Password field ');
      end;

      //to do check the username and password entered against the one in database
      if not(UserManagement.CheckIfUserExist(LUsernameField, LPasswordField, LToken)) then
      begin

        LResponseobj.Add('success', False);
        LResponseobj.Add('message', ' You Are Not Registered');
        LResponseobj.Add('Status Code', 400);
        Response.StatusCode := 404;
        Response.ContentType := 'application/json';
        Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
        Exit;
      end;

      // Set Token and add cookie
      if (LToken <> 1) then
        begin

          MyCookie := Response.Cookies.Add;
          MyCookie.Name := 'UserAuthorization';
          MyCookie.Value := IntToStr(LToken);
        end
        // when token is = 1, ie admin because only one admin exist with user_id =1
        else
        begin

          MyCookie := Response.Cookies.Add;
          MyCookie.Name := 'AdminAuthorization';
          MyCookie.Value := IntToStr(LToken);
        end;

        LResponseobj.Add('success', True);
        LResponseobj.Add('message', 'Welcome! You have been successfully loged in');
        Response.StatusCode := 200;
        Response.ContentType := 'application/json';
        Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;


    except on E:Exception do
    begin
      LResponseobj.Add('success', False);
      LResponseobj.Add('message',E.Message );
      LResponseobj.Add('Status Code', 400);
      Response.StatusCode := 400;
      Response.ContentType := 'application/json';
      Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;

      exit;
    end;
    end;

  finally
    LResponseObj.Free;
    LJsonObj.Free;
    UserManagement.Free;
  end;

end;

//----------------------------------------------------------------------------------------------------------------------------------
                                                //path- post /borrow to borrow available book

procedure TWebModule1.WebModule1WebActionItem6Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
LRecivedBookId: Integer;
LCookieCheckInt: Integer;
LTempCookievalStr: String;
LRequestJsonObj: TlkJSONobject;
LIsPresent: Boolean;
LDueDate: TDateTime;
LTransactiontypestr: String;
LStatus: Boolean;
LResponseobj: TlkJSONobject;

LBookTransactionsObj: TnsBookTransactions;

begin
{*
  Intent: This procedure is used to handle the borrowing of an available book.

  Calling functions:
   - AllValidationsforBorrowAndReturnBook (All the validations)
   - AddRecordOfBorrow (adding record of borrow in BorrowTransactions Table)
   - UpdateTransactionTable (add record of borrow in the UpdateTransactions table)
   - UpdateStatusOfBook (Update the status of book as checkedout in the database)

  Result: It processes the request to borrow a book and sends a response indicating success or failure.
*}

{*
  Logic:
   - Establish a database connection and initialize a BookTransactions object.
   - Parse the request content to extract the BookID.
   - Perform validations and checks:
     - Check if the BookID is provided and is a valid integer.
     - Validate if the user is logged in and is not an admin.
     - Perform additional validations using AllValidationsforBorrowAndReturnBook method.
   - Add a record of borrowing in the BorrowTransaction table.
   - Add a record in the UpdateTransaction table.
   - Update the checked-out status of the book.
   - Generate a success message with the due date to return the book.
   - Handle exceptions and send an appropriate error response if any validation fails or an error occurs during processing.
*}


//***********************************************************************************************************************************************
//                                                           revised code of borrow book                  (tested okay)

  Self.EstDBConnection;
  LBookTransactionsObj:= TnsBookTransactions.Create(FMSConnection);
  LRequestJsonObj:= TlkJSON.parsetext(Request.Content) as TlkJSONobject;
  LRecivedBookId:= FieldValueByNameAs(LRequestJsonObj, 'BookID', jsNumber, 0, LIsPresent, True, True);
  LResponseobj:= TlkJSONobject.Create();
  try
    LTransactiontypestr:='checkout';
    LStatus:= True;
    try
      // check if the recieved input type is other than integer
      if (LRecivedBookId = 0) then
      begin
        raise Exception.Create('Please provide the book id (number) for the book you want to borrow!');
        exit;
      end;

      //raise exception when admin or no one is loged in
      if not (ToValidateIfTypeIsUser(LCookieCheckInt, LTempCookievalStr, Request, Response, LResponseobj))then
      begin
        Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
        exit;
      end;

      // Validations
      LBookTransactionsObj.AllValidationsforBorrowAndReturnBook(LRecivedBookId, LCookieCheckInt, True);

      //Add the record of borrow in BorrowTransaction table
      LBookTransactionsObj.AddRecordOfBorrow(LRecivedBookId, LCookieCheckInt, Response, LDueDate);

      //Add the record in UpdateTransaction table
      LBookTransactionsObj.UpdateTransactionTable(LTransactiontypestr, LRecivedBookId, LCookieCheckInt, Response);

      //UPDATE the checked out status of the book
      LBookTransactionsObj.UpdateStatusOfBook(LStatus, LRecivedBookId, Response);

      //success message of borrowing book
      LResponseobj.Add('success', True);
      LResponseobj.Add('message', 'yes book borrowed, due date to return book is: '+ DateToStr(LDueDate));
      LResponseobj.Add('Status Code', 200);
      Response.StatusCode := 200;
      Response.ContentType := 'application/json';
      Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;

    except on E:Exception do
    begin
      //Response.Content:= E.Message;
      LResponseobj.Add('success', False);
      LResponseobj.Add('message',E.Message );
      LResponseobj.Add('Status Code', 400);
      Response.StatusCode := 404;
      Response.ContentType := 'application/json';
      Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
      exit;
    end;
    end;
  finally
    LBookTransactionsObj.Free;
    LRequestJsonObj.Free;
    LResponseobj.Free;
  end;

end;

//------------------------------------------------------------------------------------------------------------------
//                                                        Path- /return    to return borrowed book

procedure TWebModule1.WebModule1WebActionItem7Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var

LRecivedBookId: Integer;
LCookieCheckInt: Integer;
LTempCookievalStr: String;
LRequestJsonObj: TlkJSONobject;
LIsPresent: Boolean;
LTransactiontypestr: String;
LStatus: Boolean;

LResponseobj: TlkJSONobject;

LBookTransactionsObj: TnsBookTransactions;


begin
{*
  Intent: This procedure is used to handle the borrowing of an available book.

  Calling functions:
   - AllValidationsforBorrowAndReturnBook (All the validations)
   - DeleteRecordOfBorrowAfterReturn (deleting record of borrow in BorrowTransactions Table after book is returned)
   - UpdateTransactionTable (add record of return in the UpdateTransactions table)
   - UpdateStatusOfBook (Update the status of book as checkedin in the database)

  Result: It processes the request to borrow a book and sends a response indicating success or failure.
*}

{*
  Logic:
   - Establish a database connection and initialize a BookTransactions object.
   - Parse the request content to extract the BookID.
   - Perform validations and checks:
     - Check if the BookID is provided and is a valid integer.
     - Validate if the user is logged in and is not an admin.
     - Perform additional validations using AllValidationsforBorrowAndReturnBook method.
   - Add a record of borrowing in the BorrowTransaction table.
   - Add a record in the UpdateTransaction table.
   - Update the checked-out status of the book.
   - Generate a success message with the due date to return the book.
   - Handle exceptions and send an appropriate error response if any validation fails or an error occurs during processing.
*}


//****************************************************************************************************************************
                                                            //revised code of return book        (tested okay)
  Self.EstDBConnection;
  LBookTransactionsObj:= TnsBookTransactions.Create(FMSConnection);
  LRequestJsonObj:= TlkJSON.parsetext(Request.Content) as TlkJSONobject;
  LRecivedBookId:= FieldValueByNameAs(LRequestJsonObj, 'BookID', jsNumber, 0, LIsPresent, True, True);
  LResponseobj:= TlkJSONobject.Create();
  try
    LTransactiontypestr:= 'checkedin';
    LStatus:= False;
    try
      // check if the recieved input type is other than integer
      if (LRecivedBookId = 0) then
      begin
        raise Exception.Create('Please provide the book id (number) for the book you want to borrow!');
        exit;
      end;

      //raise exception when admin or no one is loged in
      if not (ToValidateIfTypeIsUser(LCookieCheckInt, LTempCookievalStr, Request, Response, LResponseobj))then
      begin
        Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
        exit;
      end;

      // Validations
      LBookTransactionsObj.AllValidationsforBorrowAndReturnBook(LRecivedBookId, LCookieCheckInt, False);

      // delete the borrow record

      LBookTransactionsObj.DeleteRecordOfBorrowAfterReturn(LRecivedBookId, Response);

      //Add the record in UpdateTransaction table
      LBookTransactionsObj.UpdateTransactionTable(LTransactiontypestr, LRecivedBookId, LCookieCheckInt, Response);

      //UPDATE the checked out status of the book
      LBookTransactionsObj.UpdateStatusOfBook(LStatus, LRecivedBookId, Response);

      //success message for returning book
      LResponseobj.Add('success', True);
      LResponseobj.Add('message', 'yes book returned');
      Response.StatusCode := 200;
      Response.ContentType := 'application/json';
      Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;


    except on E:Exception do
    begin
      //Response.Content:= E.Message;
      LResponseobj.Add('success', False);
      LResponseobj.Add('message',E.Message );
      LResponseobj.Add('Status Code', 404);
      Response.StatusCode := 404;
      Response.ContentType := 'application/json';
      Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
      exit;
    end;
    end;

  finally
    LBookTransactionsObj.Free;
    LRequestJsonObj.Free;
    LResponseobj.Free;
  end;

end;

//----------------------------------------------------------------------------------------------------------
//                                             path-/category      to Get, Add and Edit Category        (tested okay)
procedure TWebModule1.WebModule1WebActionItem8Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  LResponseobj: TlkJSONobject;
  LBookManagement: TnsBookManagement;
  LCookieCheckInt: Integer;
  LTempCookievalStr: String;
  LResponseListVip: TlkJSONlist;
begin
{*
  Intent: This procedure handles requests to add and edit categories.

  Calling functions:
   - ToValidateIfTypeIsAdmin 
   - GetAllCategoryAsJSON
   - AddCategoryInDB
   - EditCategoryInDB


  Result: It adds or edits a category in the database and sends an appropriate response.
*}

{*
  Logic:
   - Establish a database connection.
   - Create an instance of TnsBookManagement to handle category operations.
   - Depending on the HTTP method type:
     - For GET requests:
       - Validate if the user is authenticated as admin.
       - Retrieve all categories from the database and send them as a JSON response.
     - For POST requests:
       - Validate if the user is authenticated as admin.
       - Call the AddCategoryInDB function to add a category to the database.
       - Send a success response if the category is added successfully.
     - For PUT requests:
       - Validate if the user is authenticated as admin.
       - Call the EditCategoryInDB function to edit a category in the database.
       - Send a success response if the category is edited successfully.
     - For other types of requests:
       - Send an "Unsupported HTTP method" response with status code 405.
*}

  Self.EstDBConnection;
  LBookManagement:= TnsBookManagement.Create(FMSConnection);
  LResponseobj:= TlkJSONobject.Create();
  try
    case Request.MethodType of
    mtGet:
      begin
        // Handle GET request
        //Response.Content := 'This is a GET request';
        LResponseListVip:= TlkJSONlist.Create;
        try
          try

            if not ToValidateIfTypeIsAdmin(LCookieCheckInt, LTempCookievalStr, Request, Response, LResponseobj) then
            begin
              Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
              exit;
            end;


            LBookManagement.GetAllCategoryAsJSON(LResponseListVip);

            Response.ContentType := 'application/json';
            Response.Content := TlkJSON.GenerateText(LResponseListVip);

          except on E:Exception do
          begin
            LResponseobj.Add('success', False);
            LResponseobj.Add('message',E.Message );
            LResponseobj.Add('Status Code', 401);
            Response.ContentType := 'application/json';
            Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;

            exit;
          end;
          end;
        finally
          LResponseListVip.Free;
        end;

      end;

    mtPost:
      begin
        // Handle POST request
        try
          if not ToValidateIfTypeIsAdmin(LCookieCheckInt, LTempCookievalStr, Request, Response, LResponseobj) then
          begin
            Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
            exit;
          end;

          //Calling Function to Add category in DB
          LBookManagement.AddCategoryInDB(Request, Response);

          LResponseobj.Add('success', True);
          LResponseobj.Add('message', 'Category Added Successfully!');
          Response.StatusCode := 200;
          Response.ContentType := 'application/json';
          Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;



        except on E:Exception do
        begin
          LResponseobj.Add('success', False);
          LResponseobj.Add('message',E.Message );
          LResponseobj.Add('Status Code', 401);
          Response.ContentType := 'application/json';
          Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;

          exit;
        end;
        end;
      end;

    mtPut:
      begin
        try
          //validation to check if admin is logged in
          if not ToValidateIfTypeIsAdmin(LCookieCheckInt, LTempCookievalStr, Request, Response, LResponseobj) then
          begin
            Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
           exit;
          end;

        //Calling function to edit category
        LBookManagement.EditCategoryInDB(Request, Response,LCookieCheckInt);

        //success message
        LResponseobj.Add('success', True);
        LResponseobj.Add('message', 'Category Edited Successfully!');
        Response.StatusCode := 200;
        Response.ContentType := 'application/json';
        Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;

        except on E:Exception do
        begin
          LResponseobj.Add('success', False);
          LResponseobj.Add('message',E.Message );
          LResponseobj.Add('Status Code', 401);
          Response.ContentType := 'application/json';
          Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
          exit;
        end;
        end;

      end;
    else
      begin
        // Handle other types of requests
        Response.Content := 'Unsupported HTTP method';
        Response.StatusCode := 405; // Method Not Allowed
      end;
  end;
  finally
    LResponseobj.Free;
    LBookManagement.Free;
  end;

end;


//---------------------------------------------------------------------------------------------------------
//                                           path- //transactionhistory  GET Transaction history
procedure TWebModule1.WebModule1GET_Transaction_historyAction(
  Sender: TObject; Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
LResponseListVip: TlkJSONlist;
LResponseobj: TlkJSONobject;
LTransactionManagementObj: TnsBookTransactions;
LTempCookievalStr: String;
LCookieCheckInt: Integer;



begin
{*
  Intent: This procedure handles the GET request to retrieve transaction history.
  Calling functions:
   - ToValidateIfTypeIsUser: Validates the user's authentication and type.
   - TnsBookTransactions.GetAllTransactionsAsJSON: Retrieves all transactions for the logged-in user.

  Result: Retrieves the transaction history for the logged-in user and returns it as JSON.
*}

{*
  Logic:
   - Establish a database connection.
   - Create an instance of TnsBookTransactions to manage book transactions.
   - Create JSON objects to store response data.
   - Validate user authentication and type using ToValidateIfTypeIsUser function.
   - If validation fails, return the response with an appropriate message.
   - Call GetAllTransactionsAsJSON to retrieve all transactions for the logged-in user.
   - Set the response status code and content type.
   - Generate JSON representation of the transaction list and send it in the response.
   - Handle any exceptions by returning an error response with the exception message.
*}

  Self.EstDBConnection;
  LTransactionManagementObj:= TnsBookTransactions.Create(FMSConnection);
  LResponseListVip:= TlkJSONlist.Create;
  LResponseobj:= TlkJSONobject.Create();


  
  try
    try
      //validation of user
      if not (ToValidateIfTypeIsUser(LCookieCheckInt, LTempCookievalStr, Request, Response, LResponseobj))then
      begin
        Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
        exit;
      end;

      // alling function to Get ALl Transactions done by the logged in user
      LTransactionManagementObj.GetAllTransactionsAsJSON(LResponseListVip, LCookieCheckInt);

      Response.StatusCode := 200;
      Response.ContentType := 'application/json';
      Response.Content:= TlkJSON.GenerateText(LResponseListVip as TlkJSONbase)

    except on E:Exception do
    begin
      //Response.Content:= E.Message;
      LResponseobj.Add('success', False);
      LResponseobj.Add('message',E.Message );
      LResponseobj.Add('Status Code', 401);
      Response.ContentType := 'application/json';
      Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
      exit;
    end;
    end;

  finally
    LResponseListVip.Free;
    LResponseobj.Free;
    LTransactionManagementObj.Free;
  end;

end;

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//                                                path - /edithistory  GET Edit transactions
procedure TWebModule1.WebModule1GET_Edit_HistoryAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);

var
LEditTransactionsObj: TnsBookTransactions;
LResponseobj: TlkJSONobject;
LResponseListVip: TlkJSONlist;
LCookieCheckInt: Integer;
LTempCookievalStr: String;
begin
{*
  Intent: This procedure handles the GET request for retrieving edit transactions.

  Calling functions:
   - ToValidateIfTypeIsAdmin
   - GetAllEditTransactionsAsJSON: Function to Get All Edits done to the book details

  Result: It returns a list of edit transactions in JSON format if the admin is logged in and authorized, otherwise returns an error response.
*}

{*
  Logic:
   - Establish a database connection.
   - Create an instance of TnsBookTransactions to handle book transactions.
   - Create JSON objects for the response.
   - Validate if the admin is logged in using ToValidateIfTypeIsAdmin function.
   - If the admin is not logged in or not authorized, return an error response.
   - Call GetAllEditTransactionsAsJSON to retrieve all edit transactions as JSON.
   - Set the response status code to 200 (OK) and content type to 'application/json'.
   - Generate JSON text for the response and send it.
   - If an exception occurs during execution, handle it by returning an error response with the exception message.
*}

  Self.EstDBConnection;
  LEditTransactionsObj := TnsBookTransactions.Create(FMSConnection);
  LResponseobj:= TlkJSONobject.Create();
  LResponseListVip:= TlkJSONlist.Create;
  try
    try
      //validation to check if admin is logged in
      if not ToValidateIfTypeIsAdmin(LCookieCheckInt, LTempCookievalStr, Request, Response, LResponseobj) then
      begin
        Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
        exit;
      end;

      //Calling Function to Get All Edits done to the book details
      LEditTransactionsObj.GetAllEditTransactionsAsJSON(LResponseListVip);

      // on success
      Response.StatusCode := 200;
      Response.ContentType := 'application/json';
      Response.Content:= TlkJSON.GenerateText(LResponseListVip as TlkJSONbase) ;


    except on E:Exception do
    begin
      LResponseobj.Add('success', False);
      LResponseobj.Add('message',E.Message);
      LResponseobj.Add('Status Code', 401);
      Response.ContentType := 'application/json';
      Response.Content:= TlkJSON.GenerateText(LResponseobj as TlkJSONbase) ;
      exit;
    end;
    end;

  finally
    LEditTransactionsObj.Free;
    LResponseobj.Free;
    LResponseListVip.Free;
  end;

end;

end.
