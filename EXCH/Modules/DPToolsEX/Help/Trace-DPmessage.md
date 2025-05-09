---
external help file: DpToolsEX-help.xml
Module Name: DPToolsEX
online version:
schema: 2.0.0
---

# Trace-DPmessage

## SYNOPSIS
A wrapper for Get-Messagetracking adding some handy defaults for
speedy querying on the entire exchange farm

## SYNTAX

### NoMisc (Default)
```
Trace-DPmessage [-Start <Object>] [-Hour <Object>] [-Sender <String>] [-Recipients <Object>]
 [-ResultSize <Object>] [-MessageSubject <Object>] [-Window <Int32>] [-JournalMails] [<CommonParameters>]
```

### Advanced
```
Trace-DPmessage [-Sender <String>] [-Recipients <Object>] [-ResultSize <Object>] [-MessageSubject <Object>]
 [-Misc <Hashtable>] [-JournalMails] [<CommonParameters>]
```

## DESCRIPTION
This command will, when ran with no parameters, return all email traffic 
without the journaling entries for the current day starting at 00:00.

## EXAMPLES

### Example 1
```powershell
PS C:\> Trace-DPmessage -Sender s.teriba@dgp.com -Hour 9 -Window 2 -JournalMails
```

This will find all mails sent by s.teriba@dgp.com today from 
9:00 to 11:00, including the journal mails

### Example 2
```powershell
PS C:\> Trace-DPmessage -Recipients s.teriba@dgp.com -Start 5/5/2022
```

This will find all mails received by s.teriba@dgp.com on 5/5/2022 from 
00:00 to 23:59, filtering out the journal mails

### Example 3
```powershell
PS C:\> Trace-DPmessage -Recipients s.teriba@dgp.com -MessageSubject help -Misc @{Start='4/24/2022 15:00';EventId='Agentinfo'}
```

This will find all mails with eventid AGENTINFO received by s.teriba@dgp.com 
with subject containing help from 24/4/2022 15:00 (US date notation on our 
exchange servers) up until now

## PARAMETERS

### -Hour
The time of day to start the search in a 0 to 23 format.

```yaml
Type: Object
Parameter Sets: NoMisc
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -JournalMails
When used it will not filter out the journal mails and show them as well

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MessageSubject
The subject or part of it you want to look for 

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Misc
A hashtable allowing the splatting of all parameters accepted by Get-Messagetracking.

```yaml
Type: Hashtable
Parameter Sets: Advanced
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recipients
Recipient of the searched mails

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResultSize
Maximum returned results per server

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 'Unlimited'
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sender
Sender of the searched mails

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Start
The desired start date in a format of d/MM/yyyy

```yaml
Type: Object
Parameter Sets: NoMisc
Aliases: Date

Required: False
Position: Named
Default value: (Get-Date -Format 'd/M/yyyy')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Window
The period of time in hours to search, starting from the Start + Hour combo.

```yaml
Type: Int32
Parameter Sets: NoMisc
Aliases:

Required: False
Position: Named
Default value: 24
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Int32

## NOTES

## RELATED LINKS
