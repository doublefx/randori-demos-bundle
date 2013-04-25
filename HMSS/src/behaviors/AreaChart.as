package behaviors
{
	import d3.scale;
	import d3.svg;
	import d3.time;

	import randori.behaviors.AbstractBehavior;
	import randori.jquery.JQuery;
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
		private var graph:JQuery;
		private var gxAxis:JQuery;
		private var gyAxis:JQuery;

		private var x:*;
		private var y:*;
		private var xAxis:*;
		private var yAxis:*;
		private var line:*;
		private var parseDate:*;

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
			var scopedParse:* = parseDate;
			data.forEach(function(d:*):void {
				d.date = scopedParse(d.date);
			});

			/*
				x.domain(d3.extent(data, function(d) { return d.date; }));
				y.domain(d3.extent(data, function(d) { return d.percentComplete; }));

				svg.append("path")
						.datum(data)
						.attr("class", "line")
						.attr("d", line);
			});
			*/
		}

		/**
		 * setup the chart and get it ready to receive data
		 */
		private function setupChart() : void
		{
			// Setup the graph area
			var margin:Object = {top: 20, right: 20, bottom: 30, left: 50};
			var width:Number = 960 - margin.left - margin.right;
			var height:Number = 500 - margin.top - margin.bottom;

			decoratedNode.append("<svg>");
//			var mysvg:* = d3.select("svg");
			svg = decoratedNode.find("svg")
					.attr("width", width + margin.left + margin.right)
					.attr("height", height + margin.top + margin.bottom)
					.append("<g>");
			graph = svg.find("g")
					.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

			// THESE VARIABLE ARE USED TO TRICK THE COMPILER
			// WHEN THE COMPILER ERROR IS FIXED, REMOVE THESE VARIABLE DECLARATIONS
			var time:*;
			var scale:*;

			// build the axes
			x = d3.time.scale()
					.range([0, width]);

			y = d3.scale.linear()
					.range([height, 0]);

			xAxis = d3.svg.axis()
					.scale(x)
					.orient("bottom");

			yAxis = d3.svg.axis()
					.scale(y)
					.orient("left");

			// build the line
			line = d3.svg.line()
					.x(function(d:*):* { return x(d.date); })
					.y(function(d:*):* { return y(d.percentComplete); });

			// setup the date parser
			parseDate = d3.time.format("%d/%m/%Y").parse;

			// setup the area for the axes
			svg.append("<g id='gx'>");
			gxAxis = svg.find("#gx")
					.attr("class", "x axis")
					.attr("transform", "translate(0," + height + ")");
//			gxAxis.call(xAxis);

			svg.append("<g id='gy'>");
			gyAxis = svg.find("#gy")
					.attr("class", "y axis")
//			gyAxis.call(yAxis);
 					.append("<text>");
			var gyText:JQuery = gyAxis.find("text")
					.attr("transform", "rotate(-90)")
					.attr("y", 6)
					.attr("dy", ".71em")
					.text("Price ($)");
//			gyText.style("text-anchor", "end");
		}

		/**
		 * Constructor
		 */
		public function AreaChart()
		{
		}
	}
}