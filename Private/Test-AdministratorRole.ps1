function Test-AdministratorRole
{
    ([security.principal.windowsprincipal][security.principal.windowsidentity]::GetCurrent()).IsInRole([security.principal.windowsbuiltinrole]"Administrator")
}
