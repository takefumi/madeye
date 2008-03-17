package App::MadEye::Plugin::Notify::Email;
use strict;
use warnings;
use base qw/App::MadEye::Plugin::Base/;
use Params::Validate;
use MIME::Lite;
use DateTime;

sub notify : Hook('notify') {
    my ($self, $context, $args) = @_;

    my $conf = $self->{config}->{config};
    my $from_addr = $conf->{from_addr} or die "missing from_addr";
    my $to_addr   = $conf->{to_addr} or die "missing to_addr";

    while (my ($plugin, $results) = each %$args) {
        $plugin =~ s/.+::Agent:://;

        my $mail = MIME::Lite->new(
            'To'        => $from_addr,
            'From'      => $to_addr,
            'Subject'   => "$plugin alert !!!",
            'Data'      => $self->_format( $plugin, $results ),
        );
        # warn $mail->as_string;
        $mail->send;
    }
}

sub _format {
    my ($self, $plugin, $results) = @_;

    my $res = $plugin . "\n\n";
    for my $result (@$results) {
        $res .= "- $result->{target}\n";
        $res .= "$result->{message}\n";
        $res .= "\n\n";
    }
    $res;
}

1;
__END__

=head1 NAME

App::MadEye::Plugin::Notify::Email - notify by email

=head1 SCHEMA

    type: map
    mapping:
        from_addr:
            type: str
            required: yes
        to_addr:
            type: str
            required: yes

=head1 SEE ALSO

L<App::MadEye>, L<MIME::Lite>

