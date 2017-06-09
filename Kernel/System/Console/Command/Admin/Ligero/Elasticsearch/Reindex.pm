# --
# Copyright (C) 2001-2017 Complemento - Liberdade e Tecnologia http://www.complemento.net.br
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Admin::Ligero::Elasticsearch::Reindex;

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

    $Self->Print("<yellow>Reindexing Elasticsearch Indices...</yellow>\n");

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

	use JSON;		
	# create json object - We cannot use OTRS Json object directly because it sanitize true and false and we get errors from elasticsearch
	
	my $JSONObject = JSON->new();
	$JSONObject->allow_nonref(1);

	# for each language, call IndexCreate
	for my $Lang (@Languages){
			
		# decode JSON encoded to perl structure
		my $Body;
		# use eval here, as JSON::XS->decode() dies when providing a malformed JSON string
		if ( !eval { $Body = $JSONObject->decode( $LanguagesMappings{$Lang} ) } ) {
			$Kernel::OM->Get('Kernel::System::Log')->Log(
				Priority => 'error',
				Message  => 'Decoding the JSON string failed: ' . $@,
			);
			return;
		}
		my $Result = $Kernel::OM->Get('Kernel::System::LigeroSmart')->Reindex(
			Index 	 => $Index,
			Language => $Lang,
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
