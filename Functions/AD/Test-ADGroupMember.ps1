###############################################################################################################
# Filename     :  Test-ADGroupMember
# Autor        :  Julien MAZOYER
# Description  :  Test l'appartenance d'un compte à un groupe
# 
###############################################################################################################
<#
             
    .DESCRIPTION         
    Test l'appartenance d'un compte à un groupe
      
#>
Function Test-ADGroupMember {

Param ($User,$Group)

  Trap {Return "ERROR"}

  If (Get-ADUser -Filter "memberOf -RecursiveMatch '$((Get-ADGroup $Group).DistinguishedName)'" `
            -SearchBase $((Get-ADUser $User).DistinguishedName)

    ) {$true}

    Else {$false}

}