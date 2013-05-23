package behaviors.charts
{
	import d3.D3Axis;
	import d3.D3Scale;
	import d3.D3Selection;
	import d3.d3Static;
	import d3.scale;

	import randori.behaviors.AbstractBehavior;
	import randori.jquery.JQuery;

	/***
	 * Copyright 2013 LTN Consulting, Inc. /dba Digital Primates®
	 *
	 * Licensed under the Apache License, Version 2.0 (the "License");
	 * you may not use this file except in compliance with the License.
	 * You may obtain a copy of the License at
	 *
	 * http://www.apache.org/licenses/LICENSE-2.0
	 *
	 * Unless required by applicable law or agreed to in writing, software
	 * distributed under the License is distributed on an "AS IS" BASIS,
	 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	 * See the License for the specific language governing permissions and
	 * limitations under the License.
	 *
	 * Created with IntelliJ IDEA.
	 * Date: 5/21/13
	 * Time: 10:27 AM
	 * @author Jared Schraub <jschraub@digitalprimates.net>
	 */

	/**
	 * The chart for the gadget detail
	 */
	public class GroupedBarChart extends AbstractBehavior {
		//----------------------------------------------------------------------------
		//
		// Variables
		//
		//----------------------------------------------------------------------------

		[View]
		public var groupedBarChartSVG:JQuery;
		private var svg:D3Selection;

		private var width:Number = -1;
		private var height:Number = -1;
		public var margin:Object;
		public var colors:Array;

		private var x0:D3Scale;
		private var x1:D3Scale;
		private var y:D3Scale;
		private var xAxis:D3Axis;
		private var yAxis:D3Axis;
		private var colorScale:D3Scale;

		private var xAxisDOM:D3Selection;
		private var yAxisDOM:D3Selection;
		private var yAxisTextDOM:D3Selection;
		private var barsDOM:D3Selection;
		private var legendDOM:D3Selection;

		private var DEFAULT_MARGIN:Object = {top: 20, right: 20, bottom: 50, left: 50};
		private var DEFAULT_COLORS:Array =
				["#EEE", "#DDD", "#CCC", "#BBB",
					"#AAA", "#999", "#888", "#777",
					"#666", "#555", "#444", "#333",
					"#222", "#111"];

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
		// Methods
		//
		//----------------------------------------------------------------------------

		/**
		 * create the legend to be used to show what the different bars represent
		 *
		 * @param valueNames the names of the data values
		 */
		private function buildLegend(valueNames:Array):D3Selection {
			var squareSize:Number = 18;
			var squareMargin:Number = 1;

			var legend:D3Selection = svg.selectAll(".legend")
					.data(valueNames.slice().reverse())
					.enter().append("g")
					.attr("class", "legend")
					.attr("transform", function (d:*, i:Number):String {
						return "translate(0," + i * (squareSize + squareMargin * 2) + ")";
					});

			legend.append("rect")
					.attr("x", width - squareSize)
					.attr("width", squareSize)
					.attr("height", squareSize)
					.style("fill", colorScale);

			legend.append("text")
					.attr("class", "legendText")
					.attr("x", width - squareSize - 2 * squareMargin - 2)
					.attr("y", squareSize/2)
					.attr("dy", ".35em")
					.style("text-anchor", "end")
					.text(function (d:*):* {
						return d;
					});
			return legend;
		}

		/**
		 * setup the Bars DOM objects
		 *
		 * @param data the data array
		 */
		private function buildBarsDOM(data:Array):D3Selection {
			var scopedX0:* = x0;
			svg.selectAll(".bar").remove();
			var item:D3Selection = svg.selectAll(".bar")
					.data(data)
					.enter().append("g")
					.attr("class", "g")
					.attr("transform", function (d:*):String {
						return "translate(" + scopedX0(d.name) + ",0)";
					});

			var scopedX1:* = x1;
			var scopedY:* = y;
			var scopedColorScale:* = colorScale;
			var scopedHeight:Number = height;
			var bars:D3Selection = item.selectAll("rect")
					.data(function (d:Object):Array {
						return d.values;
					})
					.enter().append("rect")
					.attr("class", "barRect")
					.attr("width", x1.rangeBand())
					.attr("x", function (d:*):Number {
						return scopedX1(d.name);
					})
					.attr("y", function (d:*):Number {
						return scopedY(d.value);
					})
					.attr("height", function (d:*):Number {
						return scopedHeight - scopedY(d.value);
					})
					.style("fill", function (d:*):* {
						return scopedColorScale(d.name);
					});
			return bars;
		}

		/**
		 * create the Y Axis DOM object
		 */
		private function buildYAxisDOM():D3Selection {
			var yAxisDOM:D3Selection = svg.append("g")
					.attr("class", "y axis")
					.call(yAxis);
			yAxisTextDOM = yAxisDOM.append("text")
					.attr("transform", "rotate(-90)")
					.attr("y", 6)
					.attr("dy", ".71em")
					.style("text-anchor", "end");
			return yAxisDOM;
		}

		/**
		 * create the XAxis DOM object
		 */
		private function buildXAxisDOM():D3Selection {
			var xAxisDOM:D3Selection = svg.append("g")
					.attr("class", "x axis")
					.attr("transform", "translate(0," + height + ")")
					.call(xAxis);
			xAxisDOM.selectAll("text")
					.attr("class", "x axis text")
					.style("text-anchor", "end")
					.attr("dx", "-.8em")
					.attr("dy", ".15em")
					.attr("transform", function (d:*):* {
						return "rotate(-45)"
					});
			return xAxisDOM;
		}

		/**
		 * setup the domains for the x0, x1, and y variables
		 *
		 * @param data the data array
		 * @param valueNames the names of the values in the data array
		 */
		private function setupDomains(data:Array, valueNames:Array):void {
			x0.domain2(data.map(function (d:*):String {
				return d.name;
			}));
			x1.domain2(valueNames).rangeRoundBands1([0, x0.rangeBand()]);
			y.domain2([0, d3Static.max(data, function (d:*):Number {
				return d3Static.max(d.values, function (d:*):Number {
					return d.value;
				});
			})]);
		}

		/**
		 * format the data into a format better conditioned for the behavior
		 *
		 * @param data the data array to be formatted
		 * @param valueNames the names of the values in the data array
		 */
		private function formatData(data:Array, valueNames:Array):void {
			data.forEach(function (d:*):void {
				try {
					d.values = valueNames.map(function (name:String):Object {
						return {name: name, value: +d[name]};
					});
				} catch (e) { }
			});
		}

		/**
		 * get the names of the values in the data array
		 *
		 * @param data the array of the data including the header line that contains the names of the values
		 * @return an array of the names of the values
		 */
		private function getValueNames(data:Array):Array {
			return d3Static.keys(data[0])
					.filter(function (key:String):Boolean {
						return key !== "name";
					});
		}

		/**
		 * set the text that appears on the y Axis
		 *
		 * @param label the string to be displayed on the y axis
		 */
		public function setYAxisText(label:String):void {
			if (yAxisTextDOM == null)
				return;
			yAxisTextDOM.text(label);
		}

		/**
		 * create the color D3Scale object
		 *
		 * @return the color D3Scale object
		 */
		private function buildColorScale():D3Scale {
			if (colors == null)
				colors = DEFAULT_COLORS;
			return scale.ordinal().range(colors);
		}

		/**
		 * build the x-D3Axis object
		 *
		 * @param x the x-D3Scale
		 * @return the x-D3Axis object
		 */
		private function buildXAxis(x:D3Scale):D3Axis {
			if (x == null)
				throw new Error("Null Exception: Value 'x' must not be null");
			return d3.svg.axis()
					.scale(x)
					.orient("bottom");
		}

		/**
		 * build the x0-D3Scale object
		 *
		 * @param width the width of the D3Scale object
		 * @return the x0-D3Scale object
		 */
		private function buildX0Scale(width:Number):D3Scale {
			if (width < 0)
				throw new Error("Invalid Number Exception: Value 'width' must be positive");
			return scale.ordinal()
					.rangeRoundBands2([0, width], .1);
		}

		/**
		 * build the x1-D3Scale object
		 *
		 * @return the x1-D3Scale object
		 */
		private function buildX1Scale():D3Scale {
			return scale.ordinal();
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
					.orient("left")
					.tickFormat(d3Static.format(".2s"));
		}

		/**
		 * build the y-D3Scale object
		 *
		 * @param height the height of the D3Scale object
		 * @return the y-D3Scale object
		 */
		private function buildYScale(height:Number):D3Scale {
			if (height < 0)
				throw new Error("Invalid Number Exception: Value 'height' must be positive");
			return scale.linear()
					.range([height, 0]);
		}

		/**
		 * create the svg/chart area on the DOM
		 *
		 * @return the svg D3Selection
		 */
		private function buildChartArea():D3Selection {
			setupSize();

			return d3Static.select(groupedBarChartSVG[0])
					.append("g")
					.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
		}

		private function setupSize():void {
			if (margin == null)
				margin = DEFAULT_MARGIN;

			if (width < 0 || height < 0) {
				width = groupedBarChartSVG.width() - margin.left - margin.right;
				height = groupedBarChartSVG.height() - margin.top - margin.bottom;
			}
		}

		/**
		 * when we get data, give it to the grid
		 *
		 * @param data the data array to be shown in the chart
		 */
		private function applyDataToChart(data:Array):void {
			// since we now have the chart behavior created, we can setup the chart internals
			setupChart();

			// now that the chart framework is setup, apply the data
			var valueNames:Array = getValueNames(data);
			formatData(data, valueNames);

			setupDomains(data, valueNames);

			xAxisDOM = buildXAxisDOM();
			yAxisDOM = buildYAxisDOM();
			barsDOM = buildBarsDOM(data);
			legendDOM = buildLegend(valueNames);
		}

		/**
		 * setup the chart and get it ready to receive data
		 */
		private function setupChart():void {
			if (svg == null) {
				svg = buildChartArea();

				// build the y axis (can't build the x axis til we have the data)
				y = buildYScale(height);
				yAxis = buildYAxis(y);

				// setup the date parser
				colorScale = buildColorScale();

				x0 = buildX0Scale(width);
				x1 = buildX1Scale();
				xAxis = buildXAxis(x0);
			}
		}

		/**
		 * @inheritDoc
		 */
		override protected function onDeregister():void {
			super.onDeregister();
		}

		/**
		 * @inheritDoc
		 */
		override protected function onRegister():void {
			super.onRegister();
			margin = DEFAULT_MARGIN;
			colors = DEFAULT_COLORS;
		}

		/**
		 * Constructor
		 */
		public function GroupedBarChart() { }
	}
}