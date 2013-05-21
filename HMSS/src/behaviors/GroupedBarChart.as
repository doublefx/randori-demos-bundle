package behaviors
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

		[View]
		public var groupedbarchartsvg:JQuery;
		private var svg:D3Selection;

		private var margin:Object;
		private var width:Number = -1;
		private var height:Number = -1;

		private var x0:D3Scale;
		private var x1:D3Scale;
		private var y:D3Scale;
		private var xAxis:D3Axis;
		private var yAxis:D3Axis;
		private var bars:D3Selection;
		private var colorScale:D3Scale;

		private var legend:D3Selection;

		private var yAxisText:D3Selection;

		private var colors:Array = ["#B8E3E8", "#9ECACF", "#588EBC", "#3F75A2"];

		//----------------------------------------------------------------------------
		//
		// Methods
		//
		//----------------------------------------------------------------------------

		private function setupLegend(valueNames:Array):void {
			legend = svg.selectAll(".legend")
					.data(valueNames.slice().reverse())
					.enter().append("g")
					.attr("class", "legend")
					.attr("transform", function (d:*, i:Number):String {
						return "translate(0," + i * 20 + ")";
					});

			legend.append("rect")
					.attr("x", width - 18)
					.attr("width", 18)
					.attr("height", 18)
					.style("fill", colorScale);

			legend.append("text")
					.attr("x", width - 24)
					.attr("y", 9)
					.attr("dy", ".35em")
					.style("text-anchor", "end")
					.text(function (d:*):* {
						return d;
					});
		}

		private function setupBarsDOM(data:Array):void {
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
			bars = item.selectAll("rect")
					.data(function (d:*):Array {
						return d.values;
					})
					.enter().append("rect")
					.attr("width", x1.rangeBand())
					.attr("x", function (d:*):* {
						return scopedX1(d.name);
					})
					.attr("y", function (d:*):* {
						return scopedY(d.value);
					})
					.attr("height", function (d:*):* {
						return scopedHeight - scopedY(d.value);
					})
					.style("fill", function (d:*):* {
						return scopedColorScale(d.name);
					});
		}

		private function setupYAxisDOM():void {
			yAxisText = svg.append("g")
					.attr("class", "y axis")
					.call(yAxis)
					.append("text")
					.attr("transform", "rotate(-90)")
					.attr("y", 6)
					.attr("dy", ".71em")
					.style("text-anchor", "end");
		}

		private function setupXAxisDOM():void {
			svg.append("g")
					.attr("class", "x axis")
					.attr("transform", "translate(0," + height + ")")
					.call(xAxis)
					.selectAll("text")
					.attr("class", "x axis text")
					.style("text-anchor", "end")
					.attr("dx", "-.8em")
					.attr("dy", ".15em")
					.attr("transform", function (d:*):* {
						return "rotate(-45)"
					});
		}

		private function setupDomains(data:Array, valueNames:Array):void {
			x0.domain2(data.map(function (d:*):String {
				return d.name;
			}));
			x1.domain2(valueNames).rangeRoundBands1([0, x0.rangeBand()]);
			y.domain2([0, d3Static.max(data, function (d:*):* {
				return d3Static.max(d.values, function (d:*):* {
					return d.value;
				});
			})]);
		}

		private function formatData(data:Array, valueNames:Array):void {
			data.forEach(function (d:*):void {
				d.values = valueNames.map(function (name:String):* {
					return {name: name, value: +d[name]};
				});
			});
		}

		private function getValueNames(data:Array):Array {
			return d3Static.keys(data[0])
					.filter(function (key:String):Boolean {
						return key !== "name";
					});
		}

		public function setYAxisText(label:String):void {
			if (yAxisText == null)
				return;
			yAxisText.text(label);
		}

		private function buildColorScale():D3Scale {
			return scale.ordinal().range(colors);
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
		private function buildX0Scale(width:Number):D3Scale {
			return scale.ordinal()
					.rangeRoundBands2([0, width], .1);
		}

		/**
		 * build the x-D3Scale object
		 *
		 * @param width the width of the D3Scale object
		 * @param data the data that will be displayed in the chart
		 * @return the x-D3Scale object
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

			return d3Static.select(groupedbarchartsvg[0])
					.append("g")
					.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
		}

		private function setupSize():void {
			if (margin == null)
				margin = {top: 20, right: 20, bottom: 160, left: 50};

			if (width == -1 || height == -1) {
				width = groupedbarchartsvg.width() - margin.left - margin.right;
				height = groupedbarchartsvg.height() - margin.top - margin.bottom;
			}
		}

		/**
		 * when we get data, give it to the grid
		 */
		private function applyDataToChart(data:Array):void {
			// since we now have the chart behavior created, we can setup the chart internals
			setupChart();

			var valueNames:Array = getValueNames(data);
			formatData(data, valueNames);

			setupDomains(data, valueNames);

			setupXAxisDOM();
			setupYAxisDOM();

			setupBarsDOM(data);

			setupLegend(valueNames);
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

//				buildAxesDOM();
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
		}

		/**
		 * Constructor
		 */
		public function GroupedBarChart() { }
	}
}