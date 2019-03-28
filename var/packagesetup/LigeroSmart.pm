# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package var::packagesetup::LigeroSmart;

use strict;
use warnings;

use Kernel::Output::Template::Provider;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::DynamicField',
    'Kernel::System::Log',
    'Kernel::System::State',
    'Kernel::System::Stats',
    'Kernel::System::SysConfig',
    'Kernel::System::Type',
    'Kernel::System::Valid',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}


sub CodeInstall {
    my ( $Self, %Param ) = @_;

    #$Self->_CreateDynamicFields();
	#$Self->_UpdateConfig();
    $Self-> _CreateWebServices();
    return 1;
}

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    #$Self->_CreateDynamicFields();
    $Self->_CreateWebServices();
    #$Self->_UpdateConfig();
	
    return 1;
}

sub _UpdateConfig {
    my ( $Self, %Param ) = @_;

    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');
#    my @Configs = (
#        {
#            ConfigItem => 'CustomerFrontend::CommonParam###Action',
#            Value 	   => 'CustomerServiceCatalog'
#        },
#    );

#    CONFIGITEM:
#    for my $Config (@Configs) {
#        # set new setting,
#        my $Success = $SysConfigObject->ConfigItemUpdate(
#            Valid => 1,
#            Key   => $Config->{ConfigItem},
#            Value => $Config->{Value},
#        );

#    }

    return 1;
}

sub _CreateDynamicFields {
    my ( $Self, %Param ) = @_;

    my $ValidID = $Kernel::OM->Get('Kernel::System::Valid')->ValidLookup(
        Valid => 'valid',
    );

    # get all current dynamic fields
    my $DynamicFieldList = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid => 0,
    );

    # get the list of order numbers (is already sorted).
    my @DynamicfieldOrderList;
    for my $Dynamicfield ( @{$DynamicFieldList} ) {
        push @DynamicfieldOrderList, $Dynamicfield->{FieldOrder};
    }

    # get the last element from the order list and add 1
    my $NextOrderNumber = 1;
    if (@DynamicfieldOrderList) {
        $NextOrderNumber = $DynamicfieldOrderList[-1] + 1;
    }

    # get the definition for all dynamic fields for ITSM
    my @DynamicFields = $Self->_GetITSMDynamicFieldsDefinition();

    # create a dynamic fields lookup table
    my %DynamicFieldLookup;
    DYNAMICFIELD:
    for my $DynamicField ( @{$DynamicFieldList} ) {
        next DYNAMICFIELD if ref $DynamicField ne 'HASH';
        $DynamicFieldLookup{ $DynamicField->{Name} } = $DynamicField;
    }

    # create or update dynamic fields
    DYNAMICFIELD:
    for my $DynamicField (@DynamicFields) {

        my $CreateDynamicField;

        if ( ref $DynamicFieldLookup{ $DynamicField->{Name} } eq 'HASH' ) {
            # Deletes DF
            my $DynamicFieldID = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldGet(
                                       Name => $DynamicField->{Name},
                                    );
            if ($DynamicFieldID->{ID}){
                  my $Success = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldDelete(
                   ID      => $DynamicFieldID->{ID},
                   UserID  => 1,
                   Reorder => 1,               # or 0, to trigger reorder function, default 1
               );
            }
        }

        # check if new field has to be created
#        if ($CreateDynamicField) {


            # create a new field
            my $FieldID = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldAdd(
                InternalField => 1,
                Name          => $DynamicField->{Name},
                Label         => $DynamicField->{Label},
                FieldOrder    => $NextOrderNumber,
                FieldType     => $DynamicField->{FieldType},
                ObjectType    => $DynamicField->{ObjectType},
                Config        => $DynamicField->{Config},
                ValidID       => $ValidID,
                UserID        => 1,
            );
            next DYNAMICFIELD if !$FieldID;

            # increase the order number
            $NextOrderNumber++;
#        }
    }

    return 1;
}

sub _GetITSMDynamicFieldsDefinition {
    my ( $Self, %Param ) = @_;

    # define all dynamic fields for ITSM
    my @DynamicFields = (
        #{
            #Name       => 'LigeroIndexUpdate',
            #Label      => 'LigeroIndexUpdate',
            #FieldType  => 'Text',
            #ObjectType => 'Ticket',
            #Config     => {
                #DefaultValue   => '',
            #},
        #},
    );

    return @DynamicFields;
}

sub _CreateWebServices {
    my ( $Self, %Param ) = @_;

    #Verify if it already exists
    my $List             = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice')->WebserviceList();
    my %WebServiceLookup = reverse %{$List};
    my $Name = 'LigeroTicketIndexer';
    if ( $WebServiceLookup{$Name} ) {
        return 1;
    }

    # if doesn't exists
    my $YAML = <<"_END_";
---
Debugger:
  DebugThreshold: error
  TestMode: '0'
Description: ''
FrameworkVersion: 5.0.7
Provider:
  Operation: {}
  Transport:
    Type: ''
RemoteSystem: ''
Requester:
  Invoker:
    LigeroTicketIndexer:
      Description: ''
      Events:
      - Asynchronous: '1'
        Event: TicketServiceUpdate
      - Asynchronous: '1'
        Event: TicketTitleUpdate
      - Asynchronous: '1'
        Event: TicketQueueUpdate
      - Asynchronous: '1'
        Event: ArticleCreate
      MappingInbound:
        Type: Simple
      MappingOutbound:
        Type: Simple
      Type: LigeroSmart::LigeroSmartIndexer
  Transport:
    Config:
      DefaultCommand: PUT
      Host: http://localhost:9200
      InvokerControllerMapping:
        LigeroTicketIndexer:
          Command: PUT
          Controller: /:Index/doc/:TicketID?pipeline=:pipeline
    Type: HTTP::REST
_END_

    my $Config = $Kernel::OM->Get('Kernel::System::YAML')->Load( Data => $YAML );

    # add new web service
    my $ID = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice')->WebserviceAdd(
        Name    => 'LigeroTicketIndexer',
        Config  => $Config,
        ValidID => 1,
        UserID  => 1,
    );

    return 1;   
}
