module lang::muql::ql::Types

import lang::muql::ql::QL;
import Node;

data QLType
  = integer()
  | boolean()
  | money()
  | string()
  | bottom()
  ;
  
QLType qlType((Type)`boolean`) = boolean();
QLType qlType((Type)`string`) = string();
QLType qlType((Type)`integer`) = integer();
QLType qlType((Type)`money`) = money();
  
str type2str(QLType t) = getName(t);