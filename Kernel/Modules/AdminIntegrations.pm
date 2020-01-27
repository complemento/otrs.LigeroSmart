
package Kernel::Modules::AdminIntegrations;

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

sub Run {
    my ( $Self, %Param ) = @_;
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # ------------------------------------------------------------ #
    # change
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'GetIntegrationList' ) {
        my %Integrations = %{ $ConfigObject->Get('Ligero::Integrations') };

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Integration List ",

        );

        my @ArrayIntegrations = ();
        while ((my $key, my $value) = each (%Integrations))
        {
            $value->{src} = 'https://blog.wildix.com/wp-content/uploads/2018/09/Determining-Integration-Requirements.png';
            $value->{flex} = 3;
            $value->{Template} = $LayoutObject->Output(
                TemplateFile => 'Vue/Integrations/'.$value->{Template}
            );
            push @ArrayIntegrations, $value;
        }

        my $JSON = $LayoutObject->JSONEncode(
            Data => \@ArrayIntegrations,
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