function Send-Email {
    param (
    [Parameter(Mandatory=$false)]
    [string]
    $EmailFrom = 'sccm@billycock.ru',
    [Parameter(Mandatory=$false)]
    [string]
    $EmailTo = 'pestbox@yandex.ru',
    [Parameter(Mandatory=$false)]
    [string]
    $EmailCC,
    [Parameter(Mandatory=$false)]
    [string]
    $SmtpServer = 'smtp.yandex.ru',
    [Parameter(Mandatory=$false)]
    [int]
    $Port = 587,
    [Parameter(Mandatory=$false)]
    [String]
    $EmailCredentialPAssword = 'pgupgugeeeydslnk',
    [Parameter(Mandatory=$false)]
    [string]
    $Attachments,
    [Parameter(Mandatory=$false)]
    [string]
    $PathAttachments
    )
    $EmailCredential = New-Object -TypeName System.Management.Automation.PSCredential $EmailFrom, (ConvertTo-SecureString -String $EmailCredentialPAssword -AsPlainText -Force)
    Send-MailMessage -From $EmailFrom -To $EmailTo -Subject 'Test mail' -SmtpServer $SmtpServer -Credential $EmailCredential -UseSsl -Port $Port
    }
    