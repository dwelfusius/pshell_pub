Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$content = (@"
j.mendez@degroofpetercam.com
jl.boix@degroofpetercam.com
j.faja@degroofpetercam.com
m.senent@degroofpetercam.com
j.mendiri@degroofpetercam.com
compensacion@degroofpetercam.com
o.huguet@degroofpetercam.com
a.petschen@degroofpetercam.com
j.martires@degroofpetercam.com
compliance.sp@degroofpetercam.com
d.gonzalez@degroofpetercam.com
c.calaco@degroofpetercam.com
j.garcia@degroofpetercam.com
a.misse@degroofpetercam.com
d.mateos@degroofpetercam.com
j.viedma@degroofpetercam.com
javier.garcia@degroofpetercam.com
j.aguilera@degroofpetercam.com
a.amoros@degroofpetercam.com
v.aran@degroofpetercam.com
j.asenjo@degroofpetercam.com
i.garcia@degroofpetercam.com
i.arribas@degroofpetercam.com
t.arsuaga@degroofpetercam.com
f.canga@degroofpetercam.com
n.bello@degroofpetercam.com
m.azkargorta@degroofpetercam.com
a.callau@degroofpetercam.com
a.dechurruca@degroofpetercam.com
m.gili@degroofpetercam.com
e.gonzalez@degroofpetercam.com
salas.spain@degroofpetercam.com
g.florensa@degroofpetercam.com
e.escayola@degroofpetercam.com
j.iborra@degroofpetercam.com
jr.casanovas@degroofpetercam.com
d.jaimez@degroofpetercam.com
a.diaz@degroofpetercam.com
d.queipo@degroofpetercam.com
f.loscertales@degroofpetercam.com
i.manzano@degroofpetercam.com
c.lliso@degroofpetercam.com
l.molina@degroofpetercam.com
m.olmeda@degroofpetercam.com
m.mazana@degroofpetercam.com
c.perez@degroofpetercam.com
t.moreiro@degroofpetercam.com
s.mauri@degroofpetercam.com
a.puig@degroofpetercam.com
m.morales@degroofpetercam.com
r.vinas@degroofpetercam.com
dataprivacy-es@degroofpetercam.com
n.roger@degroofpetercam.com
p.rodriguez@degroofpetercam.com
j.santisteban@degroofpetercam.com
c.martinez@degroofpetercam.com
n.sanchez@degroofpetercam.com
a.santos@degroofpetercam.com
c.solera@degroofpetercam.com
d.tevar@degroofpetercam.com
x.vives@degroofpetercam.com
g.viladomiu@degroofpetercam.com
m.vicens@degroofpetercam.com
v.rmingo@degroofpetercam.com
m.vandewalle@degroofpetercam.com
comunicaciondp@degroofpetercam.com
p.castellanos@degroofpetercam.com
p.egana@degroofpetercam.com
b.martinez@degroofpetercam.com
noreply_sp@degroofpetercam.com
m.zumarraga@degroofpetercam.com
m.diaz@degroofpetercam.com
j.soriano@degroofpetercam.com
m.pfaff@degroofpetercam.com
compliance.cos@degroofpetercam.com
personal@degroofpetercam.com
dpscorporatefinance@degroofpetercam.com
suscripcion@degroofpetercam.com
atencion.cliente@degroofpetercam.com
corporate.finance.esp@degroofpetercam.com
seguridaddps@degroofpetercam.com
formacion.spain@degroofpetercam.com
dpspain@degroofpetercam.com
4D@degroofpetercam.com
prevencion@degroofpetercam.com
eventos@degroofpetercam.com
comunicacion@degroofpetercam.com
grtadmin@degroofpetercam.com
nagios@degroofpetercam.com
info.mercados@degroofpetercam.com
dpg.gestion@degroofpetercam.com
operaciones@degroofpetercam.com
bia@degroofpetercam.com
ES-BCN-PN-MEETING-ROOM-01@degroofpetercam.com
ES-BCN-PN-MEETING-ROOM-02@degroofpetercam.com
ES-BCN-PN-MEETING-ROOM-04@degroofpetercam.com
ES-BCN-PN-MEETING-ROOM-05@degroofpetercam.com
ES-BCN-PN-MEETING-ROOM-03@degroofpetercam.com
ES-BCN-PS-MEETING-ROOM-01@degroofpetercam.com
ES-MAD-MEETING-ROOM-06@degroofpetercam.com
ES-MAD-MEETING-ROOM-04@degroofpetercam.com
ES-MAD-MEETING-ROOM-02@degroofpetercam.com
ES-VAL-MEETING-ROOM-01@degroofpetercam.com
ES-MAD-MEETING-ROOM-05@degroofpetercam.com
ES-BIL-MEETING-ROOM-02@degroofpetercam.com
ES-VAL-MEETING-ROOM-03@degroofpetercam.com
ES-MAD-MEETING-ROOM-03@degroofpetercam.com
ES-MAD-MEETING-ROOM-01@degroofpetercam.com
ES-VAL-MEETING-ROOM-02@degroofpetercam.com
ES-BIL-MEETING-ROOM-01@degroofpetercam.com
"@).Split('',[System.StringSplitOptions]::RemoveEmptyEntries)


$list = [system.collections.arraylist]@()

#$content = @("pbadmin","accountsadministration")
foreach ($mailbox in $content) 
{

$mbdetails = Get-MailboxStatistics $mailbox |select displayname,totalitemsize
#$mbfolder =Get-MailboxfolderStatistics $mailbox|measure
#$archdetails = Get-MailboxStatistics $mailbox -Archive |select displayname,totalitemsize
#$archfolder =Get-MailboxfolderStatistics $mailbox|measure

#$mbdetails,$mbfolder.Count,$archdetails,$archfolder.Count |ft
$o = New-Object psobject -Property @{
            "Mailbox" = $mbdetails.displayname
            "MB Size" = $mbdetails.TotalItemSize
            #"MB Folder count" = $mbfolder.Count
                    }
$list.Add($o)
Clear-Variable o
} 
