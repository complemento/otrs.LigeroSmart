# --
# Copyright (C) 2001-2017 Complemento - Liberdade e Tecnologia http://www.complemento.net.br
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Admin::Ligero::Elasticsearch::MappingInstall;

use strict;
use warnings;
use Data::Dumper;
use Time::HiRes();

use base qw(Kernel::System::Console::BaseCommand);

our @ObjectDependencies = (
    'Kernel::Config',
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Install Elasticsearch Mappings for all or one specific language.');
    $Self->AddOption(
        Name        => 'LanguageCode',
        Description => "Single language creation.",
        Required    => 0,
        HasValue    => 1,
		ValueRegex  => qr/.*/smx,
    );

    $Self->AddOption(
        Name        => 'AllLanguages',
        Description => "Install all mappings",
        Required    => 0,
        HasValue    => 0,
    );

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

    $Self->Print("<yellow>Creating Elasticsearch Mappings...</yellow>\n");

	if (!$Self->GetOption('LanguageCode') && !$Self->GetOption('AllLanguages')){
		$Self->Print("<yellow>You need to specify at least one option between LanguageCode or AllLanguages.</yellow>\n");
		return $Self->ExitCodeOk();
	}
	if ($Self->GetOption('LanguageCode') && $Self->GetOption('AllLanguages')){
		$Self->Print("<yellow>You need to specify only one option between LanguageCode or AllLanguages.</yellow>\n");
		return $Self->ExitCodeOk();
	}

	my $Index = $Kernel::OM->Get('Kernel::Config')->Get('LigeroSmart::Index');

	# Get all Languages from Config
	my %LanguagesMappings = %{$Kernel::OM->Get('Kernel::Config')->Get('LigeroSmart::Mappings')};
	my @Languages;
	if($Self->GetOption('AllLanguages')){
		@Languages = keys %LanguagesMappings;
	}
	if($Self->GetOption('LanguageCode')){
		push @Languages, $Self->GetOption('LanguageCode');
	}

	# for each language, call IndexCreate
	for my $Lang (@Languages){
		
		my $Body = $JSONObject->Decode(
						Data => $LanguagesMappings{$Lang},
					);

		$Kernel::OM->Get('Kernel::System::LigeroSmart')->IndexCreate(
			Index 	 => $Index,
			Language => $Lang,
			Body  	 => $Body
		);
	}



    $Self->Print("<green>Done.</green>\n");
    return $Self->ExitCodeOk();
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
