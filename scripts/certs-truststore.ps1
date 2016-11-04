ls Cert:\CurrentUser\Root | ? {$_.SignatureAlgorithm.FriendlyName -eq "sha256RSA" } | `
    ft @{Name="NotBefore";Expression={$_.NotBefore};FormatString="dd-MMM-yyyy"}`
      ,@{Name="NotAfter";Expression={$_.NotAfter};FormatString="dd-MMM-yyyy"}`
      ,@{Name="SignatureAlgorithm";Expression={$_.SignatureAlgorithm.FriendlyName}}`
      ,Subject -AutoSize