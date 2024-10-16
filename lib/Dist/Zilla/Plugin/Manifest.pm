package Dist::Zilla::Plugin::Manifest 6.032;
# ABSTRACT: build a MANIFEST file

use Moose;
with 'Dist::Zilla::Role::FileGatherer';

use Dist::Zilla::Pragmas;

use namespace::autoclean;

use Dist::Zilla::File::FromCode;

#pod =head1 DESCRIPTION
#pod
#pod If included, this plugin will produce a F<MANIFEST> file for the distribution,
#pod listing all of the files it contains.  For obvious reasons, it should be
#pod included as close to last as possible.
#pod
#pod This plugin is included in the L<@Basic|Dist::Zilla::PluginBundle::Basic>
#pod bundle.
#pod
#pod =head1 SEE ALSO
#pod
#pod Dist::Zilla core plugins:
#pod L<@Basic|Dist::Zilla::PluginBundle::Manifest>,
#pod L<ManifestSkip|Dist::Zilla::Plugin::ManifestSkip>.
#pod
#pod Other modules: L<ExtUtils::Manifest>.
#pod
#pod =cut

sub __fix_filename {
  my ($name) = @_;
  return $name unless $name =~ /[ '\\]/;
  $name =~ s/\\/\\\\/g;
  $name =~ s/'/\\'/g;
  return qq{'$name'};
}

sub gather_files {
  my ($self, $arg) = @_;

  my $zilla = $self->zilla;

  my $file = Dist::Zilla::File::FromCode->new({
    name => 'MANIFEST',
    code_return_type => 'bytes',
    code => sub {
      my $generated_by = sprintf "%s v%s", ref($self), $self->VERSION || '(dev)';

      return "# This file was automatically generated by $generated_by.\n"
           . join("\n", map { __fix_filename($_) } sort map { $_->name } @{ $zilla->files })
           . "\n",
    },
  });

  $self->add_file($file);
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Plugin::Manifest - build a MANIFEST file

=head1 VERSION

version 6.032

=head1 DESCRIPTION

If included, this plugin will produce a F<MANIFEST> file for the distribution,
listing all of the files it contains.  For obvious reasons, it should be
included as close to last as possible.

This plugin is included in the L<@Basic|Dist::Zilla::PluginBundle::Basic>
bundle.

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

=head1 SEE ALSO

Dist::Zilla core plugins:
L<@Basic|Dist::Zilla::PluginBundle::Manifest>,
L<ManifestSkip|Dist::Zilla::Plugin::ManifestSkip>.

Other modules: L<ExtUtils::Manifest>.

=head1 AUTHOR

Ricardo SIGNES 😏 <cpan@semiotic.systems>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2024 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
