codeunit 50102 RSMUSConfigurationCleanup
{
    //This is used to clear settings when a Company or Environment is copied

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    // local procedure EnvironmentCleanup_OnClearCompanyConfig(CompanyName: Text)
    // begin
    //     CleanIntegrationSetup(CompanyName);
    // end;

    // [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    // local procedure CopyCompany_OnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    // begin
    //     CleanIntegrationSetup(NewCompanyName);
    // end;

    // local procedure CleanIntegrationSetup(NewCompanyName: Text[30])
    // begin
    //     //TODO: Update to clear your settings        
    //     //EX:
    //     //      if CompanyName() <> NewCompanyName then
    //     //          IntegrationSetup.ChangeCompany(NewCompanyName);

    //     //      if IntegrationSetup.Get() then begin
    //     //          IntegrationSetup.Validate(EnableOutboundTriggers, false);
    //     //          IntegrationSetup.Validate(ServiceItemURL, '');
    //     //          IntegrationSetup.Modify();
    //     //      end;
    // end;
}