package behaviors.charts {
	import d3.D3Arc;
	import d3.D3Pie;
	import d3.D3Scale;
	import d3.D3Selection;
	import d3.d3Static;
	import d3.layout;
	import d3.scale;
	import d3.svg;

	import randori.behaviors.AbstractBehavior;
	import randori.jquery.JQuery;

	import utils.CircleMath;

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
	 * Date: 5/15/13
	 * Time: 3:33 PM
	 * @author Jared Schraub <jschraub@digitalprimates.net>
	 */
	public class PieChart extends AbstractBehavior {
		//----------------------------------------------------------------------------
		//
		// Variables
		//
		//----------------------------------------------------------------------------

		[View]
		public var pieChartSVG:JQuery;
		private var svgDOM:D3Selection;
		private var arcDOM:D3Selection;
		private var gpathDOM:D3Selection;
		private var gtextDOM:D3Selection;
		private var innerLabel:D3Selection;

		public var colors:Array;
		private var width:Number;
		private var height:Number;
		private var outerRadius:Number = -1;
		public var innerRadius:Number = -1;

		private var colorScale:D3Scale;
		private var d3Arc:D3Arc;
		private var d3Pie:D3Pie;

		private var DEFAULT_INNER_RADIUS:Number = 50;
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
		public function get data() : Array {
			return _data;
		}

		/**
		 * @private
		 */
		public function set data(value:Array) : void {
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

		private function setupInnerLabel(data:Array):D3Selection {
			if (innerLabel == null) {
				innerLabel = svgDOM.append("text")
						.attr("class", "innerLabel")
						.style("text-anchor", "middle")
			}
			// calculate the total number of data counts
			var total:Number = 0;
			data.forEach(function(d:*):void {
				try {
					total += d.value;
				} catch (e) { }
			});
			return innerLabel.text("Total: " + total);
		}

		/**
		 * setup the text tag (the pie slice text label)
		 */
		private function setupGTextDOM():D3Selection {
			var scopedArc:* = d3Arc;
//			var scopedRadius:Number = radius;
			return arcDOM.append("text")
					.attr("class", "arcLabel")
					.attr("transform", function(d:Object):String {
						return "translate(" + scopedArc.centroid(d) + ")";
					})
//					.attr("transform", function (d:*):String {
//						var c:Array = scopedArc.centroid(d);
//						var x:Number = c[0];
//						var y:Number = c[1];
////						var adjustedRadius:Number = scopedRadius + 4; // so that the text isn't right up against the pie slice
//						// pythagorean theorem for hypotenuse
//						var h:Number = CircleMath.calcHypotenuse(x, y);
////						var yAdjust:Number = CircleMath.angleAboveCenter(d.endAngle, d.startAngle) ? d.height : 0; // adjust for the height of the text
//						return "translate(" + CircleMath.calcComponentOfOuterCircle(x, h, scopedRadius) + ',' +
//								CircleMath.calcComponentOfOuterCircle(y, h, scopedRadius) + ")";
//					})
					.attr("dy", ".35em")
					.style("text-anchor", "middle")
//					.style("text-anchor", function (d:*):String {
//						// make sure that the center is not past
//						if (CircleMath.angleLeftOfCenter(d.endAngle, d.startAngle))
//							return "end";
//						else
//							return "start";
//					})
					.text(function (d:Object):String {
//						return d.data.name + " (" + d.data.value + ")";
						return d.data.value;
					});
		}

		/**
		 * setup the path DOM object for each arc object.
		 */
		private function setupGPathDOM():D3Selection {
			var scopedColor:* = colorScale;
			return arcDOM.append("path")
					.attr("class", "arcPath")
					.attr("d", d3Arc)
					.style("fill", function (d:Object):* {
						return scopedColor(d.data.name);
					});
		}

		/**
		 * setup the arc areas to the DOM based on the data array
		 *
		 * @param data the data array that holds the values to be displayed by the pie chart
		 */
		private function setupArcDOM(data:Array):D3Selection {
			var scopedPie:* = d3Pie;
			svgDOM.selectAll(".arc").remove();
			return svgDOM.selectAll(".arc")
					.data(scopedPie(data)).enter()
					.append("g")
					.attr("class", "arc");
		}

		/**
		 * setup the svg DOM object
		 */
		private function buildSVGDOM():D3Selection {
			return d3Static.select(pieChartSVG[0])
					.append("g")
					.attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
		}

		/**
		 * setup the d3 pie object
		 */
		private function buildD3Pie():D3Pie {
			return layout.pie()
					.sort(null)
					.value(function (d:*):* {
						return d.value;
					});
		}

		/**
		 * calculate the radius based on the width and height of the svg area
		 */
		private function calcRadius():Number {
			width = pieChartSVG.width();
			height = pieChartSVG.height();
			return CircleMath.calcRadius(width, height);
		}

		/**
		 * setup the color d3 scale
		 */
		private function buildColorScale():D3Scale {
			if (colors == null)
				colors = DEFAULT_COLORS;

			return scale.ordinal().range(colors);
		}

		/**
		 * setup the base d3 arc object, setting the outer and inner radius
		 */
		private function buildD3Arc(): D3Arc {
			if (outerRadius < 0)
				outerRadius = calcRadius();
			if (innerRadius < 0)
				innerRadius = DEFAULT_INNER_RADIUS;
			return svg.arc()
					.outerRadius(outerRadius)
					.innerRadius(innerRadius);
		}

		/**
		 * when we get data, give it to the grid
		 */
		private function applyDataToChart(data:Array):void {
			// Since this is called after the Behavior is setup, we can now setup the chart
			setupChart();
			// Actually apply the data
			arcDOM = setupArcDOM(data);
			gpathDOM = setupGPathDOM();
			gtextDOM = setupGTextDOM();
			innerLabel = setupInnerLabel(data);
		}

		/**
		 * setup the chart and get it ready to receive data
		 */
		private function setupChart():void {
			if (svgDOM == null) {
				outerRadius = calcRadius();
				colorScale = buildColorScale();
				d3Arc = buildD3Arc();
				d3Pie = buildD3Pie();
				svgDOM = buildSVGDOM();
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
			innerRadius = DEFAULT_INNER_RADIUS;
			colors = DEFAULT_COLORS;
		}

		/**
		 * Constructor
		 */
		public function PieChart() { }
	}
}