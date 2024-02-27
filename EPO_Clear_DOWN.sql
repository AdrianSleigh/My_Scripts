ePO 5.3.x and later:
SET rowcount 10000
DELETE FROM epoEventsMT
WHERE detectedutc < 'yyyy-mm-dd'
WHILE @@rowcount > 0
BEGIN
DELETE FROM epoEventsMT
WHERE detectedutc < 'yyyy-mm-dd'
END
SET rowcount 0
GO

ePO 5.1.x and earlier:
SET rowcount 10000
DELETE FROM epoEvents
WHERE detectedutc < 'yyyy-mm-dd'
WHILE @@rowcount > 0
BEGIN
DELETE FROM epoEvents
WHERE detectedutc < 'yyyy-mm-dd'
END
SET rowcount 0
GO

IMPORTANT: Ensure that you change yyyy-mm-dd to the correct date; everything earlier than the date you specify will be deleted.