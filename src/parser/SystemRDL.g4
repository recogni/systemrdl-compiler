grammar SystemRDL;

root: (root_elem ';')* EOF;

root_elem : component_def
// TODO   | enum_def
// TODO   | property_def
// TODO   | struct_def
// TODO   | constraint_def
// TODO   | explicit_component_inst
// TODO   | property_assignment
          ;

//------------------------------------------------------------------------------
// Components
//------------------------------------------------------------------------------

component_def : component_named_def ( (component_inst_type component_insts)
                | component_insts?
                )
              | component_anon_def ( (component_inst_type component_insts)
                | component_insts
                )
              | component_inst_type component_named_def component_insts
              | component_inst_type component_anon_def component_insts
              ;


component_named_def : component_type ID param_def? component_body;
component_anon_def  : component_type component_body;

component_body: '{' (component_body_elem ';')* '}';

component_body_elem : component_def
// TODO             | enum_def
// TODO             | struct_def
// TODO             | constraint_def
// TODO             | explicit_component_inst
// TODO             | property_assignment
                    ;

component_insts: param_inst? component_inst (',' component_inst)*;
component_inst: ID ( array_suffix+ | range_suffix )?
                (EQ expr)?
                (AT expr)?
                (INC expr)?
                (ALIGN expr)?
              ;

component_inst_type : kw=(EXTERNAL_kw | INTERNAL_kw);

component_type: component_type_primary
              | kw=SIGNAL_kw
              ;

component_type_primary: kw=( ADDRMAP_kw
                           | REGFILE_kw
                           | REG_kw
                           | FIELD_kw
                           | MEM_kw
                           )
                      ;
//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------
// Parameter definition
param_def: '#' '(' param_def_elem (',' param_def_elem)* ')';
param_def_elem : data_type ID array_type_suffix? (EQ expr)?;

// Parameter assignment list in instantiation
param_inst: '#' '(' param_assignment (',' param_assignment)* ')';
param_assignment: '.' ID '(' expr ')';

//------------------------------------------------------------------------------
// Expressions
//------------------------------------------------------------------------------

expr: op=(PLUS|MINUS|BNOT|NOT|AND|NAND|OR|NOR|XOR|XNOR) expr_primary  #UnaryExpr
    | expr op=EXP expr              #BinaryExpr
    | expr op=(MULT|DIV|MOD) expr   #BinaryExpr
    | expr op=(PLUS|MINUS) expr     #BinaryExpr
    | expr op=(LSHIFT|RSHIFT) expr  #BinaryExpr
    | expr op=(LT|LEQ|GT|GEQ) expr  #BinaryExpr
    | expr op=(EQ|NEQ) expr         #BinaryExpr
    | expr op=AND expr              #BinaryExpr
    | expr op=(XOR|XNOR) expr       #BinaryExpr
    | expr op=OR expr               #BinaryExpr
    | expr op=BAND expr             #BinaryExpr
    | expr op=BOR expr              #BinaryExpr
    | expr '?' expr ':' expr        #TernaryExpr
    | expr_primary                  #NOP
    ;

expr_primary  : literal
              | concatenate
              | replicate
              | paren_expr
              | cast
              | reference
              | struct_literal
              | array_literal
              ;

concatenate   : '{' expr (',' expr)*'}';

replicate     : '{' expr concatenate '}';

paren_expr: '(' expr ')';

cast  : typ=(BOOLEAN_kw|BIT_kw|LONGINT_kw) '\'(' expr ')' #CastType
      | cast_width_expr '\'(' expr ')'               #CastWidth
      ;

cast_width_expr : literal
                | paren_expr
                ;

//------------------------------------------------------------------------------
// Array and Range
//------------------------------------------------------------------------------
range_suffix: '[' expr ':' expr ']';
array_suffix:  '[' expr ']';
array_type_suffix: '[' ']';

//------------------------------------------------------------------------------
// Data Types
//------------------------------------------------------------------------------
data_type : basic_data_type
          | kw=(ACCESSTYPE_kw|ADDRESSINGTYPE_kw|ONREADTYPE_kw|ONWRITETYPE_kw)
          ;

basic_data_type : kw=(BIT_kw|LONGINT_kw) UNSIGNED_kw?
                | kw=(STRING_kw|BOOLEAN_kw|ID)
                ;

//------------------------------------------------------------------------------
// Literals
//------------------------------------------------------------------------------

literal : number
        | string_literal
        | boolean_literal
        | accesstype_literal
        | onreadtype_literal
        | onwritetype_literal
        | addressingtype_literal
        | precedencetype_literal
        | enum_literal
        ;

number : INT        #NumberInt
       | HEX_INT    #NumberHex
       | VLOG_INT   #NumberVerilog
       ;

string_literal  : STRING;

boolean_literal : val=(TRUE_kw|FALSE_kw);

array_literal : '\'{' expr (',' expr )* '}';

struct_literal : ID '\'{' struct_kv (',' struct_kv)* '}';
struct_kv : ID ':' expr ;

enum_literal : ID '::' ID;

accesstype_literal : kw=(NA_kw|RW_kw|WR_kw|R_kw|W_kw|RW1_kw|W1_kw);
onreadtype_literal : kw=(RCLR_kw|RSET_kw|RUSER_kw);
onwritetype_literal : kw=(WOSET_kw|WOCLR_kw|WOT_kw|WZS_kw|WZC_kw|WZT_kw|WCLR_kw|WSET_kw|WUSER_kw);
addressingtype_literal : kw=(COMPACT_kw|REGALIGN_kw|FULLALIGN_kw);
precedencetype_literal : kw=(HW_kw|SW_kw);

//------------------------------------------------------------------------------
// References
//------------------------------------------------------------------------------
reference   : ID // TODO
            ;

//==============================================================================
// Lexer
//==============================================================================

SL_COMMENT : ( '//' ~[\r\n]* '\r'? '\n') -> skip;
ML_COMMENT : ( '/*' .*? '*/' ) -> skip;

//------------------------------------------------------------------------------
// Keywords
//------------------------------------------------------------------------------
BOOLEAN_kw          : 'boolean';
BIT_kw              : 'bit';
LONGINT_kw          : 'longint';
UNSIGNED_kw         : 'unsigned';
STRING_kw           : 'string';
ACCESSTYPE_kw       : 'accesstype';
ADDRESSINGTYPE_kw   : 'addressingtype';
ONREADTYPE_kw       : 'onreadtype';
ONWRITETYPE_kw      : 'onwritetype';



EXTERNAL_kw : 'external';
INTERNAL_kw : 'internal';

ADDRMAP_kw  : 'addrmap';
REGFILE_kw  : 'regfile';
REG_kw      : 'reg';
FIELD_kw    : 'field';
MEM_kw      : 'mem';
SIGNAL_kw   : 'signal';

// Boolean Literals
TRUE_kw : 'true';
FALSE_kw : 'false';

// Special RDL enum-like literals
NA_kw        : 'na';
RW_kw        : 'rw';
WR_kw        : 'wr';
R_kw         : 'r';
W_kw         : 'w';
RW1_kw       : 'rw1';
W1_kw        : 'w1';
RCLR_kw      : 'rclr';
RSET_kw      : 'rset';
RUSER_kw     : 'ruser';
WOSET_kw     : 'woset';
WOCLR_kw     : 'woclr';
WOT_kw       : 'wot';
WZS_kw       : 'wzs';
WZC_kw       : 'wzc';
WZT_kw       : 'wzt';
WCLR_kw      : 'wclr';
WSET_kw      : 'wset';
WUSER_kw     : 'wuser';
COMPACT_kw   : 'compact';
REGALIGN_kw  : 'regalign';
FULLALIGN_kw : 'fullalign';
HW_kw        : 'hw';
SW_kw        : 'sw';

TODO_kw : 'TODO';

//------------------------------------------------------------------------------
// Literals
//------------------------------------------------------------------------------

// Numbers
fragment NUM_BIN : [0-1] [0-1_]* ;
fragment NUM_DEC : [0-9] [0-9_]* ;
fragment NUM_HEX : [0-9a-fA-F] [0-9a-fA-F_]* ;

INT     : NUM_DEC ;
HEX_INT : ('0x'|'0X') NUM_HEX ;
VLOG_INT: [0-9]+ '\'' ( ([bB] NUM_BIN)
                      | ([dD] NUM_DEC)
                      | ([hH] NUM_HEX)
                      )
        ;

fragment ESC : '\\"' | '\\\\' ;
STRING :  '"' (ESC | ~('"'|'\\'))* '"' ;

//------------------------------------------------------------------------------
// Operators
//------------------------------------------------------------------------------

PLUS    : '+' ;
MINUS   : '-' ;
BNOT    : '!' ;
NOT     : '~' ;
BAND    : '&&' ;
NAND    : '~&' ;
AND     : '&' ;
OR      : '|' ;
BOR     : '||' ;
NOR     : '~|' ;
XOR     : '^' ;
XNOR    : '~^' | '^~' ;
LSHIFT  : '<<' ;
RSHIFT  : '>>' ;
MULT    : '*' ;
EXP     : '**' ;
DIV     : '/' ;
MOD     : '%' ;
EQ      : '==' ;
NEQ     : '!=' ;
LEQ     : '<=' ;
LT      : '<' ;
GEQ     : '>=' ;
GT      : '>' ;

AT    : '@';
INC   : '+=';
ALIGN : '%=';

//------------------------------------------------------------------------------
WS  :   [ \t\r\n]+ -> skip ;
ID  :   ('\\')? [a-zA-Z_] [a-zA-Z0-9_]* ;

