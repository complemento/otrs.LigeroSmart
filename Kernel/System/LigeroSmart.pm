# --
# Copyright (C) 2010-2016 Complemento - Liberdade e Tecnologia - http://www.complemento.net.br
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::LigeroSmart;

use Try::Tiny;
use strict;
use warnings;
use Data::Dumper;

use Encode;
use MIME::Base64;
use Kernel::System::VariableCheck qw(IsArrayRefWithData IsHashRefWithData IsStringWithData);

# Ligero Complemento
use Search::Elasticsearch;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::SysConfig',
    'Kernel::System::Cache',
    'Kernel::System::DB',
    'Kernel::System::Log',
    'Kernel::System::Valid',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::JSON',
);

=head1 NAME

Kernel::System::LigeroSmart - LigeroSmart lib

=head1 SYNOPSIS

LigeroSmart functions

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $LigeroSmartObject = $Kernel::OM->Get('Kernel::System::LigeroSmart');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{CacheType} = 'LigeroSmart';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;
    
    $Self->{Config}    = $Kernel::OM->Get('Kernel::Config')->Get('LigeroSmart');

    return $Self;
}




=item Search

Return a hash containing all informations returned by Ligero Smart Server 

    my @Results = $LigeroSmartObject->Search(
        Indexes => 'publicfaq,publicblog', # Optional
        Types => 'posts,pages',          # Optional
        Data => @$%   # Encoded perl data structure that carries json query structure
    );

Returns:

{
   "took": 2,
   "timed_out": false,
   "_shards": {
      "total": 15,
      "successful": 15,
      "failed": 0
   },
   "hits": {
      "total": 1,
      "max_score": 2.8078485,
      "hits": [
         {
            "_index": "sitesmartfit",
            "_type": "sitesmartfit",
            "_id": "AVPuLJGwDa-I-9YdvgAN",
            "_score": 2.8078485,
            "_source": {
               "fieldX": "Complemento is Beatiful",
               "fieldy": "my body bla bla bla"
            }
         }
      ]
   }
}
    
Usage Example:
        my %SearchResultsHash = $Kernel::OM->Get('Kernel::System::LigeroSmart')->Search(
            Indexes => $Indexes,
            Types   => $Types,
            Data    => \%Search,
        );
        
        my @Results = @{ $SearchResultsHash{hits}->{hits} };
        
        for my $Result (@Results){
            $LayoutObject->Block(
                Name => 'Result',
                Data => {
                    %{$Result->{"_source"}},
                },
            );
        }


=cut

sub Search {
    my ( $Self, %Param ) = @_;

    if (!$Self->{Config}->{Nodes}){
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "You must specify at least one node"
        );
        return;
    }

    my $Indexes = $Param{Indexes} || '';
    my $Types   = $Param{Types} || '';

    # Connect
    my @Nodes = @{$Self->{Config}->{Nodes}};
    
    my $e = Search::Elasticsearch->new(
        nodes => @Nodes,
        (trace_to => ['File','/opt/otrs/var/tmp/ligerosearch.log'])
    );    
    
    my @SearchResults;
    
    try {
        @SearchResults = $e->search(
            'index' => $Indexes,
            'type'  => $Types,
            'body'  => {
                %{$Param{Data}}
            }
        );
    } catch {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "error"
        );
    
    }

    
    my %SearchResultsHash;
    
    if(@SearchResults){
        %SearchResultsHash = %{ $SearchResults[0] };    
    }

    return %SearchResultsHash;
}


=item DeleteByQuery

Return a hash containing all informations returned by Ligero Smart Server 

    my @Results = $LigeroSmartObject->DeleteByQuery(
        Indexes => 'publicfaq,publicblog', # Optional
        Types => 'posts,pages',          # Optional
        Data => @$%   # Encoded perl data structure that carries json query structure
    );

Returns:

{
   "took": 2,
   "timed_out": false,
   "total": 0,
   "deleted": 0,
   "batches": 0,
   "version_conflicts": 0,
   "noops": 0,
   "retries": {
      "bulk": 0,
      "search": 0
   },
   "throttled_millis": 0,
   "requests_per_second": -1,
   "throttled_until_millis": 0,
   "failures": []
}
    
Usage Example:
        my %DeletedInformation = $Kernel::OM->Get('Kernel::System::LigeroSmart')->DeleteByQuery(
            Indexes => $Indexes,
            Types   => $Types,
            Data    => \%Search,
        );
        

=cut

sub DeleteByQuery {
    my ( $Self, %Param ) = @_;

    if (!$Self->{Config}->{Nodes}){
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "You must specify at least one node"
        );
        return;
    }

    my $Indexes = $Param{Indexes} || '';
    my $Types   = $Param{Types} || '';

    # Connect
    my @Nodes = @{$Self->{Config}->{Nodes}};
    
    my $e = Search::Elasticsearch->new(
        nodes => @Nodes,
        (trace_to => ['File','/opt/otrs/var/tmp/ligerosearch.log'])
    );    
    
    my $DeletedInformation;
    
    $DeletedInformation = $e->delete_by_query(
            'index' => $Indexes,
            'type'  => $Types,
            'body'  => {
                %{$Param{Body}}
            }
        );

    return $DeletedInformation;
}



=item Index

Index documents on Elasticsearch

    my @Results = $LigeroSmartObject->Index(
        Index   => 'otrs', # Optional
        Type    => 'servicecatalogsearch',          # Optional
        Id      => 'service-xxx' # ID for this object on elasticsearch
        Body    => @$%           # Encoded perl data structure reference which will be used as document body
    );

Returns:

@TODO: Check the return object
    
Usage Example:



=cut

sub Index {
    my ( $Self, %Param ) = @_;

    if (!$Self->{Config}->{Nodes}){
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "You must specify at least one node"
        );
        return;
    }

    for my $Key (qw(Index Type Id Body)) {
        if ( !$Param{$Key} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Key!",
            );
            return;
        }
    }

    my $Index = $Param{Index};
    my $Type  = $Param{Type};
    my $Id    = $Param{Id};
    my $Body  = $Param{Body};

    my %AdditionalOptions;
    if (defined $Param{Pipeline}) 
    {
        $AdditionalOptions{pipeline} = $Param{Pipeline};
    }
    

    # Connect
    my @Nodes = @{$Self->{Config}->{Nodes}};
    
    my $e = Search::Elasticsearch->new(
        nodes => @Nodes,
        (trace_to => ['File','/opt/otrs/var/tmp/ligerosearch.log'])
    );    
    
    my $Result;
    
#    try {
    $Result = $e->index(
        'index'    => $Index,
        'type'     => $Type,
        'id'       => $Id,
        'body'     => {
            %{$Body}
        },
        %AdditionalOptions
    );

#    } catch {
#        $Kernel::OM->Get('Kernel::System::Log')->Log(
#            Priority => 'error',
#            Message  => "error indexing document"
#        );
#        return 0;
#    }

    return $Result;
}

=item FullTicketGet()

Get whole ticket, articles and it's attachments

    my %Ticket = $LigeroElasticsearch->FullTicketGet(
        TicketID    => 12323213, # required
        Attachments => 0 or 1 (default 1)
    );

    returns
    (
        HASH containing whole Ticket structure
    )

=cut

sub FullTicketGet {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(TicketID)) {
        if ( !defined $Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "FullTicketGet: $Needed is Required!"
            );
            return \{}; # return empty hash
        }
    }

    my $Attachments = $Param{Attachments} || 'Yes';
    
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    #get ticket
    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 1,
        Extended      => 1,
        UserID        => 1,
    );

    #encode ticket stuff and remove undefined attributes
    for my $key (keys %Ticket){
        $Ticket{$key}=encode("utf-8", $Ticket{$key});
        delete $Ticket{$key} unless defined($Ticket{$key});
    }

    # get all articles
    my @ArticleBoxRaw = $TicketObject->ArticleGet(
        TicketID          => $Param{TicketID},
        DynamicFields     => 1,
        Extended          => 1,
        UserID            => 1,
    );

  
    if (@ArticleBoxRaw) {
        my @ArticleBox;
        for my $ArticleRaw (@ArticleBoxRaw) {
            my %Article;
            my @DynamicFields;

            # encode everything and remove undefined stuff
            ATTRIBUTE:
            for my $Attribute ( sort keys %{$ArticleRaw} ) {
                $Article{$Attribute} = encode("utf-8", $ArticleRaw->{$Attribute});
                delete $Article{$Attribute} if defined($Ticket{$Attribute});
                delete $Article{$Attribute} unless defined($Article{$Attribute});
            }
            
            if($Attachments eq 'Yes'){
                # get attachment index (without attachments)
                my %AtmIndex = $TicketObject->ArticleAttachmentIndex(
                    ContentPath                => $Article{ContentPath},
                    ArticleID                  => $Article{ArticleID},
                    StripPlainBodyAsAttachment => 3,
                    Article                    => \%Article,
                    UserID                     => 1,
                );

                if (IsHashRefWithData( \%AtmIndex )){
                    my @Attachments;
                    ATTACHMENT:
                    for my $FileID ( sort keys %AtmIndex ) {
                        next ATTACHMENT if !$FileID;
                        my %Attachment = $TicketObject->ArticleAttachment(
                            ArticleID => $Article{ArticleID},
                            FileID    => $FileID,                 # as returned by ArticleAttachmentIndex
                            UserID    => 1,
                        );

                        next ATTACHMENT if !IsHashRefWithData( \%Attachment );

                        # convert content to base64
                        $Attachment{Content} = encode_base64( $Attachment{Content} , '' );
                        push @Attachments, {%Attachment};
                    }

                    # set Attachments data
                    $Article{Attachment} = \@Attachments;            
                }
            }
            push @ArticleBox, \%Article;
        }
        $Ticket{Article} = \@ArticleBox;
    }

    # Force UTF-8
    ## @TODO: Check if it is working right...
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');
    my $JSONString = $JSONObject->Encode(
       Data     => \%Ticket,
    );
    $JSONString = encode("utf-8", $JSONString);
    my $TicketUtf8 = $JSONObject->Decode(
       Data => $JSONString,
    );

    return $TicketUtf8;

}

1;
