---
external help file: DpToolsEX-help.xml
Module Name: DPToolsEX
online version:
schema: 2.0.0
---

# Add-DPSharedMailboxPermission

## SYNOPSIS
Command to add standard shared mailbox permissions

## SYNTAX

```
Add-DPSharedMailboxPermission [-Name] <String> [[-Group] <String>] [[-InputObject] <Object>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Command to add standard shared mailbox permissions in case of 
missing or changed rights and/or groups. Will use standard naming convention
for access group if none is defined

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-DPSharedMailboxPermission -Name Connect.DP
```

Will add Full-Access and Send-As permissions for the 
group EXCHANGE_SharedMailboxAccess_Connect.DP

## PARAMETERS

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Group
The name of the group you want to grant Full-Access and Send-As permissions

```yaml
Type: String
Parameter Sets: (All)
Aliases: User

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InputObject
To pass along a list of shared mailboxes via the pipeline

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
The name of the shared mailbox whose access you wish to modify

```yaml
Type: String
Parameter Sets: (All)
Aliases: Identity

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Object

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
