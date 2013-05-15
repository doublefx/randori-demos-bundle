package behaviors
{
	import d3.D3Area;
	import d3.D3Axis;
	import d3.D3Line;
	import d3.D3Scale;
	import d3.D3Selection;
	import d3.d3Static;
	import d3.scale;
	import d3.svg;
	import d3.time;

	import randori.behaviors.AbstractBehavior;
	import randori.jquery.JQuery;
	import randori.jquery.JQueryStatic;

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

		private var svg:D3Selection;

		private var margin:Object;
		private var width:Number;
		private var height:Number;

		private var x:D3Scale;
		private var y:D3Scale;
		private var xAxis:D3Axis;
		private var yAxis:D3Axis;
		private var line:D3Line;
		private var area:D3Area;
		private var parseDate:*;

		//----------------------------------------------------------------------------
		//
		// Methods
		//
		//----------------------------------------------------------------------------

		/**
		 * set the data on the area and line DOM objects
		 *
		 * @param data the data to be displayed by the chart
		 * @param area the D3Area object to which the data should be applied
		 * @param line the D3Line object to which the data should be applied
		 */
		private function setAreaData(data:Array, area:D3Area, line:D3Line):void {
			svg.select(".area")
					.datum(data)
					.attr("d", area);

			svg.select(".line")
					.datum(data)
					.attr("d", line);
		}

		/**
		 * setup the x axis DOM object including the text ticks
		 *
		 * @param xAxis the D3Axis object to use in the call function
		 */
		private function buildXAxisDOM(xAxis:D3Axis):void {
			svg.select(".x.axis")
					.call(xAxis)
					.selectAll("text")
					.style("text-anchor", "end")
					.attr("dx", "-.8em")
					.attr("dy", ".15em")
					.attr("transform", function (d:*):* {
						return "rotate(-45)"
					});
		}

		/**
		 * build the D3Area object
		 *
		 * @return the D3Area object
		 */
		private function buildArea():D3Area {
			var scopedX:* = x;
			var scopedY:* = y;
			return d3.svg.area()
					.x(function(d:*):* { return scopedX(d.date); })
					.y0(height)
					.y1(function(d:*):* { return scopedY(d.percentComplete); });
		}

		/**
		 * build the D3Line object
		 *
		 * @return the D3Line object
		 */
		private function buildLine():D3Line {
			var scopedX:* = x;
			var scopedY:* = y;
			return d3.svg.line()
					.x(function (d:*):* {
						return scopedX(d.date);
					})
					.y(function (d:*):* {
						return scopedY(d.percentComplete);
					});
		}

		/**
		 * build the x-D3Axis object
		 *
		 * @param x the x-D3Scale
		 * @return the x-D3Axis object
		 */
		private function buildXAxis(x:D3Scale):D3Axis {
			return d3.svg.axis()
					.scale(x)
					.orient("bottom");
		}

		/**
		 * build the x-D3Scale object
		 *
		 * @param width the width of the D3Scale object
		 * @param data the data that will be displayed in the chart
		 * @return the x-D3Scale object
		 */
		private function buildXScale(width:Number, data:Array):D3Scale {
			return time.scale()
					.domain(d3Static.extent(data, function (d:*):* {
						return d.date;
					}))
					.range([0, width]);
		}

		/**
		 * build the y-D3Axis object
		 *
		 * @param y the y-D3Scale
		 * @return the y-D3Axis object
		 */
		private function buildYAxis(y:D3Scale):D3Axis {
			return d3.svg.axis()
					.scale(y)
					.orient("left");
		}

		/**
		 * build the y-D3Scale object
		 *
		 * @param height the height of the D3Scale object
		 * @return the y-D3Scale object
		 */
		private function buildYScale(height:Number):D3Scale {
			return scale.linear()
					.domain([0, 100])
					.range([height, 0]);
		}

		/**
		 * build the x and y axes in the DOM
		 */
		private function buildAxesDOM():void {
			svg.append("g")
					.attr("class", "y axis")
					.call(yAxis)
					.append("text")
					.attr("transform", "rotate(-90)")
					.attr("y", 6)
					.attr("dy", ".71em")
					.style("text-anchor", "end")
					.text("Percent Complete");

			svg.append("g")
					.attr("class", "x axis")
					.attr("transform", "translate(0," + height + ")")
		}

		/**
		 * build the area and line objects in the DOM
		 */
		private function buildAreaDOM():void {
			svg.append("path")
					.attr("class", "area");

			svg.append("path")
					.attr("class", "line");
		}

		/**
		 * create the svg/chart area on the DOM
		 *
		 * @return the svg D3Selection
		 */
		private function buildChartArea():D3Selection {
			margin = {top: 20, right: 20, bottom: 70, left: 50};

			return d3Static.select(this.decoratedNode[0]).append("svg")
					.append("g")
					.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
		}

		/**
		 * when we get data, give it to the grid
		 */
		private function applyDataToChart(data:Array):void {
			var scopedParse:* = parseDate;
			data.forEach(function(d:*):void {
				try {
					d.percentComplete = d.percentComplete;
					d.date = scopedParse(d.date);
				} catch (e) { }
			});

			x = buildXScale(width, data);
			xAxis = buildXAxis(x);
			buildXAxisDOM(xAxis);

			// build the line and area
			line = buildLine();
			area = buildArea();
			setAreaData(data, area, line);
		}

		/**
		 * setup the chart and get it ready to receive data
		 */
		private function setupChart():void {
			var jsvg:JQuery = JQueryStatic.J("svg");
			width = jsvg.width() - margin.left - margin.right;
			height = jsvg.height() - margin.top - margin.bottom;

			// build the y axis (can't build the x axis til we have the data)
			y = buildYScale(height);
			yAxis = buildYAxis(y);

			// setup the date parser
			parseDate = time.format("%d/%m/%Y").parse;

			buildAxesDOM();
			buildAreaDOM();
		}

		/**
		 * @inheritDoc
		 */
		override protected function onPreRegister():void {
			super.onPreRegister();
			svg = buildChartArea();
		}

		/**
		 * @inheritDoc
		 */
		override public function verifyAndRegister():void {
			super.verifyAndRegister();
			setupChart();
		}

		/**
		 * @inheritDoc
		 */
		override protected function onDeregister():void {
			super.onDeregister();
			svg.remove();
		}

		/**
		 * @inheritDoc
		 */
		override protected function onRegister():void {
			super.onRegister();
		}

		/**
		 * Constructor
		 */
		public function PercentCompleteAreaChart() { }
	}
}