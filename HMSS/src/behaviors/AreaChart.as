package behaviors
{
	import d3.svg;
	import d3.time;

	import randori.behaviors.AbstractBehavior;
	import randori.jquery.JQuery;
	import randori.jquery.JQueryStatic;
	import randori.webkit.page.Window;

	/**
	 * The chart for the gadget detail
	 */
	public class AreaChart extends AbstractBehavior
	{
		//----------------------------------------------------------------------------
		//
		// Properties
		//
		//----------------------------------------------------------------------------

		//----------------------------------------
		// data
		//----------------------------------------

		/**
		 * @private
		 */
		private var _data:Array;

		/**
		 * the grid updates when data is written to this property
		 */
		public function get data() : Array
		{
			return _data;
		}

		/**
		 * @private
		 */
		public function set data(value:Array) : void
		{
			if (_data == value)
				return;

			_data = value;

			applyDataToChart(_data);
		}

		//----------------------------------------------------------------------------
		//
		// Variables
		//
		//----------------------------------------------------------------------------

		private var svg:JQuery;

		private var g:JQuery;

		//----------------------------------------------------------------------------
		//
		// Methods
		//
		//----------------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		override protected function onRegister():void
		{
			Window.console.log("AreaChart Registering");
			setupChart();
		}

		/**
		 * @inheritDoc
		 */
		override protected function onDeregister():void
		{

		}

		/**
		 * when we get data, give it to the grid
		 */
		private function applyDataToChart(data:Array) : void
		{

		}

		/**
		 * setup the chart and get it ready to receive data
		 */
		private function setupChart() : void
		{
			JQueryStatic.J("<div></div>");
			var margin:Object = {top: 20, right: 20, bottom: 30, left: 50};
			var width:Number = 960 - margin.left - margin.right;
			var height:Number = 500 - margin.top - margin.bottom;

			decoratedNode.append("<svg>");
			svg = decoratedNode.find("svg");
			svg.attr("width", width + margin.left + margin.right)
					.attr("height", height + margin.top + margin.bottom)
					.append("<g>");
			g = svg.find("g");
			g.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

//			var time:*;

//			var x:* = (new time())//.range([0, width]);
			var x:* = time.scale().range([0, width]);


//			var y = scale.linear()
//					.range([height, 0]);

			var myAxis:* = d3.svg.axis();

			/*
			 var parseDate = d3.time.format("%d-%b-%y").parse;

			 var x = d3.time.scale()
			 .range([0, width]);

			 var y = d3.scale.linear()
			 .range([height, 0]);

			 var xAxis = d3.svg.axis()
			 .scale(x)
			 .orient("bottom");

			 var yAxis = d3.svg.axis()
			 .scale(y)
			 .orient("left");

			 var line = d3.svg.line()
			 .x(function(d) { return x(d.date); })
			 .y(function(d) { return y(d.close); });

			 d3.tsv("data.tsv", function(error, data) {
			 data.forEach(function(d) {
			 d.date = parseDate(d.date);
			 d.close = +d.close;
			 });

			 x.domain(d3.extent(data, function(d) { return d.date; }));
			 y.domain(d3.extent(data, function(d) { return d.close; }));

			 svg.append("g")
			 .attr("class", "x axis")
			 .attr("transform", "translate(0," + height + ")")
			 .call(xAxis);

			 svg.append("g")
			 .attr("class", "y axis")
			 .call(yAxis)
			 .append("text")
			 .attr("transform", "rotate(-90)")
			 .attr("y", 6)
			 .attr("dy", ".71em")
			 .style("text-anchor", "end")
			 .text("Price ($)");

			 svg.append("path")
			 .datum(data)
			 .attr("class", "line")
			 .attr("d", line);
			 });
			 */

		}

		/**
		 * Constructor
		 */
		public function AreaChart()
		{
		}
	}
}