
library D3Dart;

import 'dart:html';
import 'dart:math' as Math;

typedef String PropertyFunction(dynamic d, int i);
typedef Object KeyFunction(dynamic d, int i);

class Selection {
  
  static Expando _datum = new Expando("__data__");

  Selection _parent;
  
  List<Element> _elements;
  Iterable<Object> _data = [];
  
  Selection(Selection this._parent, List<Element> this._elements);
  
  int get length {
    return _elements.length;
  }
  
  void set text(PropertyFunction f) {
    int index = 0;
    Iterator<Object> data_it = _data.iterator;
    for (Element elmt in _elements) {
      data_it.moveNext();
      Object d = data_it.current;
      dynamic v = f(d, index);
      elmt.text = v;
      index += 1;
    }
  }
  
  _SelectionStyle get style => new _SelectionStyle(this);

  void attr(String name, PropertyFunction f) {
    int index = 0;
    Iterator<Object> data_it = _data.iterator;
    for (Element elmt in _elements) {
      data_it.moveNext();
      Object d = data_it.current;
      dynamic v = f(d, index);
      elmt.attributes[name] = v;
      index += 1;
    }
  }
  
  Selection select(String selector) {
    /*for (List<Element> group in )
    var subgroups = [],
        subgroup,
        subnode,
        group,
        node;

    selector = d3_selection_selector(selector);

    for (var j = -1, m = this.length; ++j < m;) {
      subgroups.push(subgroup = []);
      subgroup.parentNode = (group = this[j]).parentNode;
      for (var i = -1, n = group.length; ++i < n;) {
        if (node = group[i]) {
          subgroup.push(subnode = selector.call(node, node.__data__, i, j));
          if (subnode && "__data__" in node) subnode.__data__ = node.__data__;
        } else {
          subgroup.push(null);
        }
      }
    }

    return d3_selection(subgroups);
    */
  }
  
  Selection selectAll(String selector) {
    return new Selection(this, _elements.map((Element elmt) => elmt.queryAll(selector)).reduce((Iterable a, Iterable b) {
      List list = a.toList();
      list.addAll(b);
      return list;
    }));
  }

  BoundSelection data(Iterable<Object> value, { KeyFunction key: null }) {
    return new BoundSelection(_parent, _elements, value, key);
  }
  
  Object get datum {
    if (_elements.isEmpty) {
      return null;
    }
    return _datum[_elements.first];
  }
  
  void set datum(Object value) {
    for (Element elmt in _elements) {
      _datum[elmt] = value;
    }
  }
}

class EnterSelection extends Selection {
  EnterSelection(Selection parent, Iterable<Object> _data) : super(parent, []) {
    this._data = _data;
  }

  void append(String tag) {
    for (Object d in _data) {
      Element elmt = new Element.tag(tag);
      _elements.add(elmt);
      // FIXME: .first ???
      _parent._elements.first.append(elmt);
    }
  }
}

class BoundSelection extends Selection {
  Iterable<Object> _all_data;
  KeyFunction _key;
  Map<Object, Element> _bound;
  int _taken;
  
  BoundSelection(Selection parent, List<Element> elements, Iterable<Object> this._all_data, KeyFunction this._key) : super(parent, []) {
    _taken = Math.min(elements.length, _data.length);
    this._elements.addAll(elements.take(_taken));
    this._data = _all_data.take(_taken);
  }
  
  EnterSelection enter() {
    int taken = _taken;
    _taken = _all_data.length;
    return new EnterSelection(_parent, _all_data.skip(taken));
  }
  
  Object remove() {
    throw new UnimplementedError();
  }
}

Selection select(String selector) {
  Element elmt = query(selector);
  if (elmt != null) {
    return new Selection(null, [elmt]);
  }
  return new Selection(null, []);
}

Selection selectAll(String selector) {
  return new Selection(null, queryAll(selector));
}

class _SelectionStyle {
  Selection _selection;
  _SelectionStyle(Selection this._selection);
  
  void setProperty(String propertyName, PropertyFunction f) {
    int index = 0;
    Iterator<Object> data_it = _selection._data.iterator;
    for (Element elmt in _selection._elements) {
      data_it.moveNext();
      Object d = data_it.current;
      dynamic v = f(d, index);
      elmt.style.setProperty(propertyName, v);
      index += 1;
    }
  }

  // CSSStyleRule
  void set color(PropertyFunction f) => setProperty("color", f);
  void set backgroundColor(PropertyFunction f) => setProperty("background-color", f);
  void set fontSize(PropertyFunction f) => setProperty("font-size", f);
  void set width(PropertyFunction f) => setProperty("width", f);
  void set height(PropertyFunction f) => setProperty("height", f);
}

class Scale {
  static PropertyFunction linear({List domain, List range, String suffix: "px"}) {
    return (dynamic d, int i) {
      if (domain != null) {
        d = (d - domain[0]) / domain[1];
      }
      if (range != null) {
        d = d * (range[1] - range[0]);
      }
      return "${d}${suffix}";
    };
  }
}

num max(Iterable<Object> data) {
  num v = data.first;
  for (num v1 in data) {
    if (v1 > v) {
      v = v1;
    }
  }
  return v;
}
