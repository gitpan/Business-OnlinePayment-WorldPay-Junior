package Business::OnlinePayment::WorldPay::Junior;

use 5.006;
use strict;
use warnings;

use DBI;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration       use Business::OnlinePayment::WorldPay::Junior ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw( ) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( new register authorised callback errstr valid_callback_host );
our $VERSION = '1.05';

my %args = ();

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Business::OnlinePayment::WorldPay::Junior - WARNING - This module is deprecated - use Business::WorldPay::Junior instead.

=head1 SYNOPSIS

  use Business::OnlinePayment::WorldPay::Junior;
  
  my $wp = Business::OnlinePayment::WorldPay::Junior->new( db => 'worldpay',
                                                           dbuser => 'wpuser',
                                                           dbpass => 'wppass' );

  my $cartId = undef;
  if ( ! $cartId = $wp->register(\%transaction) )
      {
      die "whatever - " . $wp->errstr;
      }
  
  # Send customer off to Worldpay for processing...
  
  # Get called as a result of the callback
  my %cb = $cgi->Vars;
  
  if ( ! $wp->valid_callback_host($cgi->remote_host) )
      {
      # Security issue - callback can only be from valid WorldPay host
      die "Security warning " . $wp->errstr;
      }
  
  if ( ! $wp->callback(\%cb) )
      {
      # Invalud callback
      die "whatever - " . $wp->errstr;
      }

  if ( ! $wp->authorised() )
      {
      # No authorisation received...
      die "noauth - " . $wp->errstr;
      }

=head1 DESCRIPTION

A simple module that handles transaction tracking and callback management
for the WorldPay Junior service - card payment facility.

=head2 METHODS

=head3 new

To start using Business::OnlinePayment::WorldPay::Junior you need to initialise 
the module in your script using the "new" method like so:

use Business::OnlinePayment::WorldPay::Junior;

my $wp = Business::OnlinePayment::WorldPay::Junior->new( db => 'worldpay',
                                                         dbuser => 'worldpay',
                                                         dbpass => 'wppass',
                                                         host => 'localhost' );

The db, dbuser and dbpass parameters are compulsory and should be the
database that the worldpay table is located within and the mysql username 
and password with select, insert and update privileges on that table.

Optionally you can specify a host parameter to point to the host where the
database is located. If this is not specified it defaults to localhost.

Do remember to test that the call to new succeeded as if you have not
correctly passed the required details it will fail. This does the trick
nicely:

if ( ! $wp )
    {
    # deal with it. Note that there should be an error message in
    # $Business::OnlinePayment::WorldPay::Junior::errstr detailing why it failed.
    }

=head3 register

Once you have initialised the module you can carry on to either register a
new transaction, process a callback or check whether a given transaction has
already been authorised.

To register a new transaction you use the "register" method like so:

my $cartId = $wp->register(\%transaction_details);

As you can see the actual transaction details are passed as a reference to a
hash. The hash typically looks like this:

my %transaction_details = ( amount => 12.50,
                            desc => "A Test Transaction",
                            instId => '99999',
                            currency => 'GBP',
                          );

The details above are the only ones that are necessary to register a new
transaction and all correspond to the standard WorldPay parameters - do
note that they are case sensetive.

The $cartId variable returned should be used for the WorldPay cartId
parameter. It is generated by an auto-incrementing field in the database so
it's pretty much guaranteed to be unique for that database.

Once you have registered your transaction you should send the user to the
WorldPay website for payment - I usually just print a simple page to the
user informing them of the amount owing and what it is for with a simple
"Click here to pay" button. It's a simple HTML form.

=head3 valid_callback_host

To check that the source of the callback is authentic you simply call the 
"valid_callback_host" method like this:

if ( ! $wp->valid_callback_host($cgi->remote_host) )
    {
    # Invalid callback host - handle the error.
    # You should probably bring this security violation to the attention of
    # a real person within your organisation.
    }

Note that remote_host is the CGI method so you need to have the CGI module
loaded for this, which I've assumed you will as you are handling data
provided by that means anyway.

Also note that this module assumes that you are not carrying out reverse
resolution on connections to your web site so it expects a standard IPv4
address - ie something like 192.168.234.12.

If you have specified that there should be a callback password check this in
your script.

=head3 callback

Like the "register" method, detailed above, the "callback" method expects
you to pass the details via a reference to a hash. If you tell the CGI
module that you want to use the functionality of cgi-lib - by using CGI with
qw (:cgi-lib) as an arguement - you can make use of the CGI "Vars" method
which is the easiest way to this this:

my %callback_data = $cgi->Vars;
if ( ! $wp->callback(\%callback_data) )
    {
    # The data supplied in the callback is not valid
    # You can get more information about the problem by calling
    # $wp->errstr which will return an error string
    }

The "callback" method only verifies that the data in the callback is correct
and matches a registered transaction. It does not tell you whether the
transaction was authorised or not.

=head3 authorised

To check whether a transaction was authorised by WorldPay use the
"authorised" method like so:

my $cartId = $cgi->param('cartId); 
if ( ! $wp->authorised($cartId) )
    {
    # This transaction was NOT authorised
    }

=head2 DEPENDANCIES

This module requires MySQL for the backend data store and depends upon DBI
and DBD::mysql to talk to it. 

There are no other dependancies.

=head1 AUTHOR

Jason Clifford, E<lt>jason@jasonclifford.comE<gt>

=head1 LICENSE

This module is licensed under the terms of the Free Software Foundations Gnu
Public License (GPL) version 2.

See the accompanying COPYING file for specific details of the license.

Note that you may not alter, copy or redistribute this module except in
accordance with the terms of the GPL license.

=head1 SEE ALSO

The WorldPay support website (at http://support.worldpay.com/) for more
details about the Select Junior service.

L<perl>.

=cut

sub new
    {
    my $self;
    ($self, %args) = @_;
    
    # Verify that the required db access details are provided.
    if ( ! defined $args{db} || ! defined $args{dbuser} || ! defined $args{dbpass} )
        {
        $errstr = "Required Database connection details missing";
        return;
        }
    my $class = ref($self) || $self;
    return bless {}, $class;
    }

sub callback
    {
    # verifies the validity of data supplied via the callback facility.

    my $self = shift;
    my $hr_callback = shift;	# Hash of the values returned by callback
    
    # Are all the mandatory callback fields present and all data valid?

    my %required = ( instId => 1,
                     cartId => 1,
                     desc => 1,
                     transStatus => 1,
                   );
    
    my %rules = ( instId => '\d+',
                  cartId => '\d+',
                  currency => '(GBP|EUR|USD)',
                  amount => '[\d\.]+',
                  desc => '[[:print:]]+',
                  testMode => '(0|100|101)',
                  name => '[[:print:]]{0,40}',
                  address => '[[:print:]]{0,255}',
                  postcode => '[[:print:]]{0,12}',
                  country => '[A-Z]{2}',
                  tel => '[[:print:]]{0,30}',
                  fax => '[[:print:]]{0,30}',
                  email => '[[:print:]]{0,80}',
                  transId => '\d{1,16}',
                  futurePayId => '\d{1,16}',
                  transStatus => '(Y|C)',
                  transTime => '\d+',
                  authAmount => '[\d\.]+',
                  authCurrency => '(GBP|EUR|USD)',
                  cardType => '[[:print:]]+',
                  AVS => '\d{4}',
                );
                  
    my @fields = ( keys %rules );

    if ( $hr_callback->{transStatus} eq 'Y' )
        {
        $required{authCurrency} = 1;
        $required{authAmount} = 1;
        $required{transTime} = 1;
        $required{transId} = 1;
        }
    
    foreach my $field (@fields)
        {
        if ( defined $required{$field} && ! $hr_callback->{$field} )
            {
            $errstr = "mandatory field $field is missing";
            return;
            }
        next if ! $hr_callback->{$field};

        if ( $hr_callback->{$field} !~ m/^$rules{$field}$/i )
            {
            $errstr = "field $field invalid";
            return;
            }
        }
    
    # retrieve the stored details for the transaction
    my $rdb = $self->db_connect;
    my $sql = sprintf "SELECT instId, currency, amount, description, testMode FROM worldpay WHERE cartId = %s", $rdb->quote($hr_callback->{cartId});
    my $sth = $rdb->prepare($sql);
    if ( ! $sth )
        {
        $errstr = "not able to prepare $sql";
        $sth->finish;
        $rdb->disconnect if $rdb;;
        return;
        }
    if ( ! $sth->execute )
        {
        $errstr = "not able to execute prepared $sql";
        $sth->finish;
        $rdb->disconnect if $rdb;;
        return;
        }
        
    my $hr_trans = $sth->fetchrow_hashref();
    if ( ! $hr_trans )
        {
        $errstr = "no data in database - $sql -\n";
        $sth->finish;
        $rdb->disconnect if $rdb;;
        return;
        }
    
    # Is the payment correct?
    my $fail = undef;	# flag to indicate that callback does not match
			# stored transaction details
			
    $fail = 1 if $hr_trans->{instId} != $hr_callback->{instId};
    $fail = 1 if $hr_trans->{testMode} != $hr_callback->{testMode};
    $fail = 1 if $hr_trans->{description} ne $hr_callback->{desc};

    # If the transaction was cancelled that's all we'll have so we need
    # to test for that now and act accordingly.

    if ( $hr_callback->{transStatus} ne 'Y' )
        {
        # The transaction was cancelled.
        # Update the db to indicate this and return false
        $sql = sprintf "UPDATE worldpay SET transStatus = 'C' WHERE cartId = %s", $rdb->quote($hr_callback->{cartId});
        eval ( $rdb->do($sql) );
        if ( $@ )
            {
            $errstr = "transaction failed - unable to update DB!";
            $rdb->disconnect if $rdb;;
            return;
            }
        $rdb->disconnect if $rdb;;
        return 1;	# Database updated to reflect transaction cancelled.
        		# call $self->authorised() for a true/false on auth
        }

    $fail = 1 if $hr_trans->{amount} != $hr_callback->{amount};
    $fail = 1 if $hr_trans->{currency} ne $hr_callback->{currency};
    
    if ( $fail )
        {
        $errstr = "db and callback mismatch";
        $sth->finish;
        $rdb->disconnect if $rdb;;
        return;
        }

    $sth->finish;
    
    # At this point we know that the transaction does match the callback.
    # We also know that the desc and instId fields are correct and that the
    # transaction was authorised
    
    # Before we test anything else we need to double check the transaction.
    
    if ( $hr_callback->{transStatus} eq 'Y' )
        {
        # We need to check the amount and currency fields to verify the transaction
        
        if ( $hr_trans->{currency} ne $hr_callback->{authCurrency} )
            {
            # check to see whether the transaction is in another currency
            # and if so whether the amount is correct after exchange rate
            # calculations.
            if ( ! &exchange_rate( $hr_trans, $hr_callback ) )
                {
                $errstr = "Invalid transaction. Amount paid either insufficient or no exchange rate date available";
                return undef;
		}
            }
        
        # OK the payment has been accepted and is sufficient. We're happy.
        # Record the payment details and return true.
        
        # Take the values from the callback that we care about and store them
        # in the database.

        my $count = 1;
        my $sql = "UPDATE worldpay SET";
        foreach (@fields)
            {
            next if $_ =~ /(desc|cartId|amount|currency|instId)/;
            next if ! defined $hr_callback->{$_};
            $sql .= "," if $count > 1;
            $sql .= " $_ = " . $rdb->quote($hr_callback->{$_});
            $count++;
            }
        $sql .= " WHERE cartId = " . $rdb->quote($hr_callback->{cartId});
        eval ( $rdb->do($sql) );
        if ( $@ )
            {
            $errstr = "transaction authorised - unable to update DB!";
            $rdb->disconnect if $rdb;;
            return;
            }
        $rdb->disconnect if $rdb;;
        return 1;
        }
    }

sub valid_callback_host
    {
    # Input is output from $cgi->remote_host
    # Output is true is remote_host is a valid WorldPay callback server
    # or false if it is not.

    my $self = shift;
    my $host = shift;
    
    $errstr = "no host", return if ! $host;
    $errstr = "not 4 . separated digits", return if $host !~ /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/;

    my $fail = undef;

    if ( $1 != 195 )
        {
        $fail = 1;
        $errstr .= "Octet 1 failed ";
        }
    if ( $2 != 35 )
        {
        $fail = 1;
        $errstr .= "Octet 2 failed ";
        }
    if ( $3 < 90 || $3 > 91 )
        {
        $fail = 1;
        $errstr .= "Octet 3 failed ";
        }
    if ( $4 < 1 || $4 > 254 )
        {
        $fail = 1;
        $errstr .= "Octet 4 failed ";
        }
    return if $fail;
    
    return 1;
    }

sub register
    {
    # register a new transaction prior to sending it to Worldpay
    # takes transaction details and returns a transaction ID string
    # to uniquely identify the transaction which should be used as
    # transId for Worldpay
    
    my $self = shift;
    my $hr_trans = shift;	# Details of the transaction
    
    # Are all required fields present?
    my %required = ( instId => 1,
                     currency => 1,
                     amount => 1,
                     desc => 1,
                   );
    
    my %rules = ( instId => '\d+',
                  currency => '(GBP|EUR|USD)',
                  amount => '[\d\.]+',
                  desc => '[[:print:]]+',
                  testMode => '(0|100|101)',
                 );

    my @fields = qw ( instId currency amount desc testMode );
    
    if ( ! defined $hr_trans->{testMode} )
        {
        $hr_trans->{testMode} = '0';
        }
    
    foreach my $field (@fields)
        {
        if ( defined $required{$field} && ! $hr_trans->{$field} )
            {
            $errstr = "mandatory field $field is missing";
            return;
            }
        next if ! $hr_trans->{$field};

        if ( $hr_trans->{$field} !~ m/^$rules{$field}$/i )
            {
            $errstr = "field $field invalid";
            return;
            }
        }

    # Insert into database
    my $rdb = $self->db_connect();
    if ( ! $rdb )
        {
        $errstr = "unable to connect to backend db";
        return;
        }
    my $sql = sprintf "insert into worldpay (instId, currency, amount, description, testMode) values (%s, %s, %s, %s, %s)",
              $rdb->quote($hr_trans->{instId}), $rdb->quote($hr_trans->{currency}), $rdb->quote($hr_trans->{amount}), $rdb->quote($hr_trans->{desc}), $rdb->quote($hr_trans->{testMode});
    
    eval ( $rdb->do($sql) );
    if ( $@ )
        {
        $errstr = "cannot update db - " . $rdb->errstr;
        $rdb->disconnect;
        return;
        }

    # Obtain transaction ID
    my $cartId = $rdb->{'mysql_insertid'};
    $rdb->disconnect;    
    
    # Return the transaction ID
    return $cartId;
    }

sub authorised
    {
    # Check to see whether a registered transaction has been authorised by Worldpay
    my $self = shift;
    my $cartId = shift;	# Unique ID per transaction
    
    return if ! $cartId;
    
    # Lookup authorised status for transaction in database 
    my $rdb = $self->db_connect();
    
    my $sql = sprintf "select transStatus from worldpay where cartId = %s", $rdb->quote($cartId);
    my $sth = $rdb->prepare($sql);
    if ( ! $sth )
        {
        $errstr = "unable to access database - ". $rdb->errstr;
        $rdb->disconnect;
        return;
        }
    if ( ! $sth->execute )
        {
        $errstr = "unable to access database - ". $rdb->errstr;
        $rdb->disconnect;
        return;
        }
    my @res = $sth->fetchrow_array;
    $sth->finish;
    $rdb->disconnect;
    if ( ! $res[0] )
        {
        return;
        }
    else
        {
        # If transStatus is Y return true
        return if $res[0] ne "Y";
        return 1;
        }
    }

sub errstr
    {
    my $self = shift;
    return $errstr;
    }

sub exchange_rate
    {
    # Input is references to transaction and callback hashes.
    
    # Checks to see whether they paid amount satisfies the debt or is
    # close enough (5% tolerance of underpayment - overpayment we're happy
    # with!)
    
    my $hr_trans = shift;
    my $hr_callback = shift;

    # First we need to retrieve the relevant exchange rate for today
    # from the database (which is updated from cron hourly).
    
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($hr_callback->{transTime}/1000);
    my $date = $mday . "-" . $mon+1 . "-" . $year+1900;

    my $rdb = $self->db_connect();

    my $sql = sprintf "select rate from wprates where base=%s and where cur=%s and where date=%s", $rdb->quote($hr_trans->{currency}), $rdb->quote(hr_callback->{authCurrency}), $date;
    my $sth = $rdb->prepare($sql);
    if ( ! $sth )
        {
        $errstr = "Cannot connect to db to get exchange rates";
        return;
        }
    if ( ! $sth->execute )
        {
        $errstr = "Cannot execure query to get exchange rates";
        return;
        }
    my @res = $sth->fetchrow_array;
    if ( ! $res[0] )
        {
        $errstr = "No exchange rates available";
        return;
        }

    $sth->finish;
    $rdb->disconnect;
    
    # OK we have the rate. The calculation is :
    # $hr_trans->{amount} == $hr_callback->{authAmount}) / rate

    # We only want 2 significant decimal places
    my $paid = sprintf "%.2f", $hr_callback->{authAmount} / $row[0];
    
    if ( $hr_trans->{amount} == $paid )
        {
        # Exact match.
        return 1;
        }
    else
        {
        # See if the difference is within an acceptable tolerance level
        # Tolerance level is set at 5%

        my $difference = $paid - $hr_trans->{amount};

        # If there is an underpayment $difference will be a negative value.
        if ( $difference >= 0 )
            {
            # Overpayment - which is OK
            return 1;
            }
        if ( ! $difference < -($hr_trans->{amount} * 0.05) )
            {
            # Acceptable difference
            return 1;
            }
        return undef;
        }
    }

sub db_connect
    {
    # Defines for connection to database backend
    my $driver = "mysql";
    my $host="localhost";
    $host = $args{host} if defined $args{host};
    my $database=$args{db};
    my $user=$args{dbuser};
    my $password=$args{dbpass};

    my $dsn ="DBI:$driver:database=$database;host=$host";

    my $dbh = DBI->connect($dsn, $user, $password)
              || die "Cannot connect to database Error: $!";
    return $dbh;

    }
