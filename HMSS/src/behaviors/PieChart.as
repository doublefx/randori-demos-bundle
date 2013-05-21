package behaviors {
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
		// Variables
		//
		//----------------------------------------------------------------------------

		[View]
		public var piechartsvg:JQuery;
		private var svgDOM:D3Selection;

		private var width:Number;
		private var height:Number;
		private var radius:Number = -1;

		private var colorScale:D3Scale;
		private var d3Arc:D3Arc;
		private var d3Pie:D3Pie;
		private var arcDOM:D3Selection;
		private var gpathDOM:D3Selection;
		private var gtextDOM:D3Selection;
		private var innerLabel:D3Selection;

		public var colors:Array = ["#EEE", "#DDD", "#CCC", "#BBB", "#AAA", "#999", "#888", "#777", "#666", "#555", "#444", "#333", "#222", "#111"];

		//----------------------------------------------------------------------------
		//
		// Methods
		//
		//----------------------------------------------------------------------------

		private function setupInnerLabel(data:Array):void {
			if (innerLabel == null) {
				innerLabel = svgDOM.append("text")
						.attr("class", "innerLabel")
						.style("text-anchor", "middle")
			}
			var total:Number = 0;
			data.forEach(function(d:*):void {
				total += d.value;
			});
			innerLabel.text("Total: " + total);
		}

		/**
		 * setup the text tag (the pie slice text label)
		 */
		private function setupGTextDOM():void {
			var scopedArc:* = d3Arc;
//			var scopedRadius:Number = radius;
			gtextDOM = arcDOM.append("text")
					.attr("class", "arcLabel")
					.attr("transform", function(d:Object):String { return "translate(" + scopedArc.centroid(d) + ")"; })
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
		private function setupGPathDOM():void {
			var scopedColor:* = colorScale;
			gpathDOM = arcDOM.append("path")
					.attr("class", "arcpath")
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
		private function setupArcDOM(data:Array):void {
			var scopedPie:* = d3Pie;
			svgDOM.selectAll(".arc").remove();
			arcDOM = svgDOM.selectAll(".arc")
					.data(scopedPie(data)).enter()
					.append("g")
					.attr("class", "arc");
		}

		/**
		 * setup the svg DOM object
		 */
		private function setupSVGDOM():void {
			if (svgDOM == null) {
				svgDOM = d3Static.select(piechartsvg[0])
						.append("g")
						.attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
			}
		}

		/**
		 * setup the d3 pie object
		 */
		private function setupD3Pie():void {
			if (d3Pie == null) {
				d3Pie = layout.pie()
						.sort(null)
						.value(function (d:*):* {
							return d.value;
						});
			}
		}

		/**
		 * calculate the radius based on the width and height of the svg area
		 */
		private function setupRadius():void {
			if (radius == -1) { // if the radius hasn't been set yet
				width = piechartsvg.width();
				height = piechartsvg.height();
				radius = CircleMath.calcRadius(width, height);
			}
		}

		/**
		 * setup the color d3 scale
		 */
		private function setupColorScale():void {
			if (colorScale == null) {
				colorScale = scale.ordinal()
						.range(colors);
			}
		}

		/**
		 * setup the base d3 arc object, setting the outer and inner radius
		 */
		private function setupD3Arc(): void {
			if (d3Arc == null) {
				d3Arc = svg.arc()
						.outerRadius(radius)
						.innerRadius(50);
			}
		}

		/**
		 * when we get data, give it to the grid
		 */
		private function applyDataToChart(data:Array):void {
			// Since this is called after the Behavior is setup, we can now setup the chart
			setupChart();
			// Actually apply the data
			setupArcDOM(data);
			setupGPathDOM();
			setupGTextDOM();
			setupInnerLabel(data);
		}

		/**
		 * setup the chart and get it ready to receive data
		 */
		private function setupChart():void {
			setupRadius();
			setupColorScale();
			setupD3Arc();
			setupD3Pie();
			setupSVGDOM();
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
//			CircleMath;
		}

		/**
		 * Constructor
		 */
		public function PieChart() { }
	}
}