use v6;

use CSS::Writer::BaseTypes;

class CSS::Writer::Node
    is CSS::Writer::BaseTypes {

    use CSS::Grammar::CSS3;

    multi method write-node( Str :$at-keyw!, List :$declarations! ) {
        ($.write-node( :$at-keyw ),  $.write-node( :$declarations)).join: ' ';
    }

    multi method write-node( Numeric :$angle!, Any :$units? ) {
        $.write-num( $angle, $units );
    }

    multi method write-node( Str :$at-keyw! ) {
        '@' ~ $.write-node( :ident($at-keyw) );
    }

    multi method write-node( List :$args! ) {
        @$args.map({ $.write($_) }).join: ', ';
    }

    multi method write-node( List :$attrib! ) {
        [~] '[', $attrib.map({ $.write( $_ ) }), ']';
    }

    multi method write-node( Str :$attribute-selector! ) {
        $attribute-selector.lc
    }

    multi method write-node( Str :$charset-rule! ) {
        [~] '@charset ', $.write( 'string' => $charset-rule ), ';'
    }

    multi method write-node( Str :$combinator! ) {
        $combinator.lc
    }

    multi method write-node( Any :$color!, Any :$units? ) {
        $.write-color( $color, $units );
    }

    multi method write-node( Str :$class! is copy ) {
        '.' ~ $.write-node( :name($class) );
    }

    multi method write-node( List :$declarations! ) {
        my @declarations-indented = do {

            $declarations.map: {
                my $prop = .<ident>:exists
                    ?? %(property => $_)
                    !! $_;

                $.write( $prop, :indent(2) );
            }
        };
        ('{', @declarations-indented, $.indent ~ '}').join: $.nl;
    }

    multi method write-node( Str :$element-name! ) {
        given $element-name {
            when '*' {'*'}  # wildcard namespace
            default  { $.write-node( :ident($_) ) }
        }
    }

    multi method write-node( List :$expr! ) {
        my $sep = '';

        [~] @$expr.map( -> $term {

            $sep = '' if $term<op> && $term<op>;
            my $out = $sep ~ $.write($term);
            $sep = $term<op> && $term<op> ne ',' ?? '' !! ' ';
            $out;
        });
    }

    multi method write-node( Hash :$fontface-rule! ) {
        [~] '@font-face ', $.write( $fontface-rule, :node<declarations> );
    }

    multi method write-node( Numeric :$freq!, Any :$units? ) {
        $.write-num( $freq, $units );
    }

    multi method write-node( Hash :$func! is copy ) {
        sprintf '%s(%s)', $.write( $func, :node<ident> ), do {
            when $func<args>:exists {$.write( $func, :node<args> )}
            when $func<expr>:exists {$.write( $func, :node<expr> )}
            default {''};
        }
    }

    multi method write-node( Str :$id! is copy ) {
        '#' ~ $.write-node( :name($id) );
    }

    multi method write-node( Str :$ident! is copy ) {
        my $pfx = $ident ~~ s/^"-"// ?? '-' !! '';
        my $minus = $ident ~~ s/^"-"// ?? '\\-' !! '';
        [~] $pfx, $minus, $.write-node( :name($ident) );
    }

    multi method write-node( Hash :$import! ) {
        [~] '@import ', join(' ', <url media-list>.grep({ $import{$_}:exists }).map({ $.write( $import, :node($_) ) })), ';';
    }

    multi method write-node( Numeric :$int! ) {
        $.write-num( $int );
    }

    multi method write-node( Str :$keyw! ) {
        $keyw.lc;
    }

    multi method write-node( Numeric :$length!, Any :$units? ) {
        $.write-num( $length, $units );
    }

    multi method write-node( List :$media-list! ) {
        join(', ', $media-list.map({ $.write( $_ ) }) );
    }

    multi method write-node( List :$media-query! ) {
        join(' ', $media-query.map({
            my $css = $.write( $_ );

            if .<property> {
                # e.g. color:blue => (color:blue)
                $css = [~] '(', $css.subst(/';'$/, ''), ')';
            }

            $css
        }) );
    }

    multi method write-node( Hash :$media-rule! ) {
        [~] '@media ', <media-list rule-list>.grep({ $media-rule{$_}:exists }).map({ $.write( $media-rule, :node($_) ) });
    }

    multi method write-node( Str :$name! ) {
        [~] $name.comb.map({
            when /<CSS::Grammar::CSS3::nmreg>/    { $_ };
            when /<CSS::Grammar::CSS3::regascii>/ { '\\' ~ $_ };
            default                               { .ord.fmt("\\%X ") }
        });
    }

    multi method write-node( Hash :$namespace-rule! ) {
        join(' ', '@namespace', <ns-prefix url>.grep({ $namespace-rule{$_}:exists }).map({ $.write( $namespace-rule, :node($_) ) })) ~ ';';
    }

    multi method write-node( Str :$ns-prefix! ) {
        given $ns-prefix {
            when ''  {''}   # no namespace
            when '*' {'*'}  # wildcard namespace
            default  { $.write-node( :ident($_) ) }
        }
    }

    multi method write-node( Any :$num! ) {
        $.write-num( $num )
    }

    multi method write-node( Str :$op! ) {
        $op.lc;
    }

    multi method write-node( Hash :$page-rule! ) {
        join(' ', '@page', <pseudo-class declarations>.grep({ $page-rule{$_}:exists }).map({ $.write( $page-rule, :node($_) ) }) );
    }

    multi method write-node( :$percent! ) {
        $.write-num( $percent, '%' );
    }

    multi method write-node( Hash :$property! ) {
        my $expr = $property<expr>:exists
            ?? ': ' ~ $.write($property, :node<expr>)
            !! '';
        my $prio = $property<prio>
            ?? ' !' ~ $property<prio>
            !! '';

        [~] $.write( $property, :node<ident> ), $expr, $prio, ';';
    }

    multi method write-node( Str :$pseudo-class! ) {
        ':' ~ $.write-node( :name($pseudo-class) );
    }

    multi method write-node( Str :$pseudo-elem! ) {
        '::' ~ $.write-node( :name($pseudo-elem) );
    }

    multi method write-node( Hash :$pseudo-func! ) {
        ':' ~ $.write-node( :func($pseudo-func) );
    }

    multi method write-node( Hash :$qname! ) {
        my $out = $.write($qname, :node<element-name>);
        $out = [~] $.write($qname, :node<ns-prefix>), '|', $out
            if $qname<ns-prefix>:exists;
        $out;
    }

    multi method write-node( Numeric :$resolution!, Any :$units? ) {
        $.write-num( $resolution, $units );
    }

    multi method write-node( List :$rule-list! ) {
        ' { ' ~ $rule-list.map( { $.write($_) } ).join($.nl) ~ '}';
    }

    multi method write-node( Hash :$ruleset! ) {
        sprintf "%s %s", $.write($ruleset, :node<selectors>), $.write($ruleset, :node<declarations>);
    }

    multi method write-node( List :$selector! ) {
        $selector.map({ $.write( $_ ) }).join(' ');
    }

    multi method write-node( List :$selectors! ) {
        $selectors.map({ $.write( $_ ) }).join(', ');
    }

    multi method write-node( List :$simple-selector! ) {
        [~] $simple-selector.map({ $.write( $_ ) })
    }

    multi method write-node( Str :$string! ) {
        $.write-string($string);
    }

    multi method write-node( List :$stylesheet! ) {
        my $sep = $.terse ?? "\n" !! "\n\n";
        join($sep, $stylesheet.map({ $.write( $_ ) }) );
    }

    multi method write-node( Numeric :$time!, Any :$units? ) {
        $.write-num( $time, $units );
    }

    multi method write-node( List :$unicode-range! ) {
        my $range;
        my ($lo, $hi) = @$unicode-range.map: {sprintf("%X", $_)};

        if !$lo eq $hi {
            # single value
            $range = sprintf '%x', $lo;
        }
        else {
            my $lo-sub = $lo.subst(/0+$/, '');
            my $hi-sub = $hi.subst(/F+$/, '');

            if $lo-sub eq $hi-sub {
                $range = $hi-sub  ~ ('?' x ($hi.chars - $hi-sub.chars));
            }
            else {
                $range = [~] $lo, '-', $hi;
            }
        }

        'U+' ~ $range;
    }

    multi method write-node( Str :$url! ) {
        sprintf "url(%s)", $.write-string( $url );
    }

    multi method write-node( *%args ) is default {

        use CSS::AST :CSSUnits;
        for %args.keys {
            if my $type = CSSUnits.enums{$_} {
                # e.g. redispatch $.write-node( :px(12) ) as $.write-node( :length(12), :units<px> )
                my %new-args = $type => %args{$_}, units => $_;
                return $.write-node( |%new-args );
            }
        }
        
        die "unable to handle struct: {%args.perl}"
    }
}