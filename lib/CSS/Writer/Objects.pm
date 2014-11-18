use v6;
use CSS::Grammar::AST :CSSObject;

class CSS::Writer::Objects {

    proto write-object( Str $type, Any $ast, Str $units --> Str ) {*}

    multi method write-object( CSSObject::CharsetRule, Any $ast ) {
        ...
    }

    multi method write-object( CSSObject::FontFaceRule, Any $ast ) {
        ...
    }

    multi method write-object( CSSObject::GroupingRule, Any $ast ) {
        ...
    }

    multi method write-object( CSSObject::ImportRule, Any $ast ) {
        ...
    }

    multi method write-object( CSSObject::MarginRule, Any $ast ) {
        ...
    }

    multi method write-object( CSSObject::MediaRule, Any $ast ) {
        ...
    }

    multi method write-object( CSSObject::NamespaceRule, Any $ast ) {
        ...
    }

    multi method write-object( CSSObject::PageRule, Any $ast ) {
        ...
    }

    multi method write-object( CSSObject::RuleSet, Any $ast ) {
        ...
    }

    multi method write-object( CSSObject::RuleList, Any $ast ) {
        ...
    }

    multi method write-object( CSSObject::StyleDeclaration, Any $ast ) {
        ...
    }

    multi method write-object( CSSObject::StyleRule, Any $ast ) {
        ...
    }

    multi method write-object( CSSObject::StyleSheet, Any $ast ) {
        ...
    }

    multi method write-object( Any $type, Any $ast ) is default {
        die "unable to handle type: {$type.perl}, ast: {$ast.perl}"
    }

}
