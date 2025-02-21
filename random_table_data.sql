-----Random_table_data

USE Random_Teble_Data;
GO

-- Drop the old table, if needed
DROP TABLE Random_Teble_Data;
GO

-- Create a table with primary key
CREATE TABLE fyi_random (
  id INT,
  rand_integer INT,
  rand_number numeric(18,9),
  rand_datetime DATETIME,
  rand_string VARCHAR(80)
);
GO

-- Insert rows with random values
DECLARE @row INT;
DECLARE @string VARCHAR(80), @length INT, @code INT;
SET @row = 0;
WHILE @row < 100000 BEGIN
   SET @row = @row + 1;

   -- Build the random string
   SET @length = ROUND(80*RAND(),0);
   SET @string = '';
   WHILE @length > 0 BEGIN
      SET @length = @length - 1;
      SET @code = ROUND(32*RAND(),0) - 6;
      IF @code BETWEEN 1 AND 26 
         SET @string = @string + CHAR(ASCII('a')+@code-1);
      ELSE
         SET @string = @string + ' ';
   END 

   -- Ready for the record
   SET NOCOUNT ON;
   INSERT INTO fyi_random VALUES (
      @row,
      ROUND(2000000*RAND()-1000000,0),
      ROUND(2000000*RAND()-1000000,9),
      CONVERT(DATETIME, ROUND(60000*RAND()-30000,9)),
      @string
   )
END
PRINT 'Rows inserted: '+CONVERT(VARCHAR(20),@row);
GO
