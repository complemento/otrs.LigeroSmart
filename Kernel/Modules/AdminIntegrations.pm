
package Kernel::Modules::AdminIntegrations;

use strict;
use warnings;
use Data::Dumper;
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
    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    # ------------------------------------------------------------ #
    # GetIntegrationList
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'GetIntegrationList' ) {
        my %Integrations = %{ $ConfigObject->Get('Ligero::Integrations') };

        


        my @ArrayIntegrations = ();
        while ((my $key, my $value) = each (%Integrations))
        {
            my %Setting = $SysConfigObject->SettingGet(
                Name    => 'Ligero::Integrations###'.$key,
                Default => 1,
            );

            if($Setting{IsValid}){
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "------------------ ".$value->{Image},
                );
                $value->{Image} = $value->{Image} // 'https://blog.wildix.com/wp-content/uploads/2018/09/Determining-Integration-Requirements.png';
                $value->{flex} = 3;
                $value->{Enable} = $value->{Enable} == '1';
                push @ArrayIntegrations, $value;
            }
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