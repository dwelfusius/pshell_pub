---
external help file: DpToolsEX-help.xml
Module Name: DPToolsEX
online version:
schema: 2.0.0
---

# Edit-DPRoom

## SYNOPSIS
Command to change meeting room names according to naming convention

## SYNTAX

```
Edit-DPRoom [-Oldname] <Object> [-Name] <Object> [[-DC] <Object>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Command to change meeting room names according to naming convention.

## EXAMPLES

### Example 1
```powershell
PS C:\> Edit-DPRoom -Oldname 'Guimard10' -Name 'BE-GU10-02-MEETING-ROOM-03'
```

This will change the name,displayname,primary smtp,mail nickname and 
SAM account name according to the naming convention using the logged on DC

### Example 2
```powershell
PS C:\> Edit-DPRoom -Oldname 'Guimard10' -Name 'BE-GU10-02-MEETING-ROOM-03' -DC dc01
```

This will change the name,displayname,primary smtp,mail nickname and 
SAM account name according to the naming convention using DC01

## PARAMETERS

### -DC
This allows you to select another Domain Controller than the one currently used

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Logged on Domain Controller
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
This is the new name the meeting room should receive

```yaml
Type: Object
Parameter Sets: (All)
Aliases: NewName

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Oldname
This is the old name and also the identity of the room mailbox to modify

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
