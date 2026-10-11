# Database access: JDBC and SQL verbs

A BBj program queries a database through the object-based JDBC API or through the language-level SQL verbs. The
EM JDBC How-To page has ready-to-use Java and BBj code examples for both:
https://documentation.basis.cloud/BASISHelp/WebHelp/em/database/EM_DB_JDBC_How-To.htm

## JDBC

`BBjAPI().getJDBCConnection(name)` returns a `java.sql.Connection`
(https://documentation.basis.cloud/BASISHelp/WebHelp/bbjobjects/bbjapi/bbjapi_getjdbcconnection.htm). Declare the
`java.sql` types of the connection, the statement and the result set. An undeclared `rs!` in the `while` condition
fails `bbjcpl -t` with `Cannot assign <undeclared> to BBjNumber`; `bbj-ls` passes it.

```bbj should-fail
declare java.sql.Connection conn!
declare java.sql.Statement stmt!
conn! = BBjAPI().getJDBCConnection("MyDatasource")
stmt! = conn!.createStatement()
rs! = stmt!.executeQuery("select 1")
while (rs!.next())
    val! = rs!.getString("COL")
wend
rs!.close()
stmt!.close()
```

```bbj
declare java.sql.Connection conn!
declare java.sql.Statement stmt!
declare java.sql.ResultSet rs!
conn! = BBjAPI().getJDBCConnection("MyDatasource")
stmt! = conn!.createStatement()
rs! = stmt!.executeQuery("select 1")
while (rs!.next())
    val! = rs!.getString("COL")
wend
rs!.close()
stmt!.close()
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

The string, numeric and time-and-date functions of the BBj SQL grammar are listed on the official pages. Use
them, and only the functions they list:

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
