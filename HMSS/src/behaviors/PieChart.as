package behaviors {
	import d3.D3Arc;
	import d3.D3Pie;
	import d3.D3Scale;
	import d3.D3Selection;
	import d3.d3Static;
	import d3.layout;
	import d3.scale;

	import randori.behaviors.AbstractBehavior;

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
	public class PieChart extends AbstractBehavior
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

		private var width:Number;
		private var height:Number;
		private var radius:Number;

		private var color:D3Scale;
		private var arc:D3Arc;
		private var pie:D3Pie;
		private var g:D3Selection;
		private var gpath:D3Selection;
		private var gtext:D3Selection;

		//----------------------------------------------------------------------------
		//
		// Methods
		//
		//----------------------------------------------------------------------------

		/**
		 * when we get data, give it to the grid
		 */
		private function applyDataToChart(data:Array):void {
			var scopedPie:* = pie;
			svg.selectAll(".arc").remove();
//			var arcs = svg.selectAll(".arc");
//			var scopedD = scopedPie(data);
//			var dat = arcs.data(scopedD);
//			var enter = dat.enter();
//			var arcsg = enter.append("g").attr("class", "arc");
			g = svg.selectAll(".arc")
					.data(scopedPie(data)).enter()
					.append("g")
					.attr("class", "arc");

			var scopedColor:* = color;
			gpath = g.append("path")
					.attr("d", arc)
					.style("fill", function(d:Object):* { return scopedColor(d.data.name); });

			var scopedArc:* = arc;
			var scopedRadius:Number = radius;
			gtext = g.append("text")
					.attr("class", "arclabel")
//					.attr("transform", function(d:Object):String { return "translate(" + scopedArc.centroid(d) + ")"; })
					.attr("transform", function(d:*):String {
						var c:Array = scopedArc.centroid(d);
						var x:Number = c[0];
						var y:Number = c[1];
						// pythagorean theorem for hypotenuse
						var h:Number = Math.sqrt(x*x + y*y);
						return "translate(" + (x/h * scopedRadius) +  ',' +
								(y/h * scopedRadius) +  ")";
					})
					.attr("dy", ".35em")
//					.style("text-anchor", "middle")
					.attr("text-anchor", function(d:*):String {
						// are we past the center?
						return (d.endAngle + d.startAngle)/2 > Math.PI ?
								"end" : "start";
					})
					.text(function(d:Object):String { return d.data.name + " (" + d.data.value + ")"; });
		}

		/**
		 * setup the chart and get it ready to receive data
		 */
		private function setupChart():void {
			width = 500;
			height = 300;
			radius = Math.min(width, height) / 2;

			color = scale.ordinal()
					.range(["#9ECACF", "#B8E3E8", "#3F75A2", "#588EBC"]);

			arc = d3.svg.arc()
					.outerRadius(radius - 10)
					.innerRadius(0);

			pie = layout.pie()
					.sort(null)
					.value(function(d:*):* { return d.value; });

			svg = d3Static.select(this.decoratedNode[0]).append("svg")
					.append("g")
					.attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
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
			setupChart();
		}

		/**
		 * Constructor
		 */
		public function PieChart() { }
	}
}