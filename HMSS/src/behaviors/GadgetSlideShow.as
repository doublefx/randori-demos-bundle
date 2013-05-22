package behaviors {
	import behaviors.charts.DateAreaChart;
	import behaviors.charts.GroupedBarChart;
	import behaviors.charts.PieChart;

	import randori.behaviors.AbstractBehavior;
	import randori.jquery.JQuery;

	import services.vo.Gadget;

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
	 * Date: 4/25/13
	 * Time: 4:04 PM
	 * @author Jared Schraub <jschraub@digitalprimates.net>
	 */
	public class GadgetSlideShow extends AbstractBehavior {

		//----------------------------------------------------------------------------
		//
		// Properties
		//
		//----------------------------------------------------------------------------

		//----------------------------------------
		// data
		//----------------------------------------

		[View]
		public var gadgetSelector:Filmstrip;
		[View(required="false")]
		public var mainSlide:JQuery;
		[View(required="false")]
		public var gadgetName:JQuery;
		[View(required="false")]
		public var gadgetStatus:JQuery;
		[View(required="false")]
		public var gadgetDescription:JQuery;
		[View(required="false")]
		public var gadgetProgressChart:DateAreaChart;
		[View(required="false")]
		public var gadgetUsesChart:PieChart;
		[View(required="false")]
		public var gadgetUsesCompareChart:GroupedBarChart;

		public var activeGadget:Gadget;

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

			if (gadgetSelector)
				gadgetSelector.data = _data;

			// set the active item to the first item in the list
			setActive(_data[0]);

			dataToCharts(_data);
		}

		public function dataToCharts(data:Array):void {
			if (gadgetUsesCompareChart) {
				var uses:Array = new Array();
				data.forEach(function (gadget:Gadget):void {
					uses.push({name: gadget.name,
								"Lab Fails": gadget.failLabUses,
								"Field Fails": gadget.failFieldUses,
								"Lab Successes": gadget.succLabUses,
								"Field Successes": gadget.succFieldUses})
				});
				gadgetUsesCompareChart.margin = {top: 20, right: 20, bottom: 160, left: 50};
				gadgetUsesCompareChart.colors = ["#B8E3E8", "#9ECACF", "#588EBC", "#3F75A2"];
				gadgetUsesCompareChart.data = uses;
				gadgetUsesCompareChart.setYAxisText("Gadget Uses");
			}
		}

		public function setActive(gadget:Gadget):void {
			if (activeGadget == gadget)
				return;
			// set the active gadget
			activeGadget = gadget;
			// set the displays of the active gadget
			if (mainSlide)
				mainSlide.attr("src", gadget.image);
			if (gadgetName)
				gadgetName.html(gadget.name);
			if (gadgetStatus)
				gadgetStatus.html(gadget.status);
			if (gadgetDescription)
				gadgetDescription.html(gadget.description);
			if (gadgetProgressChart) {
				gadgetProgressChart.margin = {top: 20, right: 20, bottom: 70, left: 50};
				gadgetProgressChart.data = gadget.progressPercents;
				gadgetProgressChart.setYAxisText("Percent Complete");
			}
			if (gadgetUsesChart) {
				gadgetUsesChart.colors = ["#B8E3E8", "#9ECACF", "#588EBC", "#3F75A2"];
				gadgetUsesChart.data = [{name:"Lab Fails", value:gadget.failLabUses},
										{name:"Field Fails", value:gadget.failFieldUses},
										{name:"Lab Successes", value:gadget.succLabUses},
										{name:"Field Successes", value:gadget.succFieldUses}];
			}
		}

		private function handleGadgetSelected( gadget:Gadget ):void {
			setActive(gadget);
		}

		override protected function onRegister():void {
			gadgetSelector.registerItemSelect(handleGadgetSelected);
		}

		override protected function onDeregister():void {

		}
	}
}