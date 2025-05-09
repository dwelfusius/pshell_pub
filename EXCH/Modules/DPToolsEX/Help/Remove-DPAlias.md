---
external help file: DpToolsEX-help.xml
Module Name: DpToolsEX
online version:
schema: 2.0.0
---

# Remove-DPAlias

## SYNOPSIS
Interactive command to remove smtp mailbox aliases

## SYNTAX

```
Remove-DPAlias [-Name] <Object> [<CommonParameters>]
```

## DESCRIPTION
This command will give a grid interface with all non-primary smtp aliases
so they can be removed easily

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-DPAlias -Name ktc
```

This will provide an Out-Gridview window where you can select non-primary
smtp aliases to be removed

## PARAMETERS

### -Name
The mailbox identity to look for

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Identity

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
