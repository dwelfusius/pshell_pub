---
external help file: DpToolsEX-help.xml
Module Name: DPToolsEX
online version:
schema: 2.0.0
---

# New-DPRoom

## SYNOPSIS
Command to create a new meeting room using all the required defaults

## SYNTAX

```
New-DPRoom [-Name] <Object> [-Seats] <Object> [[-DC] <Object>] [[-OU] <Object>] [[-Details] <String[]>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Command to create a new meeting room using all the required defaults.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-DPRoom -Name 'BE-NI45-07-MEETING-ROOM-03' -Seats 8 -Details VideoConference
```

Will create room BE-NI45-07-MEETING-ROOM-03 with location 'BE-NI45-07'
8 seats and mark it as VideoConferencing available

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

### -DC
The Domain Controller used for all actions, to avoid replication lag issues

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $env:LOGONSERVER.Substring(2)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Details
Resource details like Room,VideoConference,Whiteboard,..

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Room
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The desired name of the room in the correct naming convention

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

### -OU
The OU to place the specific room in.Standard room ou
is used if parameter is not used

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: OU=Room Mailbox,OU=Exchange,OU=Users,OU=BDB,DC=degroof,DC=be
Accept pipeline input: False
Accept wildcard characters: False
```

### -Seats
The amount of seats in the meeting room

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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
