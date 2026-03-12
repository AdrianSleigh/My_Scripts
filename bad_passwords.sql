/*=====================================================================
    SQL SERVER WEAK PASSWORD GENERATOR & AUDIT TOOL
    ------------------------------------------------
    PWDCOMPARE ONLY compares a plaintext candidate to a stored hash.
    This method is Microsoft-supported and completely safe to run in
    production environments.
INSTRUCTIONS 1.Run GenerateWeakPasswords 2.Run CheckWeakSQLPasswords 3. Results written to WeakPasswordHits table
EXAMPLES:
MODE1--------
EXEC dbo.GenerateWeakPasswords
    @Mode = 1,
    @TargetCount = 100000;
MODE2--------
EXEC dbo.GenerateWeakPasswords
    @Mode = 2,
    @Roots = 'telford,tenby,poppy,luna',
    @TargetCount = 100000;
MODE3--------
EXEC dbo.GenerateWeakPasswords
    @Mode = 3,
    @Roots = 'bankofengland,boe,threadneedle',
    @CsvPath = 'C:\lists\extra_roots.csv',
    @UseDictionary = 1,
    @TargetCount = 100000;
MODE4--------
EXEC dbo.GenerateWeakPasswords
    @Mode = 4,
    @CsvPath = 'C:\lists\extra_roots.csv',
    @TargetCount = 100000;
PREVIEWMODE--------
EXEC dbo.GenerateWeakPasswords
    @Mode = 3,
    @Roots = 'telford,tenby',
    @CsvPath = 'C:\lists\extra_roots.csv',
    @Preview = 1;
DISABLE DEFAULTS--------
EXEC dbo.GenerateWeakPasswords
    @Mode = 3,
    @Roots = 'boe,bank,finance',
    @CsvPath = 'C:\lists\finance_roots.csv',
    @IncludeDefaults = 0;
DISABLE SUFFIXES,NUMBERS,REPEATS,SUBS-------
EXEC dbo.GenerateWeakPasswords
    @Mode = 3,
    @IncludeSuffixes = 0,
    @IncludeNumbers = 0,
    @IncludeRepeats = 0,
    @IncludeSubstitutions = 0;
DICTIONARY ONLY--------
EXEC dbo.GenerateWeakPasswords
    @Mode = 3,
    @UseDictionary = 1,
    @IncludeDefaults = 0,
    @Roots = NULL,
    @CsvPath = NULL;

RUN THE AUDIT AFTER GENERATION
EXEC dbo.CheckWeakSqlPasswords;










    VERSION HEADER:
      Build: 2026.03.12.01
      Author: Adrian Sleigh
=====================================================================*/


/*---------------------------------------------------------------------
    SUPPORTING TABLES
---------------------------------------------------------------------*/

IF OBJECT_ID('dbo.WeakPasswords', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.WeakPasswords
    (
        PasswordText VARCHAR(256) NOT NULL PRIMARY KEY
    );
END;

IF OBJECT_ID('dbo.WeakPasswordGenLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.WeakPasswordGenLog
    (
        RunID        INT IDENTITY(1,1) PRIMARY KEY,
        RunTime      DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
        Mode         INT          NOT NULL,
        TargetCount  INT          NOT NULL,
        DefaultRoots INT          NOT NULL,
        UserRoots    INT          NOT NULL,
        CsvRoots     INT          NOT NULL,
        DictRoots    INT          NOT NULL,
        FinalRoots   INT          NOT NULL,
        FinalPwCount INT          NOT NULL
    );
END;

IF OBJECT_ID('dbo.PasswordDictionary', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PasswordDictionary
    (
        Root VARCHAR(50) NOT NULL PRIMARY KEY
    );
END;

IF OBJECT_ID('dbo.WeakPasswordHits', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.WeakPasswordHits
    (
        LoginName     SYSNAME,
        WeakPassword  VARCHAR(256),
        CheckedAt     DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO


/*---------------------------------------------------------------------
    WEAK PASSWORD GENERATOR (MODES 1–4 + CSV VALIDATION)
---------------------------------------------------------------------*/

CREATE OR ALTER PROCEDURE dbo.GenerateWeakPasswords
(
    @Mode                 INT             = 1,               -- 1=Default, 2=User, 3=Combined, 4=CSV only
    @Roots                NVARCHAR(MAX)   = NULL,            -- comma-separated user roots
    @CsvPath              NVARCHAR(4000)  = NULL,            -- optional CSV file path
    @UseDictionary        BIT             = 0,               -- include dbo.PasswordDictionary
    @IncludeDefaults      BIT             = 1,               -- include built-in defaults
    @IncludeSuffixes      BIT             = 1,
    @IncludeKeyboard      BIT             = 1,
    @IncludeNumbers       BIT             = 1,
    @IncludeRepeats       BIT             = 1,
    @IncludeSubstitutions BIT             = 1,
    @YearStart            INT             = 2000,
    @YearEnd              INT             = YEAR(GETDATE()),
    @MinLength            INT             = 1,
    @MaxLength            INT             = 32,
    @TargetCount          INT             = 100000,
    @Preview              BIT             = 0,
    @LogRun               BIT             = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @YearEnd < @YearStart
        SET @YearEnd = @YearStart;

    IF OBJECT_ID('tempdb..#Roots')      IS NOT NULL DROP TABLE #Roots;
    IF OBJECT_ID('tempdb..#Default')    IS NOT NULL DROP TABLE #Default;
    IF OBJECT_ID('tempdb..#UserRoots')  IS NOT NULL DROP TABLE #UserRoots;
    IF OBJECT_ID('tempdb..#CsvRoots')   IS NOT NULL DROP TABLE #CsvRoots;
    IF OBJECT_ID('tempdb..#DictRoots')  IS NOT NULL DROP TABLE #DictRoots;
    IF OBJECT_ID('tempdb..#Nums')       IS NOT NULL DROP TABLE #Nums;

    -------------------------------------------------------------------
    -- CSV VALIDATION (file exists, readable)
    -------------------------------------------------------------------
    IF @CsvPath IS NOT NULL AND @CsvPath <> ''
    BEGIN
        BEGIN TRY
            SELECT TOP 1 BulkColumn
            FROM OPENROWSET(BULK @CsvPath, SINGLE_CLOB) AS v;
        END TRY
        BEGIN CATCH
            RAISERROR('CSV file cannot be opened: %s', 16, 1, @CsvPath);
            RETURN;
        END CATCH;
    END

    -------------------------------------------------------------------
    -- 1. Default roots most common passwords 2025
    -------------------------------------------------------------------
    SELECT root
    INTO #Default

  FROM (VALUES
('123456'),('admin'),('12345678'),('123456789'),('12345'),
('password'),('Aa123456'),('1234567890'),('Pass@123'),('admin123'),
('1234567'),('123123'),('111111'),('12345678910'),('P@ssw0rd'),
('Password'),('Aa@123456'),('admintelecom'),('Admin@123'),('112233'),
('qwerty'),('qwerty123'),('qwertyuiop'),('iloveyou'),('welcome'),
('dragon'),('football'),('monkey'),('letmein'),('abc123'),
('superman'),('princess'),('sunshine'),('pokemon'),('charlie'),
('bella'),('milo'),('luna'),('max'),('daisy'),
('poppy'),('london'),('manchester'),('liverpool'),('birmingham'),
('leeds'),('glasgow'),('james'),('john'),('robert'),
('michael'),('david'),('oliver'),('harry'),('george'),
('amelia'),('654321'),('000000'),('121212'),('1q2w3e'),
('qazwsx'),('asdfgh'),('zxcvbn'),('1qaz2wsx'),('159753'),
('qwerty1'),('qwerty12'),('qwerty1234'),('qwertyui'),('987654321'),
('9876543210'),('1234'),('123'),('123321'),('123qwe'),
('qwe123'),('1q2w3e4r'),('1q2w3e4r5t'),('123456a'),('123456aa'),
('123456abc'),('123456q'),('123456qq'),('123456z'),('123456x'),
('123456!'),('123456@'),('123456#'),('123456$'),('123456%'),
('123456?'),('password1'),('password123'),('password1234'),('password12345'),
('pass123'),('pass1234'),('pass12345'),('passw0rd'),('p@ssword'),
('p@ssw0rd'),('admin1'),('admin1234'),('admin12345'),('administrator'),
('root'),('root123'),('root1234'),('root12345'),('system'),
('guest'),('guest123'),('guest1234'),('guest12345'),('test'),
('test1'),('test123'),('test1234'),('test12345'),('login'),
('login123'),('login1234'),('login12345'),('user'),('user1'),
('user123'),('user1234'),('user12345'),('default'),('default123'),
('default1234'),('default12345'),('welcome1'),('welcome123'),('welcome1234'),
('welcome12345'),('qwert'),('qwert1'),('qwert12'),('qwert12345'),
('qwerty!'),('qwerty@'),('qwerty#'),('qwerty$'),('qwerty%'),
('iloveyou1'),('iloveyou123'),('iloveyou1234'),('iloveyou12345'),
('love'),('love123'),('love1234'),('love12345'),('loveyou'),
('loveyou1'),('loveyou123'),('loveyou1234'),('loveyou12345'),
('1111111'),('11111111'),('111111111'),('222222'),('333333'),
('444444'),('555555'),('666666'),('777777'),('888888'),
('999999'),('123654'),('654123'),('147258'),('258369'),
('369258'),('147852'),('852369'),('123abc'),('abc1234'),
('abc12345'),('abc123456'),('abcdef'),('abcdefg'),('abcdefgh'),
('abcd1234'),('abcd12345'),('abcd123456'),('1password'),('mypassword'),
('mypassword1'),('mypassword123'),('mypassword1234'),('mypassword12345'),
('letmein1'),('letmein123'),('letmein1234'),('letmein12345'),
('football1'),('football123'),('football1234'),('football12345'),
('baseball'),('baseball1'),('baseball123'),('baseball1234'),
('soccer'),('soccer1'),('soccer123'),('soccer1234'),
('hockey'),('hockey1'),('hockey123'),('hockey1234'),
('basketball'),('basketball1'),('basketball123'),('basketball1234'),
('superman1'),('superman123'),('superman1234'),('superman12345'),
('batman'),('batman1'),('batman123'),('batman1234'),
('spiderman'),('spiderman1'),('spiderman123'),('spiderman1234'),
('pokemon1'),('pokemon123'),('pokemon1234'),('pokemon12345'),
('starwars'),('starwars1'),('starwars123'),('starwars1234'),
('harrypotter'),('harrypotter1'),('harrypotter123'),('harrypotter1234'),
('liverpool1'),('liverpool123'),('liverpool1234'),('liverpool12345'),
('arsenal'),('arsenal1'),('arsenal123'),('arsenal1234'),
('chelsea'),('chelsea1'),('chelsea123'),('chelsea1234'),
('manchester1'),('manchester123'),('manchester1234'),('manchester12345'),
('taylor'),('taylor1'),('taylor123'),('taylor1234'),
('summer'),('summer1'),('summer123'),('summer1234'),
('winter'),('winter1'),('winter123'),('winter1234'),
('hello'),('hello1'),('hello123'),('hello1234'),
('welcome!'),('welcome@'),('welcome#'),('welcome$'),
('qwerty2024'),('qwerty2025'),('qwerty2026'),('password2024'),
('password2025'),('password2026'),('admin2024'),('admin2025'),
('admin2026'),('1234562024'),('1234562025'),('1234562026')
)

)

        
        
        
        AS d(root);

    -------------------------------------------------------------------
    -- 2. User roots
    -------------------------------------------------------------------
    SELECT LTRIM(RTRIM(value)) AS root
    INTO #UserRoots
    FROM STRING_SPLIT(@Roots, ',')
    WHERE @Roots IS NOT NULL
      AND LTRIM(RTRIM(value)) <> '';

    -------------------------------------------------------------------
    -- 3. CSV roots (supports headers, commas, quotes)
    -------------------------------------------------------------------
    IF @CsvPath IS NOT NULL AND @CsvPath <> '' AND @Mode IN (3,4)
    BEGIN
        ;WITH Raw AS
        (
            SELECT BulkColumn AS line
            FROM OPENROWSET(BULK @CsvPath, SINGLE_CLOB) AS x
        ),
        SplitLines AS
        (
            SELECT value AS line
            FROM STRING_SPLIT((SELECT line FROM Raw), CHAR(10))
        ),
        Clean AS
        (
            SELECT 
                LTRIM(RTRIM(
                    REPLACE(
                        REPLACE(
                            PARSENAME(REPLACE(line, ',', '.'), 4), '"', ''
                        ), CHAR(13), ''
                    )
                )) AS root
            FROM SplitLines
            WHERE line IS NOT NULL AND LTRIM(RTRIM(line)) <> ''
        )
        SELECT root
        INTO #CsvRoots
        FROM Clean
        WHERE root IS NOT NULL
          AND root <> ''
          AND root NOT LIKE '%root%';  -- remove header row

        IF NOT EXISTS (SELECT 1 FROM #CsvRoots)
        BEGIN
            RAISERROR('CSV file loaded but contained no valid roots: %s', 16, 1, @CsvPath);
            RETURN;
        END
    END
    ELSE
    BEGIN
        SELECT CAST(NULL AS VARCHAR(50)) AS root
        INTO #CsvRoots
        WHERE 1 = 0;
    END

    -------------------------------------------------------------------
    -- 4. Dictionary roots
    -------------------------------------------------------------------
    IF @UseDictionary = 1
    BEGIN
        SELECT Root AS root
        INTO #DictRoots
        FROM dbo.PasswordDictionary;
    END
    ELSE
    BEGIN
        SELECT CAST(NULL AS VARCHAR(50)) AS root
        INTO #DictRoots
        WHERE 1 = 0;
    END

    -------------------------------------------------------------------
    -- 5. Merge roots based on mode
    -------------------------------------------------------------------
    SELECT DISTINCT root
    INTO #Roots
    FROM
    (
        SELECT root FROM #Default    WHERE @IncludeDefaults = 1 AND @Mode IN (1,3)
        UNION ALL
        SELECT root FROM #UserRoots  WHERE @Mode IN (2,3)
        UNION ALL
        SELECT root FROM #CsvRoots   WHERE @Mode IN (3,4)
        UNION ALL
        SELECT root FROM #DictRoots  WHERE @UseDictionary = 1 AND @Mode IN (3)
    ) AS x
    WHERE root IS NOT NULL AND root <> '';

    DECLARE @DefaultCount INT = (SELECT COUNT(*) FROM #Default);
    DECLARE @UserCount    INT = (SELECT COUNT(*) FROM #UserRoots);
    DECLARE @CsvCount     INT = (SELECT COUNT(*) FROM #CsvRoots);
    DECLARE @DictCount    INT = (SELECT COUNT(*) FROM #DictRoots);
    DECLARE @FinalRoots   INT = (SELECT COUNT(*) FROM #Roots);

    -------------------------------------------------------------------
    -- 6. Numbers table 0–99999
    -------------------------------------------------------------------
    WITH N AS
    (
        SELECT 0 AS n
        UNION ALL
        SELECT n + 1 FROM N WHERE n < 99999
    )
    SELECT n INTO #Nums FROM N OPTION (MAXRECURSION 0);

    -------------------------------------------------------------------
    -- 7. Suffixes and patterns
    -------------------------------------------------------------------
    DECLARE @Suffixes TABLE (sfx VARCHAR(10));
    IF @IncludeSuffixes = 1
    BEGIN
        INSERT INTO @Suffixes(sfx)
        VALUES ('','1','12','123','1234','12345','!','!1','!23','01','02','99');

        DECLARE @y INT = @YearStart;
        WHILE @y <= @YearEnd
        BEGIN
            INSERT INTO @Suffixes(sfx) VALUES (CAST(@y AS VARCHAR(10)));
            SET @y += 1;
        END
    END
    ELSE
    BEGIN
        INSERT INTO @Suffixes(sfx) VALUES ('');
    END

    DECLARE @Patterns TABLE (p VARCHAR(50));
    IF @IncludeKeyboard = 1
    BEGIN
        INSERT INTO @Patterns(p)
        VALUES ('qwerty'),('asdfgh'),('zxcvbn'),('qazwsx'),
               ('1q2w3e'),('qwertyuiop'),('123456'),('111111'),
               ('000000'),('121212'),('654321');
    END

    -------------------------------------------------------------------
    -- 8. Generate base set
    -------------------------------------------------------------------
    ;WITH Base AS
    (
        SELECT r.root + s.sfx AS pw
        FROM #Roots r
        CROSS JOIN @Suffixes s

        UNION ALL
        SELECT p FROM @Patterns WHERE @IncludeKeyboard = 1

        UNION ALL
        SELECT RIGHT('000000' + CAST(n AS VARCHAR(6)), 6)
        FROM #Nums
        WHERE @IncludeNumbers = 1
          AND n BETWEEN 0 AND 99999

        UNION ALL
        SELECT REPLICATE(CAST((n % 10) AS CHAR(1)), 6)
        FROM #Nums
        WHERE @IncludeRepeats = 1
          AND n < 10

        UNION ALL
        SELECT REPLACE(r.root, 'a', '@') + '1'
        FROM #Roots r
        WHERE @IncludeSubstitutions = 1
    ),
    Filtered AS
    (
        SELECT pw
        FROM Base
        WHERE LEN(pw) BETWEEN @MinLength AND @MaxLength
    )
    SELECT pw
    INTO #FinalPw
    FROM Filtered
    GROUP BY pw;

    DECLARE @FinalPwCount INT = (SELECT COUNT(*) FROM #FinalPw);

    -------------------------------------------------------------------
    -- 9. Preview or insert
    -------------------------------------------------------------------
    IF @Preview = 1
    BEGIN
        SELECT TOP (200) pw AS PasswordText
        FROM #FinalPw
        ORDER BY pw;
    END
    ELSE
    BEGIN
        TRUNCATE TABLE dbo.WeakPasswords;

        INSERT INTO dbo.WeakPasswords(PasswordText)
        SELECT TOP (@TargetCount) pw
        FROM #FinalPw
        ORDER BY pw;
    END

    -------------------------------------------------------------------
    -- 10. Log run
    -------------------------------------------------------------------
    IF @LogRun = 1
    BEGIN
        INSERT INTO dbo.WeakPasswordGenLog
        (
            Mode, TargetCount,
            DefaultRoots, UserRoots, CsvRoots, DictRoots,
            FinalRoots, FinalPwCount
        )
        VALUES
        (
            @Mode, @TargetCount,
            @DefaultCount, @UserCount, @CsvCount, @DictCount,
            @FinalRoots, @FinalPwCount
        );
    END
END;
GO


/*---------------------------------------------------------------------
    PWDCOMPARE-BASED SQL LOGIN AUDIT (SAFE, NON-LOCKING)
---------------------------------------------------------------------*/

CREATE OR ALTER PROCEDURE dbo.CheckWeakSqlPasswords
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.WeakPasswords', 'U') IS NULL
    BEGIN
        RAISERROR('WeakPasswords table not found. Run GenerateWeakPasswords first.', 16, 1);
        RETURN;
    END;

    TRUNCATE TABLE dbo.WeakPasswordHits;

    DECLARE @Login SYSNAME,
            @Hash VARBINARY(256),
            @Pwd  VARCHAR(256);

    DECLARE LoginCursor CURSOR FAST_FORWARD FOR
    SELECT name, password_hash
    FROM sys.sql_logins
    WHERE name NOT LIKE '##%'      -- skip system cert logins
      AND is_disabled = 0;

    OPEN LoginCursor;
    FETCH NEXT FROM LoginCursor INTO @Login, @Hash;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE PwdCursor CURSOR FAST_FORWARD FOR
        SELECT PasswordText FROM dbo.WeakPasswords;

        OPEN PwdCursor;
        FETCH NEXT FROM PwdCursor INTO @Pwd;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF PWDCOMPARE(@Pwd, @Hash) = 1
            BEGIN
                INSERT INTO dbo.WeakPasswordHits(LoginName, WeakPassword)
                VALUES(@Login, @Pwd);
            END

            FETCH NEXT FROM PwdCursor INTO @Pwd;
        END

        CLOSE PwdCursor;
        DEALLOCATE PwdCursor;

        FETCH NEXT FROM LoginCursor INTO @Login, @Hash;
    END

    CLOSE LoginCursor;
    DEALLOCATE LoginCursor;

    SELECT *
    FROM dbo.WeakPasswordHits
    ORDER BY LoginName, WeakPassword;
END;
GO


/*=====================================================================
    SHA-256 CHECKSUM FOOTER
    (Checksum is calculated over the entire script body above)
=====================================================================*/

-- SHA256:  <PLACEHOLDER — COMPUTE AFTER FINAL SAVE>

/*=====================================================================*/


