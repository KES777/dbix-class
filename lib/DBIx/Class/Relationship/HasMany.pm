package # hide from PAUSE
    DBIx::Class::Relationship::HasMany;

use strict;
use warnings;

sub has_many {
  my ($class, $rel, $f_class, $cond, $attrs) = @_;

  $class->ensure_class_loaded($f_class);

  unless (ref $cond) {
    my ($pri, $too_many) = $class->primary_columns;
    $class->throw_exception( "has_many can only infer join for a single primary key; ${class} has more" )
      if $too_many;

    my ($f_key,$guess);
    if (defined $cond && length $cond) {
      $f_key = $cond;
      $guess = "caller specified foreign key '$f_key'";
    } else {
      $class =~ /([^\:]+)$/;
      $f_key = lc $1; # go ahead and guess; best we can do
      $guess = "using our class name '$class' as foreign key";
    }

    my $f_class_loaded = eval { $f_class->columns };
    $class->throw_exception("No such column ${f_key} on foreign class ${f_class} ($guess)")
      if $f_class_loaded && !$f_class->has_column($f_key);
      
    $cond = { "foreign.${f_key}" => "self.${pri}" };
  }

  $class->add_relationship($rel, $f_class, $cond,
                            { accessor => 'multi',
                              join_type => 'LEFT',
                              cascade_delete => 1,
                              cascade_copy => 1,
                              %{$attrs||{}} } );
}

1;
