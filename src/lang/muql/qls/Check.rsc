module lang::muql::qls::Check

import lang::muql::ql::QL;
import lang::muql::qls::QLS;
import Message;
import ParseTree;
import List;
import Map;

/*
 To check:
 - referenced questions exist in questionnaire
 - all questions are placed
 - no duplicate placement of questions
*/


set[Message] check(Stylesheet s, Form f) {
  qt = ( q.var: q.\type | /Question q := f, q has var ); 
  msgs = {};
  placed = {};

  void check(Rule r, Var v) {
    if (v in placed) 
      msgs += {error("Question already placed", r@\loc)};
    else   
      placed += {v};
    if (v notin qt) 
       msgs += {error("Undefined question", r@\loc)};
    //else
    //   return r[@link=...];
  }
  
  void checkType(Widget w, Type t) {
    if (!compatible(t, w)) 
      msgs += {error("Widget incompatible to type", w@\loc)};
  }
  
  void checkStyle(Style y, Type t) {
    ws = [ w | /Widget w := y ];
    if (Widget w <- ws) 
      checkType(w, t);
    if (size(ws) > 1) {
      msgs += { warning("Widget already defined", w@\loc) | w <- tail(ws) };  
    }
  }
  
  top-down visit (s) {
    case r:(Rule)`question <Var v>`: check(r, v);
    case r:(Rule)`question <Var v> <Style y>`: {
       check(r, v);
       if (v in qt) 
         checkStyle(y, qt[v]);
    }
    case r:(Rule)`default <Type t> <Style y>`: checkStyle(y, t);      
  }
  
  qs = domain(qt);
  if (placed & qs != qs) {
    missing = intercalate(", ", [ "<q>" | q <- qs - placed ]);
    msgs += {error("Missing placement for <missing>", s.name@\loc)}; 
  }
  
  return msgs;
}

bool compatible((Type)`boolean`, (Widget)`checkbox`) = true;
bool compatible((Type)`boolean`, (Widget)`radio(<String _>, <String _>)`) = true;
bool compatible((Type)`integer`, (Widget)`textbox`) = true;
bool compatible((Type)`integer`, (Widget)`slider(<Integer _>, <Integer _>, <Integer _>)`) = true;
bool compatible((Type)`integer`, (Widget)`spinbox`) = true;
bool compatible((Type)`money`, (Widget)`textbox`) = true;
bool compatible((Type)`money`, (Widget)`spinbox`) = true;
default bool compatible(Type _, Widget _) = false;
