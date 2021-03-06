
import 'package:d3dart/D3Dart.dart' as d3;
import 'dart:html';

var DATASET = [[{
  'x': 'Cats',
  'y': 'English',
  'value': 21
},{
  'x': 'Dogs',
  'y': 'English',
  'value': 11
}],[{
  'x': 'Cats',
  'y': 'Scottish',
  'value': 12
},{
  'x': 'Dogs',
  'y': 'Scottish',
  'value': 18
}],[{
  'x': 'Cats',
  'y': 'Irish',
  'value': 8
},{
  'x': 'Dogs',
  'y': 'Irish',
  'value': 15
}]];

void main() {
  d3.ColumnChart chart = new d3.ColumnChart(querySelector("#chart"));
  chart.has_legend = true;
  chart.popoverContentFunc = (d) {
    DivElement div = new DivElement();
    div.text = "$d";
    return div;
  };
  chart.margin = {"top": 10, "bottom": 50, "left": 50, "right": 200};
  chart.data = DATASET;
}
