package Dist::Zilla::Plugin::CPANFile 6.032;
# ABSTRACT: produce a cpanfile prereqs file

use Moose;
with 'Dist::Zilla::Role::FileGatherer';

use Dist::Zilla::Pragmas;

use namespace::autoclean;

use Dist::Zilla::File::FromCode;

#pod =head1 SYNOPSIS
#pod
#pod     # dist.ini
#pod     [CPANFile]
#pod
#pod =head1 DESCRIPTION
#pod
#pod This plugin will add a F<cpanfile> file to the distribution.
#pod
#pod =attr filename
#pod
#pod If given, parameter allows you to specify an alternate name for the generated
#pod file.  It defaults, of course, to F<cpanfile>.
#pod
#pod     # dist.ini
#pod     [CPANFile]
#pod     filename = dzil-generated-cpanfile
#pod
#pod =attr comment
#pod
#pod If given, override the default C<cpanfile> header comment with your own. The default comment
#pod explains that this file was generated by Dist::Zilla and tells users to edit the dist.ini
#pod file to change prereqs
#pod
#pod     # dist.ini
#pod     [CPANFile]
#pod     comment = This file is generated by Dist::Zilla
#pod     comment = Prereqs are detected automatically. You do not need to edit this file
#pod
#pod =head1 SEE ALSO
#pod
#pod =for :list
#pod * L<Module::CPANfile>
#pod * L<Carton>
#pod * L<cpanm>
#pod
#pod =cut

has filename => (
  is  => 'ro',
  isa => 'Str',
  default => 'cpanfile',
);

sub mvp_multivalue_args { qw( comment ) }

has comment => (
  is => 'ro',
  isa => 'ArrayRef[Str]',
  default => sub {
    [
      qq{This file is generated by Dist::Zilla::Plugin::CPANFile v}
        . ( $Dist::Zilla::Plugin::CPANFile::VERSION // '<internal>' ),
      qq{Do not edit this file directly. To change prereqs, edit the `dist.ini` file.},
    ]
  }
);

sub _hunkify_hunky_hunk_hunks {
  my ($self, $indent, $type, $req) = @_;

  my $str = '';
  for my $module (sort $req->required_modules) {
    my $vstr = $req->requirements_for_module($module);
    $str .= qq{$type "$module" => "$vstr";\n};
  }
  $str =~ s/^/'  ' x $indent/egm;
  return $str;
}

sub gather_files {
  my ($self, $arg) = @_;

  my $zilla = $self->zilla;

  my $file  = Dist::Zilla::File::FromCode->new({
    name => $self->filename,
    code => sub {
      my $prereqs = $zilla->prereqs;

      my @types  = qw(requires recommends suggests conflicts);
      my @phases = qw(runtime build test configure develop);

      my $str = join "\n", ( map { "# $_" } @{ $self->comment } ), '', '';
      for my $phase (@phases) {
        for my $type (@types) {
          my $req = $prereqs->requirements_for($phase, $type);
          next unless $req->required_modules;
          $str .= qq[\non '$phase' => sub {\n] unless $phase eq 'runtime';
          $str .= $self->_hunkify_hunky_hunk_hunks(
            ($phase eq 'runtime' ? 0 : 1),
            $type,
            $req,
          );
          $str .= qq[};\n]                     unless $phase eq 'runtime';
        }
      }

      return $str;
    },
  });

  $self->add_file($file);
  return;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Plugin::CPANFile - produce a cpanfile prereqs file

=head1 VERSION

version 6.032

=head1 SYNOPSIS

    # dist.ini
    [CPANFile]

=head1 DESCRIPTION

This plugin will add a F<cpanfile> file to the distribution.

=head1 PERL VERSION

This module should work on any version of perl still receiving updates from
the Perl 5 Porters.  This means it should work on any version of perl
released in the last two to three years.  (That is, if the most recently
released version is v5.40, then this module should work on both v5.40 and
v5.38.)

Although it may work on older versions of perl, no guarantee is made that the
minimum required version will not be increased.  The version may be increased
for any reason, and there is no promise that patches will be accepted to
lower the minimum required perl.

=head1 ATTRIBUTES

=head2 filename

If given, parameter allows you to specify an alternate name for the generated
file.  It defaults, of course, to F<cpanfile>.

    # dist.ini
    [CPANFile]
    filename = dzil-generated-cpanfile

=head2 comment

If given, override the default C<cpanfile> header comment with your own. The default comment
explains that this file was generated by Dist::Zilla and tells users to edit the dist.ini
file to change prereqs

    # dist.ini
    [CPANFile]
    comment = This file is generated by Dist::Zilla
    comment = Prereqs are detected automatically. You do not need to edit this file

=head1 SEE ALSO

=over 4

=item *

L<Module::CPANfile>

=item *

L<Carton>

=item *

L<cpanm>

=back

=head1 AUTHOR

Ricardo SIGNES 😏 <cpan@semiotic.systems>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2024 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut