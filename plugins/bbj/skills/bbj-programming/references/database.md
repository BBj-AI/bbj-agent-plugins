# Database access: JDBC and SQL verbs

A BBj program queries a database through the object-based JDBC API or through the language-level SQL verbs. The
EM JDBC How-To page has a Java sample for JDBC and a BBj sample for the SQL verbs:
https://documentation.basis.cloud/BASISHelp/WebHelp/em/database/EM_DB_JDBC_How-To.htm

## JDBC

`BBjAPI().getJDBCConnection(url)` returns a `java.sql.Connection`
(https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/bbjapi/bbjapi_getjdbcconnection.htm). The `url`
is "The name of a BBj database on the server, or the JDBC connection URL used to connect to a remote or third party
database"; a BBj database name must match "the name defined in the Enterprise Manager, including case". The page also
lists overloads that take `mode` (a list of properties such as `USER=myusername,PWD=mypass`), `props`, or `user` and
`password` (the last two from BBj 16.00). The blocks
use `ChileCompany`, the database of the page's own example; pass the name of your database. The query
`select 1` and the column name `COL` are placeholders: `select 1` returns one unnamed column, so replace both with a
query and a column of your own table. The Java sample of the How-To page closes the result
set, the statement and the connection, so the blocks do the same. Declare the `java.sql` types of the connection,
the statement and the result set. An undeclared `rs!` in the `while` condition fails `bbjcpl -t` with
`Cannot assign <undeclared> to BBjNumber`; `bbj-ls` passes it.

```bbj should-fail
declare java.sql.Connection conn!
declare java.sql.Statement stmt!
conn! = BBjAPI().getJDBCConnection("ChileCompany")
stmt! = conn!.createStatement()
rs! = stmt!.executeQuery("select 1")
while (rs!.next())
    val! = rs!.getString("COL")
wend
rs!.close()
stmt!.close()
conn!.close()
```

```bbj
declare java.sql.Connection conn!
declare java.sql.Statement stmt!
declare java.sql.ResultSet rs!
conn! = BBjAPI().getJDBCConnection("ChileCompany")
stmt! = conn!.createStatement()
rs! = stmt!.executeQuery("select 1")
while (rs!.next())
    val! = rs!.getString("COL")
wend
rs!.close()
stmt!.close()
conn!.close()
```

## SQL verbs

`SQLOPEN` associates a channel with a SQL database, `SQLPREP` sets up the command, `SQLEXEC` executes it,
`SQLFETCH()` returns the next row and `SQLTMPL()` returns the template for the `DIM`. `SQLFETCH()` raises
`!ERROR=2` when no rows remain, so loop it with `err=` pointing at a label, and close the channel with `SQLCLOSE`.
Pages: https://documentation.basis.cloud/BASISHelp/WebHelp/commands/sqlopen_verb.htm,
https://documentation.basis.cloud/BASISHelp/WebHelp/commands/sqlprep_verb.htm,
https://documentation.basis.cloud/BASISHelp/WebHelp/commands/sqlexec_verb.htm,
https://documentation.basis.cloud/BASISHelp/WebHelp/commands/sqlfetch_function.htm,
https://documentation.basis.cloud/BASISHelp/WebHelp/commands/sqltmpl_function.htm,
https://documentation.basis.cloud/BASISHelp/WebHelp/commands/sqlclose_verb.htm

The URL, the table `t` and the column `col` in the block are placeholders; replace them with your own. For a JDBC
URL the How-To sample passes the credentials as `SQLOPEN(chan, MODE="USER=youruser,PWD=yourpwd") url$`; the
SQLOPEN page documents the MODE options `UID=string` and `PWD=string` for a data source and shows
`mode="UID=me,PWD=you"`. The pages give no rule for choosing between `USER=` and `UID=`; follow the page that
matches your kind of data source.

```bbj
chan = sqlunt
sqlopen(chan) "jdbc:basis:localhost?DATABASE=Demo"
sqlprep(chan) "select * from t"
sqlexec(chan)
dim rec$:sqltmpl(chan)
while 1
    rec$ = sqlfetch(chan, err=finished)
    print rec.col$
wend
finished:
sqlclose(chan)
```

## Limiting rows

The BBj SQL grammar limits the rows of a SELECT with `LIMIT (first, count)`: "The LIMIT clause on SELECT
statements returns a specified number of rows starting at a selected offset." `first` is the offset of the first
row to return and `count` the maximum number of rows to return. The page adds:
"The first parameter is based in 1. The number of rows must be a positive integer."
(https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/SQL_LIMIT.htm). For the exact position of the
clause in a query see the SQL Grammar page linked from it.

## SQL functions

For a BBj database, these pages list the string, numeric and time-and-date functions "supported by the
BASIS DBMS". For a third-party database reached through a JDBC URL these pages do not apply; use that database's
own documentation (general advice, not stated on these pages):

- https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/bbjds_string_functions.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/bbjds_numeric_functions.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/bbjds_time_and_date_functions.htm

## Sources

- https://documentation.basis.cloud/BASISHelp/WebHelp/em/database/EM_DB_JDBC_How-To.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/bbjapi/bbjapi_getjdbcconnection.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/sqlopen_verb.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/sqlprep_verb.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/sqlexec_verb.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/sqlfetch_function.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/sqltmpl_function.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/commands/sqlclose_verb.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/SQL_LIMIT.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/bbjds_string_functions.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/bbjds_numeric_functions.htm
- https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/bbjds_time_and_date_functions.htm
- Verified on BBj 26.03 (bbjcpl -t -N -X and bbj-ls; probes d01, d02, d03)
