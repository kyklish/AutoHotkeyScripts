# Tasks with Commands
$tasklist = @()
Get-ScheduledTask | ForEach-Object {
    $task = [xml](Export-ScheduledTask -TaskName $_.URI)
    $taskdetails = New-Object -Type Psobject -Property @{
        "Name" =  $_.URI
        "Action" = $task.Task.Actions.Exec.Command
   }
   $tasklist += $taskdetails
}
$tasklist | select Name,Action | Out-GridView -Wait
