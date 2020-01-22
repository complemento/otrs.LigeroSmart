
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

    $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "-----------------------",
            );

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