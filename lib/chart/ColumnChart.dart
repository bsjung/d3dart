part of D3Dart;

abstract class ChartWithAxes {
  num width;
  num height;

  bool has_legend = false;
  String yAxisLabel = "y Axis";
  Map margin = {"top": 20, "right": 20, "bottom": 250, "left": 50};
  Function yAxisTickFormat;
  
  void renderXAxis(var x, var g) {
    var xAxis = new Axis();
    xAxis.scale = x;
    xAxis.orient = "bottom";

    var gx = g.append("g");
    gx.attr("class", "x axis");
    gx.attr("transform", "translate(0,${height})");
    gx.call(xAxis);
    var gx_text = gx.selectAll("text");
    gx_text.attr("transform", "rotate(-65)");
    gx_text.style.textAnchorConst = "end";
    gx_text.attr("dx", "-1em");
    gx_text.attr("dy", "0em");
  }
  
  void renderYAxis(LinearScale y, var g) {
    var yAxis = new Axis();
    yAxis.scale = y;
    yAxis.orient = "left";
    
    yAxis.tickFormat = yAxisTickFormat;
    
    // First render gridlines
    var ggridlines = g.append("g");
    ggridlines.attr("class", "ygridlines");
    BoundSelection tick = ggridlines.selectAll(".gridline").data(y.ticks(10)/*, key: scale1 */);
    var tickEnter = tick.enter.append("g");
    tickEnter.attr("class", "gridline");
    tickEnter.append("line");
    tickEnter.attrFunc("transform", (d, i) => "translate(0, ${y(d)})");
    var lineEnter = tickEnter.select("line");
    lineEnter.attr("x2", width);
    
    // Then axis
    var gy = g.append("g");
    gy.attr("class", "y axis");
    gy.call(yAxis);
    
    var gl = gy.append("text");
    gl.attr("transform", "rotate(-90)");
    gl.attr("y", 6);
    gl.attr("dy", ".71em");
    gl.style.textAnchorConst = "end";
    gl.text = yAxisLabel;
  }
  
  void renderLegend(Element $elmt, var _data, var color) {
    if (has_legend) {
      var legend_div = selectElement($elmt).append("div");
      legend_div.attr("class", "legend");
      BoundSelection sel = legend_div.selectAll(".legend-item").data(_data);
      Selection legend_item = sel.enter.append("div");
      legend_item.attr("class", "legend-item clearfix");
      
      Selection legend_key = legend_item.append("div");
      legend_key.attr("class", "legend-key");
      legend_key.style.backgroundColor = (d, i) {
        return "#${color(d.first['y']).toRadixString(16)}";
      };

      Selection legend_label = legend_item.append("div");
      legend_label.textFunc = (d, i) {
        return d.first['y'].toString();
      };
    }
  }
}

class ColumnChart extends ChartWithAxes {
  
  Element $elmt;
  
  num initial_width;
  num initial_height;
  
  var color = Scale.category10;
  
  List _data;
  
  ColumnChart(Element this.$elmt, { int this.initial_width, int this.initial_height }) {
    Rectangle rect = $elmt.getBoundingClientRect();
    if (width == null) {
      initial_width = rect.width;
    }
    if (height == null) {
      initial_height = rect.height;
    }
  }
  
  void _render() {
    width = initial_width - margin["left"] - margin["right"];
    height = initial_height - margin["top"] - margin["bottom"];
    
    var x = new Ordinal();
    x.rangeRoundBands([0, width], padding: 0.1);
    
    var y = new LinearScale();
    y.range = [height, 0];
    
    var svg = selectElement($elmt).append("svg");
    svg.attr("width", width +  margin["left"] + margin["right"]);
    svg.attr("height", height + margin["top"] + margin["bottom"]);

    var g = svg.append("g");
    g.attr("transform", "translate(${margin["left"]},${margin["top"]})");
    
    var series1 = _data[0];
    x.domain = series1.map((Map d) {
      return d["x"];
    }).toList();
    
    var y_extent = [0, 1];
    for (List series in _data) {
      var extents = extent(series, (d,i) {
        num v = d["value"];
        if (v.isNaN || v.isInfinite) {
          v = 0;
        }
        return v;
      });
      y_extent[0] = Math.min(y_extent[0], extents[0]);
      y_extent[1] = Math.max(y_extent[1], extents[1]);
    }
    
    y.domain = y_extent;
    
    renderXAxis(x, g);
    renderYAxis(y, g);
    
    for (List series in _data) {
      var bar = g.selectAll(".bar")
         .data(series)
       .enter;
      var rect = bar
      .append("rect");
      rect
         .attr("class", "bar");
      rect
         .attrFunc("x", (d,i) { return x(d["x"]); });
      rect
         .attr("width", x.rangeBand);
      
      rect
         .attrFunc("y", (d,i) { return y(d["value"]); });
      rect
         .attrFunc("height", (d,i) { return height - y(d["value"]); });
    }
    
    renderLegend($elmt, _data, color);
  }
  
  void set data(List value) {
    _data = value;
    _render();
  }
}