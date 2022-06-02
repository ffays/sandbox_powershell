# https://stackoverflow.com/questions/822907/how-do-i-use-powershell-to-validate-xml-files-against-an-xsd
# http://www.java2s.com/Code/CSharp/XML/UseXmlReaderSettingstovalidatetheXmldocument.htm

# $ErrorActionPreference = 'Stop'
# Set-StrictMode -Version 2

# $errors = Test-Xml -xsd 'xml_schema.xsd' -xml 'data.xml'
# if($errors) { Write-Error $errors }

function Test-Xml {
    [cmdletbinding()]
    param (
        [parameter(mandatory=$true)]$xsd,
        [parameter(mandatory=$true)]$xml,
        $namespace = $null
    )

    begin {
        $result = [System.Collections.ArrayList]@()
    }

    process {
        Write-Verbose "XML file: $xml"
        Write-Verbose "XSD file: $xsd"
        if (-not (Test-Path $xsd)) {
            throw "XSD file '$xsd' not found!"
        }
        $readerSettings = [System.Xml.XmlReaderSettings]::new()
        $readerSettings.ValidationType = [System.Xml.ValidationType]::Schema
        $readerSettings.ValidationFlags = [System.Xml.Schema.XmlSchemaValidationFlags]::ProcessIdentityConstraints -bor [System.Xml.Schema.XmlSchemaValidationFlags]::ProcessSchemaLocation -bor [System.Xml.Schema.XmlSchemaValidationFlags]::ReportValidationWarnings
        $readerSettings.Schemas.Add($namespace, $xsd) | Out-Null
        $inputUri = (Resolve-Path $xml).Path
        $readerSettings.add_ValidationEventHandler({$result.add("$($inputUri):$($_.exception.linenumber):$($_.exception.lineposition):$($_.Message)")});
        $reader = [System.Xml.XmlReader]::Create($inputUri, $readerSettings)
        try {
            while ($reader.Read()) {}
        } finally {
            $reader.Close() # close the reader since it locks files
        }
    }

    end {
        $result
    }
}
