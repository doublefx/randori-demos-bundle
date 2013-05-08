package behaviors
{
	import d3.d3Static;
	import d3.scale;
	import d3.svg;
	import d3.time;

	import randori.behaviors.AbstractBehavior;
	import randori.jquery.JQuery;
	import randori.webkit.page.Window;

	/**
	 * The chart for the gadget detail
	 */
	public class PercentCompleteAreaChart extends AbstractBehavior
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

		private var margin:Object;
		private var width:Number;
		private var height:Number;

		private var x:*;
		private var y:*;
		private var xAxis:*;
		private var yAxis:*;
		private var line:*;
		private var area:*;
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
				try {
					d.percentComplete = d.percentComplete;
					d.date = scopedParse(d.date);
				} catch (e) { }
			});

			x = time.scale()
					.domain(d3Static.extent(data, function(d:*):* { return d.date; }))
					.range([0, width]);

			xAxis = d3.svg.axis()
					.scale(x)
					.orient("bottom");

			svg.append("g")
					.attr("class", "x axis")
					.attr("transform", "translate(0," + height + ")")
					.call(xAxis)
					.selectAll("text")
					.style("text-anchor", "end")
					.attr("dx", "-.8em")
					.attr("dy", ".15em")
					.attr("transform", function(d:*):* {
						return "rotate(-45)"
					});

			// build the line
			var scopedX = x;
			var scopedY = y;
			line = d3.svg.line()
					.x(function(d:*):* { return scopedX(d.date); })
					.y(function(d:*):* { return scopedY(d.percentComplete); });

			area = d3.svg.area()
					.x(function(d:*):* { return scopedX(d.date); })
					.y0(height)
					.y1(function(d:*):* { return scopedY(d.percentComplete); });

			svg.append("path")
					.datum(data)
					.attr("class", "area")
					.attr("d", area);

			svg.append("path")
					.datum(data)
					.attr("class", "line")
					.attr("d", line);
		}

		/**
		 * setup the chart and get it ready to receive data
		 */
		private function setupChart() : void
		{
			// Setup the graph area
			margin = {top: 20, right: 20, bottom: 70, left: 50};
//			width = this.decoratedElement.clientWidth - margin.left - margin.right;
//			height = this.decoratedElement.clientHeight - margin.top - margin.bottom;
			width = 500 - margin.left - margin.right;
			height = 300 - margin.top - margin.bottom;

			svg = d3Static.select(this.decoratedNode[0]).append("svg")
//					.attr("width", width + margin.left + margin.right)
//					.attr("height", height + margin.top + margin.bottom)
					.append("g")
					.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

			// build the y axis (can't build the x axis til we have the data)
			y = scale.linear()
					.domain([0, 100])
					.range([height, 0]);

			yAxis = d3.svg.axis()
					.scale(y)
					.orient("left");

			// setup the date parser
			parseDate = time.format("%d/%m/%Y").parse;

			svg.append("g")
					.attr("class", "y axis")
					.call(yAxis)
					.append("text")
					.attr("transform", "rotate(-90)")
					.attr("y", 6)
					.attr("dy", ".71em")
					.style("text-anchor", "end")
					.text("Percent Complete");
		}

		/**
		 * Constructor
		 */
		public function PercentCompleteAreaChart()
		{
		}
	}
}