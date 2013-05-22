package behaviors.charts
{
	import d3.D3Area;
	import d3.D3Axis;
	import d3.D3Line;
	import d3.D3Scale;
	import d3.D3Selection;
	import d3.d3Static;
	import d3.scale;
	import d3.time;

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
	public class DateAreaChart extends AbstractBehavior {
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
		public var areaChartSVG:JQuery;
		private var svg:D3Selection;

		private var DEFAULT_MARGIN:Object = {top: 20, right: 20, bottom: 50, left: 50};

		public var margin:Object;
		private var width:Number = -1;
		private var height:Number = -1;

		private var x:D3Scale;
		private var y:D3Scale;
		private var xAxis:D3Axis;
		private var yAxis:D3Axis;
		private var line:D3Line;
		private var area:D3Area;
		private var parseDate:*;

		private var yAxisText:D3Selection;

		//----------------------------------------------------------------------------
		//
		// Methods
		//
		//----------------------------------------------------------------------------

		public function setYAxisText(label:String):void {
			if (yAxisText == null)
				return;
			yAxisText.text(label);
		}

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
					.attr("class", "xAxisText")
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
					.y1(function(d:*):* { return scopedY(d.value); });
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
						return scopedY(d.value);
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
					.domain2(d3Static.extent(data, function (d:*):* {
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
					.domain2([0, 100])
					.range([height, 0]);
		}

		/**
		 * build the x and y axes in the DOM
		 */
		private function buildAxesDOM():void {
			yAxisText = svg.append("g")
					.attr("class", "y axis")
					.call(yAxis)
					.append("text")
					.attr("transform", "rotate(-90)")
					.attr("y", 6)
					.attr("dy", ".71em")
					.style("text-anchor", "end");

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
			setupSize();

			return d3Static.select(areaChartSVG[0])
					.append("g")
					.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
		}

		private function setupSize():void {
			if (margin == null)
				margin = DEFAULT_MARGIN;

			if (width == -1 || height == -1) {
				width = areaChartSVG.width() - margin.left - margin.right;
				height = areaChartSVG.height() - margin.top - margin.bottom;
			}
		}

		/**
		 * when we get data, give it to the grid
		 */
		private function applyDataToChart(data:Array):void {
			// since we now have the area chart behavior created, we can setup the chart internals
			setupChart();

			// actually apply the data
			var scopedParse:* = parseDate;
			data.forEach(function(d:*):void {
				try {
					d.percentComplete = d.value;
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
			if (svg == null) {
				svg = buildChartArea();

				// build the y axis (can't build the x axis til we have the data)
				y = buildYScale(height);
				yAxis = buildYAxis(y);

				// setup the date parser
				parseDate = time.format("%d/%m/%Y").parse;

				buildAxesDOM();
				buildAreaDOM();
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
		}

		/**
		 * Constructor
		 */
		public function DateAreaChart() { }
	}
}