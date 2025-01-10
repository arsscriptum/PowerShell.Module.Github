---
external help file: PowerShell.Module.Github-help.xml
Module Name: PowerShell.Module.Github
online version:
schema: 2.0.0
---

# Sync-UserRepositories

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Sync-UserRepositories [-Username] <String> [-DestinationPath] <String> [[-Exclude] <String[]>]
 [-CreateRootFolder] [-ListOnly] [-Force] [-OpenAfterDownload] [-ShowGitOutput] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

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

### -CreateRootFolder
If set, this flag will make it so that a root folder will be created (named after the user to clone), under which the repositories will be cloned

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: c

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -DestinationPath
Destination directory

```yaml
Type: String
Parameter Sets: (All)
Aliases: d, dst

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Exclude
Excluded repos

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: x

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Force
Overwrite existing directories

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: f

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ListOnly
Simulation: dont clone, just list the operations to do and repositories to clone (equivalent to -WhatIf)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: l

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -OpenAfterDownload
Open file explorer after download

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: o

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ShowGitOutput
More outputs

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Username
Username or owner of the repositories you want to clone

```yaml
Type: String
Parameter Sets: (All)
Aliases: u, usr

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
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

### System.String[]

### System.Management.Automation.SwitchParameter

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
