# Database access

Two ways to query a database from BBj — the object-based JDBC API and the language-level SQL verbs. Both are documented here: https://documentation.basis.cloud/BASISHelp/WebHelp/em/database/EM_DB_JDBC_How-To.htm

## JDBC API (object-based)
```bbj
conn! = BBjAPI().getJDBCConnection("MyDatasource")   REM registered BBj datasource name
stmt! = conn!.createStatement()
rs!   = stmt!.executeQuery("SELECT * FROM my_table WHERE COL = 'value'")
while (rs!.next())
    val! = rs!.getString("COL_NAME")
wend
rs!.close()
stmt!.close()
```

## SQL verbs (SQLOPEN / SQLPREP / SQLEXEC / SQLFETCH)

The language-level alternative — rows come back through a string template built by `SQLTMPL`, and columns are read as template fields (`rec.COLUMN_NAME$`):
```bbj
chan = SQLUNT
url$ = "jdbc:basis:hgenc:2001?DATABASE=ChileCompany&SSL=false"
SQLOPEN(chan, MODE="USER=youruser,PWD=yourpwd") url$
SQLPREP(chan) "SELECT * FROM my_table"
SQLEXEC(chan)
DIM rec$:SQLTMPL(chan)
WHILE 1
    rec$ = SQLFETCH(chan, ERR=finished)
    PRINT rec.MY_CHAR_COLUMN$
WEND
finished:
SQLCLOSE(chan)
```
Key points: `SQLUNT` returns the next available SQL channel; `SQLTMPL(chan)` returns the template describing the result-set columns for the `DIM`; `SQLFETCH` is looped with `ERR=` pointing at a label to jump to when the rows run out; always `SQLCLOSE` the channel when done.

## BBj JDBC SQL string functions

The BBj JDBC driver uses its own set of SQL string functions — **not** ANSI SQL. Always use these names; standard ANSI names like `LOWER()` / `UPPER()` are not recognized and will throw a runtime error.

| BBj function | ANSI equivalent | Notes |
|---|---|---|
| `LCASE(str)` | `LOWER(str)` | Case-fold to lowercase |
| `UCASE(str)` | `UPPER(str)` | Case-fold to uppercase |
| `LENGTH(str)` | `LEN(str)` | String length |
| `SUBSTRING(str, start, len)` | `SUBSTR` | 1-based start index |
| `CONCAT(s1, s2)` | `s1 \|\| s2` | String concatenation |
| `TRIM(str)` | `TRIM(str)` | Trim whitespace |
| `LTRIM(str)` | `LTRIM(str)` | Trim leading whitespace |
| `RTRIM(str)` | `RTRIM(str)` | Trim trailing whitespace |

```bbj
REM Correct — use LCASE, not LOWER
ps! = conn!.prepareStatement("SELECT id FROM watches WHERE LCASE(make)=LCASE(?) AND LCASE(model)=LCASE(?)")

REM Wrong — LOWER() is not a BBj JDBC function
ps! = conn!.prepareStatement("SELECT id FROM watches WHERE LOWER(make)=LOWER(?)")   ;REM ❌ runtime error
```

Full references:
- String functions: https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/bbjds_string_functions.htm
- Numeric functions: https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/bbjds_numeric_functions.htm
- Time and date functions: https://documentation.basis.cloud/BASISHelp/WebHelp/b3odbc/SQL/bbjds_time_and_date_functions.htm

## Limiting result rows — use TOP, not LIMIT

`LIMIT n` (MySQL / SQLite style) is **not** supported by the BBj JDBC driver. Use `TOP n` immediately after `SELECT`:
```bbj
REM CORRECT — TOP goes right after SELECT
ps! = conn!.prepareStatement("SELECT TOP 20 id FROM watches WHERE LCASE(make)=LCASE(?)")

REM WRONG — LIMIT causes a syntax error
ps! = conn!.prepareStatement("SELECT id FROM watches WHERE LCASE(make)=LCASE(?) LIMIT 20")   ;REM ❌ ERROR 252
```

If a project has an existing shared/reference database, read from it directly rather than duplicating its data; create your own database/tables only for data the app owns.
