
package Kernel::Modules::IntegrationExample1;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.20 $) [1];

sub new {
    my ( $Integrations, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Integrations );


    #$Integrations  = $Kernel::OM->Get('Kernel::System::SubscriptionPlan');
    $Self->{ValidObject} = $Kernel::OM->Get('Kernel::System::Valid');

    return $Self;
}

sub _GetTemplateData {
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $IntegrationData = {
        Template => $LayoutObject->Output(
                TemplateFile => 'Vue/Integrations/Example1'
            ),
        DataStructure => {
            e6 => 1,
            field1 => 'Field 1',
            field2 => 'Field 2',
            field3 => 'Field 3',
            field4 => 'Field 4',
            field5 => 'Field 5',
            field6 => 'Field 6',
            field7 => 'Field 7',
            field8 => 'Field 8'
        },
        Enable => _CheckStatus()
    };
    return $IntegrationData;
}

sub _CheckStatus {
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my %Integrations = %{ $ConfigObject->Get('Ligero::Integrations') };

    return $Integrations{ExampleIntegration1}->{Enable} == '1'
}

sub Run {
    my ( $Self, %Param ) = @_;
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    # ------------------------------------------------------------ #
    # GetTemplateData
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'GetTemplateData' ) {

        my $IntegrationData = _GetTemplateData();

        my $JSON = $LayoutObject->JSONEncode(
            Data => $IntegrationData,
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=utf8',
            Content     => $JSON || '',
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # ------------------------------------------------------------ #
    # GetTemplateData
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'SetEnable' ) {

        my $Value = $ParamObject->GetParam( Param => 'Value' ) || '';

        my %Integrations = %{ $ConfigObject->Get('Ligero::Integrations') };

        $Integrations{ExampleIntegration1}->{Enable} = $Value;

        my %Setting = $SysConfigObject->SettingGet(
            Name    => 'Ligero::Integrations###ExampleIntegration1',
            Default => 1,
        );

        my $ExclusiveLockGUID = $SysConfigObject->SettingLock(
            UserID    => 1,
            Force     => 1,
            DefaultID => $Setting{DefaultID},
        );

        my $Success = $SysConfigObject->SettingUpdate(
            Name              => 'Ligero::Integrations###ExampleIntegration1',
            EffectiveValue    => $Integrations{ExampleIntegration1},
            ExclusiveLockGUID => $ExclusiveLockGUID,
            UserID            => 1,
        );

        $Success = $SysConfigObject->SettingUnlock(
            UserID    => 1,
            DefaultID => $Setting{DefaultID},
        );

        my %DeploymentResult = $SysConfigObject->ConfigurationDeploy(
            Comments      => "Update Enable Flag",
            UserID        => 1,
            Force         => 1,
            DirtySettings => ['Ligero::Integrations###ExampleIntegration1'],
        );

        my $JSON = $LayoutObject->JSONEncode(
            Data => 1,
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=utf8',
            Content     => $JSON || '',
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # ------------------------------------------------------------ #
    # change
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'GetConfigScreen' ) {
        #my $ID = $ParamObject->GetParam( Param => 'ID' ) || '';

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "CHEGOU AQUI ",

        );

        my $Output .= $LayoutObject->Output(
            TemplateFile => 'Teste1'
        );

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "CHEGOU AQUI 2 ".$Output,

        );

        use Data::Dumper;
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "CHEGOU AQUI 3 ".Dumper($LayoutObject->Attachment(
            ContentType => 'text/html; charset=' . $LayoutObject->{Charset},
            Content     => $Output,
            Type        => 'inline',
            NoCache     => 1,
        )),

        );

        return $LayoutObject->Attachment(
            ContentType => 'text/html; charset=' . $LayoutObject->{Charset},
            Content     => $Output,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # ------------------------------------------------------------ #
    # change
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Change' ) {
        my $ID = $ParamObject->GetParam( Param => 'ID' ) || '';

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminIntegrations',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # change action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ChangeAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminIntegrations',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # add
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Add' ) {

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminIntegrations',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # add action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'AddAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();
        
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminIntegrations',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------
    # overview
    # ------------------------------------------------------------
    #else {
        $Self->_Overview();
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminIntegrations',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
#    }

}

sub _Edit {
    my ( $Self, %Param ) = @_;

    return 1;
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    return 1;
}

1;