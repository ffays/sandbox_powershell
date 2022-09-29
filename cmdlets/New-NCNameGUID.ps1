# Create a new GUID that is compliant to Non Colonized Name "NCName" XML definition.

# To be valid, an XML Identifier must start with an alphabetic character,
# therefore the two most significant bits of the GUID are set
# in order to have the GUID starting with hexadecimal digit from 0xA to 0xF

# TSQL Equivalent (for Microsoft SQL Server)

# DECLARE @guid UNIQUEIDENTIFIER = NEWID();
# DECLARE @b0_15 BINARY(16) = CONVERT(BINARY(16), @guid); -- GUID as 16 Bytes
# DECLARE @b0_3 BINARY(3) = SUBSTRING(@b0_15,0, 4) -- bytes 0..3
# DECLARE @b4  BINARY(1) = CAST((SUBSTRING(@b0_15,4, 1) | 160) AS BINARY(1)); -- byte 4: Adjust first hexdigit to be between 0xA and 0xF
# DECLARE @b5_15  BINARY(12) = SUBSTRING(@b0_15,5, 13) -- bytes 5..15
# DECLARE @buid BINARY(16) = @b0_3 + @b4 + @b5_15; -- Adjusted GUID as 16 Bytes
# DECLARE @result UNIQUEIDENTIFIER = CONVERT(UNIQUEIDENTIFIER, @buid); -- Adjusted GUID
# SELECT @guid [GUID], @result [Adjusted UUID]

function New-NCNameGUID {
	$b = (New-Guid).ToByteArray()
	New-Object Guid(,(@($b[0],$b[1],$b[2],[Byte]($b[3] -bor 0xA0),$b[4],$b[5],$b[6],$b[7],$b[8],$b[9],$b[10],$b[11],$b[12],$b[13],$b[14],$b[15]) -as [Byte[]]))
}
