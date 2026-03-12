-- Ref: http://www.smartplanet.com/blog/business-brains/the-25-worst-passwords-of-2011-8216password-8216123456-8242/20065
/*=====================================================================
    SQL SERVER WEAK PASSWORD GENERATOR & AUDIT TOOL
    ------------------------------------------------
    SAFETY NOTICE:
    This script uses PWDCOMPARE to evaluate SQL login password hashes
    against a generated weak-password list.

    PWDCOMPARE DOES NOT:
      - Perform login attempts
      - Trigger authentication
      - Increment lockout counters
      - Generate failed login events
      - Lock or disable accounts

    PWDCOMPARE ONLY compares a plaintext candidate to a stored hash.
    This method is Microsoft-supported and completely safe to run in
    production environments.

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
    -- 1. Default roots
    -------------------------------------------------------------------
    SELECT root
    INTO #Default
    FROM (VALUES
        ('password'),('pass'),('admin'),('letmein'),('welcome'),
        ('monkey'),('dragon'),('football'),('qwerty'),('abc123'),
        ('iloveyou'),('sunshine'),('princess'),('superman'),('pokemon'),
        ('bella'),('milo'),('luna'),('charlie'),('max'),('daisy'),('poppy'),
        ('london'),('manchester'),('liverpool'),('birmingham'),
        ('leeds'),('glasgow'),
        ('james'),('john'),('robert'),('michael'),('david'),
        ('oliver'),('harry'),('george'),('amelia')
    ) AS d(root);

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
