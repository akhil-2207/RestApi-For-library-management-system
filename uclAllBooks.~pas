unit uclAllBooks;
{
  Classes in this unit- TnsBookTransactions

  Purpose- To encapsulate all the functions related to the Book Transactions and Transaction History like
            Borrow Books, Return Books and to GET all Transaction History of particular user
}
interface
uses
SysUtils, Classes, HTTPApp , ULKJSON , IBODataset, uclDataSet, uclBaseDataset, uclInnerTechDataSet,
   MSAccess, StdCtrls, DB, SDEngine;

CONST
SELECT_QUERRY_TOFETH_ALLDETAILS_OFBOOK_USINGJOIN = 'SELECT Books.book_id, Books.book_title, Author.book_author, Category.book_category, Books.book_checkedout FROM Books JOIN Author ON Books.author_id = Author.author_id JOIN Category ON Books.category_id = Category.category_id';
SELECT_QUERRY_TOFETH_EMPTYDATASET_OFBOOK_TABLE = 'SELECT * FROM Books';
DEFAULT_VALUE_OFSTRING_FORVALIDATION ='';
DEFAULT_VALUE_OFINTEGER_FORVALIDATION =0;

type

  TnsBookManagement = class
  private
    FDataSet: TnsDataSet;
    FDataSet2:TnsDataSet;
    FDataSet3ForTitle: TnsDataSet;
    FDataSet4ForAuthor: TnsDataSet;
    FnsQuery1: TnsQuery;
    
    procedure LoadDataSet(p_Filter: string = ''; p_ForAddBook: boolean  = false);

    procedure LoadDataSetForCategory(p_Filter: String = ''; p_ForAddCategory: Boolean = false; p_ForEditCategory: Boolean = false);

    procedure LoadDataSetForBookSearch(LAuthorField: String; LCategoryField: String; LTitleField: String;
              p_Filter: string; p_ForTwoFieldFilter: Boolean = false);

    procedure LoadDataSetForAuthor(p_Filter: String = ''; p_ForAddAuthor: Boolean = false; p_ForEditAuthor: Boolean = false);

     // NOTE -edited for field input type from string to integer
    procedure InputFieldValidationToCheckIfEmptyAndCategoryExistOrNot(LAuthorField: Integer; LTitleField: String; LCategoryField: Integer; LIndex: Integer);

  public

    FMSConnection : TMSConnection;

    constructor Create(p_Connection: TMSConnection); reintroduce;

    destructor Destroy; override;

    function GetAllBooksAsJSON(LResponseListVip: TlkJSONlist; p_Filter: string = ''): tlkJSONList;

    function GetAllAuthorsAsJSON(LResponseListVip: TlkJSONlist): tlkJSONList;

    function GetAllCategoryAsJSON(LResponseListVip: TlkJSONlist): tlkJSONList;

    function GetFilterSearchedBooksAsJSONList(LAuthorField: String; LCategoryField: String; LTitleField: String; LResponseListVip: TlkJSONlist): TlkJSONlist;

    procedure AddBookInDB(Request: TWebRequest; Response: TWebResponse);

    procedure AddCategoryInDB(Request: TWebRequest; Response: TWebResponse);

    procedure AddAuthorinDB(Request: TWebRequest; Response: TWebResponse);

    procedure EditCategoryInDB(Request: TWebRequest; Response: TWebResponse; LCookieCheckInt: Integer);

    procedure EditAuthorInDB(Request: TWebRequest; Response: TWebResponse; LCookieCheckInt: Integer);

    procedure AddDetailsOfEachBookinListNew(LResponseObjVip: TlkJSONobject;LTempTitleField: TField; LTempAuthorField: TField;
                       LTempIDField: TField; LTempCategoryField: TField; LTempCheckedoutField: TField; LResponseListVip: TlkJSONlist);
  end;//

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

implementation
uses
uclutils;

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------

{ TnsBookManagement }

constructor TnsBookManagement.Create(p_Connection: TMSConnection);

begin
{*
  Intent: This constructor initializes a TnsBookManagement object with the provided database connection.

  Parameters:
    - p_Connection: The database connection used to interact with the database.

  Result: It initializes the TnsBookManagement object with the database connection and sets up datasets for Books, Category, Author tables.
*}

{*
  Logic:
   - Assign the provided database connection to FMSConnection property.
   - Create and configure dataset for the Books table.
   - Set the update table name to 'Books' and key fields to 'book_id'.
   - Create and configure dataset for the Category table.
   - Set the update table name to 'Category' and key fields to 'category_id'.
   - Create and configure dataset for the Author table.
   - Set the update table name to 'Author' and key fields to 'author_id'.
   - Create a query object for additional database operations.
*}

  FMSConnection:= p_Connection;

  FDataSet := TnsDataset.create(nil);
  FDataSet.Connection:= FMSConnection;

  //FDataSet.UpdateTableName:= 'AllBooks';
  //changed for id fied functions
  FDataSet.UpdateTableName:= 'Books';
  FDataSet.KeyFields:='book_id';

  FDataSet2 := TnsDataset.create(nil);
  FDataSet2.Connection:= FMSConnection;
  FDataSet2.UpdateTableName:= 'Category';
  FDataSet2.KeyFields:='category_id';

  FDataSet3ForTitle := TnsDataset.create(nil);
  FDataSet3ForTitle.Connection:= FMSConnection;
  FDataSet3ForTitle.UpdateTableName:= 'Books';
  FDataSet3ForTitle.KeyFields:='book_title';

  FDataSet4ForAuthor:= TnsDataSet.Create(nil);
  FDataSet4ForAuthor.Connection:= FMSConnection;
  FDataSet4ForAuthor.UpdateTableName:= 'Author';
  FDataSet4ForAuthor.KeyFields:='author_id';


  FnsQuery1 := TnsQuery.Create(Nil);
  FnsQuery1.Connection := FmsConnection;

end;
//-----------------------------------------------------------------------------------
destructor TnsBookManagement.Destroy;
begin
  FreeAndNil(FDataSet);
  FreeAndNil(FDataSet2);
  FreeAndNil(FDataSet3ForTitle);
  FreeAndNil(FnsQuery1);

  inherited;
end;

//----------------------------------------------------------------------------------------
//                                     Loading Dataset for Adding books or Get Details of book and Get title of books
procedure TnsBookManagement.LoadDataSet(p_Filter: string; p_ForAddBook: boolean);
var
  LSQL: string;
begin
{*
  Intent: This procedure is used to load a dataset with book records based on specified criteria.

  Parameters:
    - p_Filter: Optional filter criteria to apply to the dataset.
    - p_ForAddBook: Specifies whether the dataset is being loaded for adding a new book (Boolean).

  Result: It loads the dataset with book records based on the provided criteria.
*}

{*
  Logic:
   - Construct the SQL query to fetch all details of books using a join operation.
   - If p_ForAddBook is True and p_Filter is empty, construct a SQL query to fetch an empty dataset of the book table.
   - If p_Filter is not empty, construct a SQL query to fetch an empty dataset of the book table filtered by the book title.
   - Open the dataset with the constructed SQL query.
*}
  LSQL := SELECT_QUERRY_TOFETH_ALLDETAILS_OFBOOK_USINGJOIN ;

  if (p_ForAddBook)and (p_Filter = '') then
  begin
    LSQL := SELECT_QUERRY_TOFETH_EMPTYDATASET_OFBOOK_TABLE;
    LSQL := LSQL + ' WHERE book_id = -1';
  end
  else if p_Filter <> '' then
  begin
    LSQL:= SELECT_QUERRY_TOFETH_EMPTYDATASET_OFBOOK_TABLE;
    LSql := LSql + ' WHERE book_title= '''+p_Filter+''' ';
    FDataSet3ForTitle.SQLSelect:= LSQL;
    FDataSet3ForTitle.Open;
  end;

  FDataSet.SQLSelect:= LSQL;
  FDataSet.Open;
  
end;
//------------------------------------------------------------------------------------------------
//                                              Loading dataset for Category
procedure TnsBookManagement.LoadDataSetForCategory(p_Filter: string = ''; p_ForAddCategory: boolean = false; p_ForEditCategory: Boolean = false);
var
  LSQL: string;
begin
{*
  Intent: This procedure is used to load a dataset for the Category table based on specified criteria.

  Parameters:
    - p_Filter: Optional filter criteria to apply to the dataset.
    - p_ForAddCategory: Specifies whether the dataset is being loaded for adding a new category.
    - p_ForEditCategory: Specifies whether the dataset is being loaded for editing a category.

  Result: It loads the dataset with category records based on the provided criteria.
*}

{*
  Logic:
   - Close the dataset to prepare for loading a new dataset.
   - Construct the SQL query to select all fields from the Category table.
   - If p_Filter is provided and p_ForAddCategory is True and p_ForEditCategory is False, 
     append a WHERE clause to the SQL query to filter by book_category.
   - If p_Filter is provided and p_ForAddCategory is False and p_ForEditCategory is False, 
     append a WHERE clause to the SQL query to filter by category_id.
   - If p_ForAddCategory is True and p_Filter is empty, append a WHERE clause to the SQL query to select no records.
   - If p_ForEditCategory is True and p_Filter is provided, append a WHERE clause to the SQL query to filter by book_category.
   - Open the dataset with the constructed SQL query.
*}
  FDataSet2.Close;
  LSQL := 'SELECT * FROM Category ';
  FDataSet2.SqlSelect := LSql;

  // used when adding new category and simultaneously check if category already exist
   if (p_Filter <> '')and (p_ForAddCategory = True)and (p_ForEditCategory = false) then
  begin
    LSQL:= LSQL + ' WHERE book_category = (:p_val1)';
    FDataSet2.SqlSelect := LSql;
    FDataSet2.CreateParamVariables;
    FDataSet2.ParamByName('p_val1').AsString := p_Filter ;
  end;

  //used to feth category name from category id
  if (p_Filter <> '')and (p_ForAddCategory = false)and (p_ForEditCategory = false) then
  begin

    LSQL := LSql + ' WHERE category_id = '+p_Filter;
    FDataSet2.SqlSelect := LSql;
  end;

  // used when adding category, to open empty dataset
  if (p_ForAddCategory)and (p_Filter = '')and (p_ForAddCategory = false) then
  begin
    LSQL:= LSQL + ' WHERE category_id = -1 ';
    FDataSet2.SqlSelect := LSql;
  end;


  //used to check if  new category already exist when edititng
  if (p_ForEditCategory) and (p_Filter <> '') and (p_ForAddCategory = false) then
  begin
    LSQL:= LSQL + 'WHERE book_category = (:p_val1)';
    FDataSet2.SqlSelect := LSql;
    FDataSet2.CreateParamVariables;
    FDataSet2.ParamByName('p_val1').AsString := p_Filter ; 
  end;

  FDataSet2.Open;
end;

//-----------------------------------------------------------------------------------------------------------------------------------------------
//                                                      loading dataset for authors
procedure TnsBookManagement.LoadDataSetForAuthor(p_Filter: string = ''; p_ForAddAuthor: boolean = false; p_ForEditAuthor: Boolean = false);
var
LSQL: String;
begin
{*
  Intent: This procedure is used to load a dataset for authors based on specified criteria.

  Parameters:
    - p_Filter: Optional filter criteria to apply to the dataset.
    - p_ForAddAuthor: Specifies whether the dataset is being loaded for adding a new author.
    - p_ForEditAuthor: Specifies whether the dataset is being loaded for editing an existing author.

  Calling functions:
   - Not specified

  Result: It loads the dataset for authors based on the provided criteria.
*}

{*
  Logic:
   - Close the dataset to prepare for loading a new dataset.
   - Construct the SQL query to select all fields from the Author table.
   - If p_Filter is provided and p_ForAddAuthor and p_ForEditAuthor are both false, append a WHERE clause to the SQL query to filter by author_id.
   - If p_Filter is provided and p_ForAddAuthor is true, append a WHERE clause to the SQL query to filter by book_author.
   - If p_ForAddAuthor is true and p_Filter is not provided, append a WHERE clause to the SQL query to select no records (for preparing to add a new author).
   - If p_ForEditAuthor is true and p_Filter is provided, append a WHERE clause to the SQL query to filter by book_author for editing an existing author.
   - Open the dataset with the constructed SQL query.
*}

  FDataSet4ForAuthor.Close;
  LSQL := 'SELECT * FROM Author';
  FDataSet4ForAuthor.SqlSelect := LSql;

  //used to store the old name of the author
  if (p_Filter <> '')and (p_ForAddAuthor = false)and (p_ForEditAuthor = false) then
  begin

    LSQL := LSql + ' WHERE author_id = ' +p_Filter;
    FDataSet4ForAuthor.SqlSelect := LSql;
  end;


  if (p_Filter <> '')and (p_ForAddAuthor = true)and (p_ForEditAuthor = false) then
  begin

    LSQL := LSql + ' WHERE book_author = (:p_val1)';
    FDataSet4ForAuthor.SqlSelect := LSql;
    FDataSet4ForAuthor.CreateParamVariables;
    FDataSet4ForAuthor.ParamByName('p_val1').AsString := p_Filter ;
  end;

  if (p_ForAddAuthor)and (p_Filter = '')and (p_ForEditAuthor = false) then
  begin

    LSQL:= LSQL + ' WHERE author_id = -1 ';
    FDataSet4ForAuthor.SqlSelect := LSql;
  end;

  //used to check if  new author already exist
  if (p_ForEditAuthor) and (p_Filter <> '')and (p_ForAddAuthor = false) then
  begin

    LSQL:= LSQL + 'WHERE book_author = (:p_val1)';
    FDataSet4ForAuthor.SqlSelect := LSql;
    FDataSet4ForAuthor.CreateParamVariables;
    FDataSet4ForAuthor.ParamByName('p_val1').AsString := p_Filter ;
  end;

  FDataSet4ForAuthor.Open;
end;

//---------------------------------------------------------------------------------------------------------------
//                                                       Load dataset for Filtered Book Search
procedure TnsBookManagement.LoadDataSetForBookSearch(LAuthorField: String; LCategoryField: String; LTitleField: String ;p_Filter: string; p_ForTwoFieldFilter: boolean = false);
var
  LSQL: string;
begin
{*
  Intent: This procedure is used to load a dataset for filtered book search based on specified criteria.

  Parameters:
    - LAuthorField: The author field value to filter the dataset.
    - LCategoryField: The category field value to filter the dataset.
    - LTitleField: The title field value to filter the dataset.
    - p_Filter: The filter string with statement after WHERE clause to apply to the dataset.
    - p_ForTwoFieldFilter: Specifies whether the dataset is being filtered based on two fields.

  Calling functions:
   - Not specified

  Result: It loads the dataset with book records based on the provided criteria.
*}

{*
  Logic:
   - Construct the SQL query to retrieve all details of books using a join operation.
   - Based on the specified criteria and filter, modify the SQL query accordingly.
   - If p_ForTwoFieldFilter is True and both LAuthorField and LCategoryField are provided, apply a filter with both fields.
   - If LAuthorField is provided and LTitleField and LCategoryField are not, apply a filter with the author field.
   - If LTitleField is provided and LAuthorField and LCategoryField are not, apply a filter with the title field.
   - If LCategoryField is provided and LAuthorField and LTitleField are not, apply a filter with the category field.
   - Open the dataset with the constructed SQL query.
*}


  LSQL:=SELECT_QUERRY_TOFETH_ALLDETAILS_OFBOOK_USINGJOIN;
  if (p_ForTwoFieldFilter)and(LCategoryField <> '')and(LAuthorField<>'')and (LTitleField = '') then
  begin
    LSql := LSql + ' WHERE ' + p_Filter;
    FDataSet.SqlSelect := LSQL;
    FDataSet.CreateParamVariables;
    FDataSet.ParamByName('p_val1').AsString := '%'+ LAuthorField +'%' ;
    FDataSet.ParamByName('p_val2').AsString :=  LCategoryField ;
  //end
  end;

  if (LAuthorField <> '')and (LTitleField = '')and (LCategoryField = '')and(p_ForTwoFieldFilter = false) then
  begin
    LSql := LSql + ' WHERE ' + p_Filter;
    FDataSet.SqlSelect := LSQL;
    FDataSet.CreateParamVariables;
    FDataSet.ParamByName('p_val1').AsString := '%' + LAuthorField + '%' ;
  end;

  if (LTitleField <> '')and (LAuthorField = '')and (LCategoryField = '')and(p_ForTwoFieldFilter = false) then
  begin
    LSql := LSql + ' WHERE ' + p_Filter;
    FDataSet.SqlSelect := LSQL;
    FDataSet.CreateParamVariables;
    FDataSet.ParamByName('p_val1').AsString := '%' + LTitleField + '%' ;
  end;

  if (LCategoryField <> '')and (LAuthorField = '')and(LTitleField = '')and(p_ForTwoFieldFilter = false) then
  begin
    LSql := LSql + ' WHERE ' + p_Filter;
    FDataSet.SqlSelect := LSQL;
    FDataSet.CreateParamVariables;
    FDataSet.ParamByName('p_val1').AsString :=  LCategoryField ;
  end;

  FDataSet.SqlSelect := LSQL;
  FDataSet.Open;
  
end;

//----------------------------------------------------------------------------------------------------------
//                                function to validate the input given by user for adding books

procedure TnsBookManagement.InputFieldValidationToCheckIfEmptyAndCategoryExistOrNot(LAuthorField: Integer; LTitleField: String; LCategoryField: Integer; LIndex: Integer);

begin
{*
  Intent: This procedure validates the input provided by the user for adding books.

  Parameters:
   - LAuthorField: The author field value to filter the dataset.
   - LCategoryField: The category field value to filter the dataset.
   - LTitleField: The title field value to filter the dataset.

  Calling functions:
   - LoadDataSetForCategory
   - LoadDataSetForAuthor
   - LoadDataSet

  Result: It raises an exception if any of the input fields are invalid or if the category, author, or title already exists in the library.
*}

{*
  Logic:
   - Check if the title field is empty. If empty, raise an exception indicating invalid input.
   - Check if the author field is zero. If zero, raise an exception indicating invalid input.
   - Check if the category field is zero. If zero, raise an exception indicating invalid input.
   - Load the dataset with the input category and check if it exists in the category table. If not, raise an exception.
   - Load the dataset with the input author and check if it exists. If not, raise an exception.
   - Load the dataset with the input title and check if it already exists in the library. If yes, raise an exception.
*}


    if(LTitleField = DEFAULT_VALUE_OFSTRING_FORVALIDATION) then
    begin
      //Response.Content:= 'Invalid input in title field of '+IntToStr(LIndex)+'item in the list';
      raise Exception.Create('An error occurred: Invalid input in title field of '
            +IntToStr(LIndex)+' item in the list, please enter only string type in the field, books till'+IntToStr(LIndex)+' Added');

    end;

    if(LAuthorField = DEFAULT_VALUE_OFINTEGER_FORVALIDATION) then
    begin
    //Response.Content:= 'Invalid input in author field of '+IntToStr(LIndex)+'item in the list';
      raise Exception.Create('An error occurred: Invalid input in author field of '
            +IntToStr(LIndex)+' item in the list, please enter only integer type in the field, books till'+IntToStr(LIndex)+' Added');

    end;

    if(LCategoryField = DEFAULT_VALUE_OFINTEGER_FORVALIDATION) then
    begin
      //Response.Content:= 'Invalid input in category field of '+IntToStr(LIndex)+'item in the list';
      raise Exception.Create('An error occurred: Invalid input in category field of '
            +IntToStr(LIndex)+' item in the list, please enter only integer type in the field, books till'+IntToStr(LIndex)+' Added');
    end;

    //Loading Dataset With Input category
    self.LoadDataSetForCategory(IntToStr(LCategoryField), false, false);
    //Check if category input by user exist in category table or not
    if (FDataSet2.RecordCount <> 1) then
    begin
      raise Exception.Create('An error occurred: This is not a valid category at '
            +IntToStr(LIndex)+' all the books above this are added, please check categories first');
    end;

    Self.LoadDataSetForAuthor(IntToStr(LAuthorField),False,False);
    // check if author exist or not
    if (FDataSet4ForAuthor.RecordCount <> 1) then
    begin
      raise Exception.Create('An error occurred: This is not a valid author at '
            +IntToStr(LIndex)+' all the books above this are added, please check authors list first');
    end;

    self.LoadDataSet(LTitleField,false);
    //Check if title input by user already exist in the library or not
    if (FDataSet3ForTitle.RecordCount <> 0) then
    begin
      raise Exception.Create('An error occurred: at ' +IntToStr(LIndex)+ ' entry, Book with this title already exist in library cannot add more than one book, all the books above this are added');
    end;

end;

//----------------------------------------------------------------------------------------------------------------------------------------------
//                                                          function to GET all Authors
function TnsBookManagement.GetAllAuthorsAsJSON(LResponseListVip: TlkJSONlist): tlkJSONList;
var
//LAvailablestatus: String;
LResponseObjVip: TlkJSONobject;
LTempAuthorIDField: TField;
LTempAuthornameField: TField;

begin
{*
  Intent: This function retrieves all authors from the database and returns them as JSON.

  Parameters:
   - LResponseListVip: The JSON list object to store the transaction data.

  Calling functions:
   - Not specified

  Result: It returns a JSON array containing all authors.
*}

{*
  Logic:
   - Load the dataset with all authors from the database.
   - Iterate through each record in the dataset.
   - Create a JSON object for each author, containing the author ID and name.
   - Add the JSON object to a JSON List.
   - If no authors are found in the dataset, raise an exception.
   - Return the JSON List containing all authors.
*}

  Self.LoadDataSetForAuthor('', false,false);
  FDataSet4ForAuthor.First;

  LTempAuthorIDField:= FDataSet4ForAuthor.FieldByName('author_id');
  LTempAuthornameField:= FDataSet4ForAuthor.FieldByName('book_author');

  while not FDataSet4ForAuthor.Eof do
  begin
    LResponseObjVip:= TlkJSONobject.Create();

    LResponseObjVip.Add('Author ID: ',LTempAuthorIDField.AsString);
    LResponseObjVip.Add('Author Name: ',LTempAuthornameField.AsString);

    LResponseListVip.Add(LResponseObjVip);
    FDataSet4ForAuthor.Next;

  end;
  if (LResponseListVip.Count = 0) then
  begin
    raise Exception.Create('No authors Found');
  end;

  Result:= LResponseListVip;

end;

//--------------------------------------------------------------------------------------------------------------------------------
//                                                      function to add details in book
procedure TnsBookManagement.AddDetailsOfEachBookinListNew(LResponseObjVip: TlkJSONobject;LTempTitleField: TField; LTempAuthorField: TField;
          LTempIDField: TField; LTempCategoryField: TField; LTempCheckedoutField: TField; LResponseListVip: TlkJSONlist);
var
LAvailablestatus: String;
begin
{*
  Intent: This procedure is used to add details of each book to a JSON object and append it to a JSON list.

  Parameters:
    - LResponseObjVip: The JSON object to which book details are added.
    - LTempTitleField: The title field of the book.
    - LTempAuthorField: The author field of the book.
    - LTempIDField: The unique identifier field of the book.
    - LTempCategoryField: The category field of the book.
    - LTempCheckedoutField: The checked-out status field of the book.
    - LResponseListVip: The JSON list to which the response object is appended.

*}

{*
  Logic:
   - Add the title, author, ID, and category fields of the book to the response JSON object.
   - Determine the availability status of the book based on the checked-out field.
   - If the book is not checked out, set the availability status to "Available in Library".
   - If the book is checked out, set the availability status to "Not Available".
   - Add the availability status to the response JSON object.
   - Append the response JSON object to the response JSON list.
*}

  LResponseObjVip.Add('Title :',LTempTitleField.AsString);
  LResponseObjVip.Add('Author:',LTempAuthorField.AsString);
  LResponseObjVip.Add('ID:',LTempIDField.AsInteger);
  LResponseObjVip.Add('Category:',LTempCategoryField.AsString);

  if not LTempCheckedoutField.AsBoolean then
  begin
    LAvailablestatus:= 'Available in Library';
  end
  else
  begin
    LAvailablestatus:= 'Not Available';
  end;
  LResponseObjVip.Add('Avaiibility',LAvailablestatus);
  LResponseListVip.Add(LResponseObjVip);
end;

//-------------------------------------------------------------------------------------------------
//                                                     function to add books
procedure TnsBookManagement.AddBookInDB;
var
LRequestList: TlkJSONlist;
LJSONobj: TlkJSONobject;
LAuthorField: Integer;
LTitleField: String;
LCategoryField: Integer;
LCheckedOutField: Boolean;
LIndex: Integer;
LIsPresent: Boolean;

begin
{*
  Intent: This procedure is used to add books to the database.

  Calling functions:
   - LoadDataSet: Loads an empty dataset in preparation for adding books.

  Result: It adds books to the database if all validations are correct.
*}

{*
  Logic:
   - Load an empty dataset to prepare for adding books.
   - Parse the request content to extract book details.
   - Iterate through each book in the request list.
   - Extract author, title, and category fields from the JSON object.
   - Validate the input fields and check if the category exists.
   - Add book details to the dataset and post the changes.
   - Set the book_checkedout field to False for each book.
*}

  //Callinf function to load empty dataset
  self.LoadDataSet('', true);
  LRequestList:= TlkJSON.parsetext(Request.Content) as TlkJSONlist;

  for LIndex:= 0 to LRequestList.Count-1 do
  begin

    LJSONobj:= LRequestList.Child[LIndex] as TlkJSONobject;
    LAuthorField:= FieldValueByNameAs(LJSONobj, 'Author ID', jsNumber, DEFAULT_VALUE_OFINTEGER_FORVALIDATION, LIsPresent, True, True);
    LTitleField:= FieldValueByNameAs(LJSONobj, 'Title', jsString, DEFAULT_VALUE_OFSTRING_FORVALIDATION, LIsPresent, True, True);
    LCategoryField:= FieldValueByNameAs(LJSONobj, 'Category ID', jsNumber, DEFAULT_VALUE_OFINTEGER_FORVALIDATION, LIsPresent, True, True);

    // fuction for validation of input fields to check whether they are empty
    if (LJSONobj=nil) then
    begin
      raise Exception.Create('Please fill value in all the fields');
    end;

    if LJSONobj.SelfType <> jsObject then
    Raise Exception.Create('Invalid JSON Error from defensive check of ');

    //also checks if the input category field is valid and present in the category table
    self.InputFieldValidationToCheckIfEmptyAndCategoryExistOrNot(LAuthorField, LTitleField, LCategoryField, LIndex );

    //initialize the checkedout status of book to be added as false
    LCheckedOutField:= False;

    //Add the details of book in the dataset and then post
    FDataSet.Insert;
    FDataSet.FieldByName('book_title').AsString:= CapitalizeFirstLetter(LTitleField);
    FDataSet.FieldByName('author_id').AsInteger:= LAuthorField;
    FDataSet.FieldByName('category_id').AsInteger:= LCategoryField;
    FDataSet.FieldByName('book_checkedout').Asboolean:= LCheckedOutField;
    FDataSet.Post;

  end;

end;

//----------------------------------------------------------------------------------------------

//                                                 function to get all book details
function TnsBookManagement.GetAllBooksAsJSON(LResponseListVip: TlkJSONlist; p_Filter: string = ''): tlkJSONList;
var
//LAvailablestatus: String;
LResponseObjVip: TlkJSONobject;

LTempTitleField: TField;
LTempAuthorField: TField;
LTempIDField: TField;
LTempCategoryField: TField;
LTempCheckedoutField: TField;
begin
{*
  Intent: This function is used to retrieve all book details in JSON format.

  Parameters:
    - LResponseListVip: The JSON list object to store the book details.
    - p_Filter: Optional filter criteria to apply to the dataset.

  Calling functions:
   - LoadDataSet procedure
   - AddDetailsOfEachBookinListNew function - to add details of the books in the list.

  Result: It returns a JSON list containing all book details.
*}

{*
  Logic:
   - Load the dataset with all book records.
   - Check if the dataset contains any records. If not, raise an exception.
   - Iterate through each record in the dataset.
   - Retrieve the book details (title, author, ID, category, checked-out status) from the dataset fields.
   - Create a JSON object for each book and add its details to the JSON list.
   - Return the JSON list containing all book details.
*}

  //Loading dataset with all the book details
  Self.LoadDataSet('', false);

  //Check If table contains any record or not
  if FDataSet.RecordCount = 0 then
    raise Exception.Create('No data of books found in Library!');


  FDataSet.First;
  LTempTitleField:= FDataSet.FieldByName('book_title');
  LTempAuthorField:= FDataSet.FieldByName('book_author');
  LTempIDField:= FDataSet.FieldByName('book_id');
  LTempCategoryField:= FDataSet.FieldByName('book_category');
  LTempCheckedoutField:= FDataSet.FieldByName('book_checkedout');

  while not FDataSet.Eof do
  begin
    LResponseObjVip:= TlkJSONobject.Create();
    //calling function to add details of book in the JSON list
    AddDetailsOfEachBookinListNew(LResponseObjVip,LTempTitleField, LTempAuthorField, LTempIDField, LTempCategoryField, LTempCheckedoutField , LResponseListVip);
    FDataSet.Next;

  end;

  Result:= LResponseListVip;

end;

//------------------------------------------------------------------------------------------------------------------------------------------------------------
//                                   function to return list of book details according to applied filter

function TnsBookManagement.GetFilterSearchedBooksAsJSONList(LAuthorField: String; LCategoryField: String; LTitleField: String; LResponseListVip: TlkJSONlist): TlkJSONlist;
var

LFilterstr: String;
LResponseObjVip: TlkJSONobject;
LTempTitleField: TField;
LTempAuthorField: TField;
LTempIDField: TField;
LTempCategoryField: TField;
LTempCheckedoutField: TField;


begin
{*
  Intent: This function returns a list of book details according to the applied filter.

  Parameters:
    - LAuthorField: The author's name to filter the books.
    - LCategoryField: The category to filter the books.
    - LTitleField: The title of the book to filter the books.
    - LResponseListVip: The JSON list to store the book details.

  Calling functions:
   - LoadDataSetForBookSearch
   - AddDetailsOfEachBookinListNew

  Result: It returns a JSON list containing book details based on the applied filter.
*}

{*
  Logic:
   - Check the filter criteria to determine how to construct the filter string.
   - Load the dataset for book search based on the filter criteria.
   - Iterate over the dataset records and add book details to the JSON list.
   - Raise an exception if no records are found for the applied filter.
*}

  //Filter only with respect to name of Author
  if(LTitleField = '')and(LCategoryField = '')and(LAuthorField <> '') then
  begin
    LFilterstr:= 'book_author LIKE (:p_val1)';

    Self.LoadDataSetForBookSearch(LAuthorField,LCategoryField,LTitleField,LFilterstr,false);

    LTempTitleField:= FDataSet.FieldByName('book_title');
    LTempAuthorField:= FDataSet.FieldByName('book_author');
    LTempIDField:= FDataSet.FieldByName('book_id');
    LTempCategoryField:= FDataSet.FieldByName('book_category');
    LTempCheckedoutField:= FDataSet.FieldByName('book_checkedout');
    FDataSet.First;

    //Loop to add JSONobjects in JSONlist
    while not FDataSet.Eof do
    begin
      LResponseObjVip:= TlkJSONobject.Create();
      self.AddDetailsOfEachBookinListNew(LResponseObjVip,LTempTitleField, LTempAuthorField, LTempIDField, LTempCategoryField, LTempCheckedoutField , LResponseListVip);

      FDataSet.Next;
    end;

    //checking if any books details of particular filter are added in list, only returning list when book  details added
    if(LResponseListVip.Count >0) then
       Result:=LResponseListVip
    else
      Raise Exception.Create('Author Not Found');
  end;

  //Filter only with respect to  Title of Book
  if(LTitleField <> '')and(LCategoryField = '')and(LAuthorField = '') then
  begin
    LFilterstr:= 'book_title LIKE (:p_val1)';
    Self.LoadDataSetForBookSearch(LAuthorField,LCategoryField,LTitleField,LFilterstr,false);

    LTempTitleField:= FDataSet.FieldByName('book_title');
    LTempAuthorField:= FDataSet.FieldByName('book_author');
    LTempIDField:= FDataSet.FieldByName('book_id');
    LTempCategoryField:= FDataSet.FieldByName('book_category');
    LTempCheckedoutField:= FDataSet.FieldByName('book_checkedout');

    FDataSet.First;

    //checking if and record found because even if not found empty data set is loaded because of using (LIKE= %%) in querry
    if FDataSet.RecordCount = 0 then
    begin
      Raise Exception.Create('Title Not Found');
    end;

    while not FDataSet.Eof do
    begin
      LResponseObjVip:= TlkJSONobject.Create();
      //AddDetailsOfEachBookinList(LResponseObjVip, FDataSet, LResponseListVip);
      self.AddDetailsOfEachBookinListNew(LResponseObjVip,LTempTitleField, LTempAuthorField, LTempIDField, LTempCategoryField, LTempCheckedoutField , LResponseListVip);
      FDataSet.Next;
    end;

    if(LResponseListVip.Count >0) then
       Result:=LResponseListVip
    else
      Raise Exception.Create('Title Not Found');
  end;

  //Filter only with respect to Category
  if(LTitleField = '')and(LCategoryField <> '')and(LAuthorField = '') then
  begin

    LFilterstr:= 'book_category =(:p_val1)';
    Self.LoadDataSetForBookSearch(LAuthorField,LCategoryField,LTitleField,LFilterstr,false);

    LTempTitleField:= FDataSet.FieldByName('book_title');
    LTempAuthorField:= FDataSet.FieldByName('book_author');
    LTempIDField:= FDataSet.FieldByName('book_id');
    LTempCategoryField:= FDataSet.FieldByName('book_category');
    LTempCheckedoutField:= FDataSet.FieldByName('book_checkedout');

    FDataSet.First;

    //checking if and record found because even if not found empty data set is loaded because of using (LIKE= %%) in querry
    if FDataSet.RecordCount = 0 then
    begin
      Raise Exception.Create('Category Not Found');
    end;

    while not FDataSet.Eof do
    begin
      LResponseObjVip:= TlkJSONobject.Create();
      //AddDetailsOfEachBookinList(LResponseObjVip, FDataSet, LResponseListVip);
      self.AddDetailsOfEachBookinListNew(LResponseObjVip,LTempTitleField, LTempAuthorField, LTempIDField, LTempCategoryField, LTempCheckedoutField , LResponseListVip);
      FDataSet.Next;
    end;

    if(LResponseListVip.Count >0) then
       Result:=LResponseListVip
    else
      Raise Exception.Create('Category Not Found');
  end;

  //condition to filter books with respect to author and category both
  if (LTitleField = '')and(LCategoryField <> '')and(LAuthorField <> '') then
  begin

    LFilterstr:= 'book_author LIKE (:p_val1) AND book_category = (:p_val2)';
    Self.LoadDataSetForBookSearch(LAuthorField,LCategoryField,LTitleField,LFilterstr,true);

    LTempTitleField:= FDataSet.FieldByName('book_title');
    LTempAuthorField:= FDataSet.FieldByName('book_author');
    LTempIDField:= FDataSet.FieldByName('book_id');
    LTempCategoryField:= FDataSet.FieldByName('book_category');
    LTempCheckedoutField:= FDataSet.FieldByName('book_checkedout');

    FDataSet.First;

    //checking if and record found because even if not found empty data set is loaded because of using (LIKE= %%) in querry
    if FDataSet.RecordCount = 0 then
    begin
      Raise Exception.Create('Book by this author of the given category not found!');
    end;

    while not FDataSet.Eof do
    begin
      LResponseObjVip:= TlkJSONobject.Create();
      //AddDetailsOfEachBookinList(LResponseObjVip, FDataSet, LResponseListVip);
      self.AddDetailsOfEachBookinListNew(LResponseObjVip,LTempTitleField, LTempAuthorField, LTempIDField, LTempCategoryField, LTempCheckedoutField , LResponseListVip); 
      FDataSet.Next;
    end;
    if(LResponseListVip.Count >0) then
       Result:=LResponseListVip
    else
      Raise Exception.Create('Book by this author of the given category not found!');
  end;

end;

//---------------------------------------------------------------------------------------------------------------------------------------------------------
//                                                       function to add category
procedure TnsBookManagement.AddCategoryInDB(Request: TWebRequest; Response: TWebResponse);
var
LRequestObj: TlkJSONobject;
LCategoryField: String;
LIsPresent: Boolean;
begin
{*
  Intent: This procedure is used to add a new category to the database.

  Parameters:
    - Request: The web request object containing the category details.
    - Response: The web response object to handle success or error.

  Calling functions:
   - LoadDataSetForCategory

  Result: It adds the new category to the database if it doesn't already exist, otherwise raises an error.
*}

{*
  Logic:
   - Parse the request content to extract the category field value.
   - Check if the category field is provided in the request.
   - Validate that the category field is not empty.
   - Load a dataset to check if the category already exists in the database.
   - If the category already exists, raise an exception.
   - Otherwise, load an empty dataset and insert the new category into the database.
*}

  LRequestObj:= TlkJSON.parsetext(Request.Content) as TlkJSONobject;
  try
    LCategoryField:= FieldValueByNameAs(LRequestObj, 'Category', jsString,'', LIsPresent, True, True);

    if (LCategoryField = '') then
    begin
      raise Exception.Create('Please provide input for the category field in text format only!');
    end;

    // check if category already exist
    Self.LoadDataSetForCategory(LCategoryField, true, false);

    if (FDataSet2.RecordCount <> 0) then
    begin
      raise Exception.Create('Category Already Exist');
    end;

    //Loading empty datset to insert new category
    Self.LoadDataSetForCategory('', True, false);
    FDataSet2.Insert;
    FDataSet2.FieldByName('book_category').AsString:= CapitalizeFirstLetter(LCategoryField) ;
    FDataSet2.Post;
  finally
    LRequestObj.Free;
  end;
end;

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//                                                                  function to edit category
procedure TnsBookManagement.EditCategoryInDB(Request: TWebRequest; Response: TWebResponse; LCookieCheckInt: Integer);
var
LOldCategoryValuestr: String;
LNewCategoryValuestr: String;
LCategoryIDint: Integer;
LRequestObj: TlkJSONobject;
LIsPresent: Boolean;

begin
{*
  Intent: This procedure is used to edit a category in the database.

  Parameters:
    - Request: The request object containing category edit details.
    - Response: The response object to handle success or error.
    - LCookieCheckInt: The integer value of the cookie to check seller authenticity.

  Calling functions:
   - LoadDataSetForCategory 

  Result: It edits the category in the database if all validations are correct else raises an error.
*}

{*
  Logic:
   - Parse the request object to extract category edit details.
   - Validate the input parameters for category ID and new category value.
   - Check if the provided category ID is valid and exists in the database.
   - Check if the new category value is already present in the database.
   - Update the category in the Category table with the new value.
   - Log the category edit transaction in the EditTransactions table.
*}


  LRequestObj:= TlkJSON.parsetext(Request.Content) as TlkJSONobject;
  try
  
    LCategoryIDint:= FieldValueByNameAs(LRequestObj, 'Category ID', jsNumber, DEFAULT_VALUE_OFINTEGER_FORVALIDATION, LIsPresent, True, True);
    LNewCategoryValuestr:= FieldValueByNameAs(LRequestObj, 'New Value', jsString, DEFAULT_VALUE_OFSTRING_FORVALIDATION, LIsPresent, True, True);

    if (LNewCategoryValuestr = DEFAULT_VALUE_OFSTRING_FORVALIDATION) then
    begin
      raise Exception.Create('Please provide input for the new value field in string format!');
    end;

    if (LCategoryIDint = DEFAULT_VALUE_OFINTEGER_FORVALIDATION) then
    begin
      raise Exception.Create('Please provide input for the category id field in integer format!');
    end;

    // check if category id is valid
    Self.LoadDataSetForCategory(IntToStr(LCategoryIDint), False, False);
    if (FDataSet2.RecordCount <> 1) then
      raise Exception.Create('Category id not found!');

     //store old name
    LOldCategoryValuestr:= FDataSet2.FieldByName('book_category').AsString;

    //check if category already exist
    Self.LoadDataSetForCategory(LNewCategoryValuestr, true, false);
    if (FDataSet2.RecordCount <> 0) then
      raise Exception.Create('Category By This Name Already Exist');


    //edit category in category table
    FnsQuery1.SQL.Clear;
    FnsQuery1.SQL.Text:='UPDATE Category SET book_category = :new_category_name WHERE category_id = :category_id;';
    FnsQuery1.CreateParamVariables;
    FnsQuery1.ParamByName('category_id').AsInteger := LCategoryIDint;
    FnsQuery1.ParamByName('new_category_name').AsString := CapitalizeFirstLetter(LNewCategoryValuestr);
    FnsQuery1.ExecuteDML;
    FnsQuery1.Close;

    //update the edit transactions table
    FnsQuery1.SQL.Clear;
    FnsQuery1.SQL.Text:='INSERT INTO EditTransactions (user_id, modified_field,  old_value, new_value, edit_date) VALUES (:user_id, :modified_field, :old_value, :new_value, :edit_date);';
    FnsQuery1.CreateParamVariables;
    FnsQuery1.ParamByName('user_id').AsInteger := LCookieCheckInt;
    FnsQuery1.ParamByName('modified_field').AsString := 'Category';
    FnsQuery1.ParamByName('old_value').AsString := LOldCategoryValuestr;
    FnsQuery1.ParamByName('new_value').AsString := CapitalizeFirstLetter(LNewCategoryValuestr);
    FnsQuery1.ParamByName('edit_date').AsDate := Now;
    FnsQuery1.ExecuteDML;
    FnsQuery1.Close;

  finally
    LRequestObj.free;
  end;

end;

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
function TnsBookManagement.GetAllCategoryAsJSON(LResponseListVip: TlkJSONlist): tlkJSONList;
var
LResponseObjVip: TlkJSONobject;
LTempCategoryIDField: TField;
LTempCategorynameField: TField;
begin
{*
  Intent: This procedure is used to Get all categories present in the database.

  Result - JSON list with details of category
*}

  //Loading dataset with all the categories in the database
  Self.LoadDataSetForCategory('', false,false);

  try
    FDataSet2.First;

    LTempCategoryIDField:= FDataSet2.FieldByName('category_id');
    LTempCategorynameField:= FDataSet2.FieldByName('book_category');
    
    //adding the category details in JSON list
    while not FDataSet2.Eof do
    begin
      LResponseObjVip:= TlkJSONobject.Create();

      LResponseObjVip.Add('Category ID: ',LTempCategoryIDField.AsInteger);
      LResponseObjVip.Add('Category Name: ',LTempCategorynameField.AsString);

      LResponseListVip.Add(LResponseObjVip);
      FDataSet2.Next;

    end;
    
    if (LResponseListVip.Count = 0) then
    begin
      raise Exception.Create('No Categories Found');
    end;

    Result:= LResponseListVip;

  finally
    FDataSet2.Close;
  end;


end;

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//  Function to Add Authors
procedure TnsBookManagement.AddAuthorinDB;
var
LRequestObj: TlkJSONobject;
LAuthorField: String;
LIsPresent: Boolean;
begin
{*
  Intent: This procedure is used to Add new Author in the database.

  result: New Author added in the database
*}

  LRequestObj:= TlkJSON.parsetext(Request.Content) as TlkJSONobject;
  try
    LAuthorField:= FieldValueByNameAs(LRequestObj, 'Author', jsString,DEFAULT_VALUE_OFSTRING_FORVALIDATION, LIsPresent, True, True);

    if (LAuthorField = DEFAULT_VALUE_OFSTRING_FORVALIDATION) then
    begin
      raise Exception.Create('Please provide input for the Author field in Text Format!');
    end;


    // check if Author already exist
    Self.LoadDataSetForAuthor(LAuthorField, true, false);

    if(FDataSet4ForAuthor.RecordCount <> 0) then
    begin
      raise Exception.Create('Author Already Exist in Database');
    end;

    //Loading empty datset
    Self.LoadDataSetForAuthor('', True, false);
    FDataSet4ForAuthor.Insert;
    FDataSet4ForAuthor.FieldByName('book_author').AsString:= CapitalizeFirstLetter(LAuthorField) ;
    FDataSet4ForAuthor.Post;
  finally
    LRequestObj.Free;
  end;
end;

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//                                                                function to edit author details
procedure TnsBookManagement.EditAuthorInDB(Request: TWebRequest; Response: TWebResponse; LCookieCheckInt: Integer);
var
LOldAuthorValuestr: String;
LNewAuthorValuestr: String;
LAuthorIDint: Integer;
LRequestObj: TlkJSONobject;
LIsPresent: Boolean;
begin
{*
  Intent: This procedure is used to edit the author details in the database.

  Parameters:
    - Request: The HTTP request object containing the new author details.
    - Response: The HTTP response object to handle success or error.
    - LCookieCheckInt: The integer value representing the Admins's cookie for adding the user_id in EditTransactions table.

  Result: It updates the author details in the database and logs the edit transaction.
*}

{*
  Logic:
   - Parse the request content to extract the new author details.
   - Validate the input parameters (Author ID and New Value).
   - Load the dataset for the specified Author ID to check if it exists in the database.
   - If the Author ID is not found, raise an exception.
   - Store the old Author name before updating it.
   - Check if the new Author value already exists in the database.
   - If the new Author value already exists, raise an exception.
   - Update the Author details in the Author table with the new value.
   - Log the edit transaction in the EditTransactions table with the old and new values, and the edit date.
*}



  LRequestObj:= TlkJSON.parsetext(Request.Content) as TlkJSONobject;
  try
    LAuthorIDint:= FieldValueByNameAs(LRequestObj, 'Author ID', jsNumber, DEFAULT_VALUE_OFINTEGER_FORVALIDATION, LIsPresent, True, True);
    LNewAuthorValuestr:= FieldValueByNameAs(LRequestObj, 'New Value', jsString, DEFAULT_VALUE_OFSTRING_FORVALIDATION, LIsPresent, True, True);

    if (LNewAuthorValuestr = DEFAULT_VALUE_OFSTRING_FORVALIDATION) then
    begin
      raise Exception.Create('Please provide input for the new value field in string format!');
    end;

    if (LAuthorIDint = DEFAULT_VALUE_OFINTEGER_FORVALIDATION) then
    begin
      raise Exception.Create('Please provide input for the author id field in integer format!');
    end;

    // check if author id is valid
    Self.LoadDataSetForAuthor(IntToStr(LAuthorIDint), False, False);

    if (FDataSet4ForAuthor.RecordCount <> 1) then
      raise Exception.Create('Author id not found!');

    //store old Author name when the Author id Provided is found
    LOldAuthorValuestr:= FDataSet4ForAuthor.FieldByName('book_author').AsString;

    //check if Author already exist
    Self.LoadDataSetForAuthor(LNewAuthorValuestr, true, false);

    if (FDataSet4ForAuthor.RecordCount <> 0) then
      raise Exception.Create('Author By This Name Already Exist');


    //edit Author in Author table
    FnsQuery1.SQL.Clear;
    FnsQuery1.SQL.Text:='UPDATE Author SET book_author = :new_author_name WHERE author_id = :author_id;';
    FnsQuery1.CreateParamVariables;
    FnsQuery1.ParamByName('author_id').AsInteger := LAuthorIDint;
    FnsQuery1.ParamByName('new_author_name').AsString := CapitalizeFirstLetter(LNewAuthorValuestr);
    FnsQuery1.ExecuteDML;
    FnsQuery1.Close;

    //update the edit transactions table
    FnsQuery1.SQL.Clear;
    FnsQuery1.SQL.Text:='INSERT INTO EditTransactions (user_id, modified_field,  old_value, new_value, edit_date) VALUES (:user_id, :modified_field, :old_value, :new_value, :edit_date);';
    FnsQuery1.CreateParamVariables;
    FnsQuery1.ParamByName('user_id').AsInteger := LCookieCheckInt;
    FnsQuery1.ParamByName('modified_field').AsString := 'Author';
    FnsQuery1.ParamByName('old_value').AsString := LOldAuthorValuestr;
    FnsQuery1.ParamByName('new_value').AsString := CapitalizeFirstLetter(LNewAuthorValuestr);
    FnsQuery1.ParamByName('edit_date').AsDate := Now;
    FnsQuery1.ExecuteDML;
    FnsQuery1.Close;

  finally
    LRequestObj.free;
  end;
end;
end.


