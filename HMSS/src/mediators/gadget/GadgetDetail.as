package mediators.gadget {
	import behaviors.PercentCompleteAreaChart;

	import eventBus.HMSSBus;

	import randori.behaviors.AbstractMediator;
	import randori.jquery.Event;
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
	 *
	 * @author Jared Schraub <jschraub@digitalprimates.net>
	 */
	public class GadgetDetail extends AbstractMediator {

		[View]
		public var gadgetName:JQuery;

		[View]
		public var gadgetDetailImage:JQuery;

		[View]
		public var gadgetStatus:JQuery;

		[View]
		public var gadgetProgressChart:PercentCompleteAreaChart;

		[View]
		public var backToList:JQuery;

		[Inject]
		public var bus:HMSSBus;

		private var gadget:Gadget;

		override public function setViewData(viewData:Object):void {
			gadget = viewData as Gadget;

			gadgetName.html(gadget.name);
			gadgetDetailImage.attr("src", gadget.image);
			gadgetStatus.html(gadget.status);
			gadgetProgressChart.data = gadget.progressPercents;
		}

		override protected function onRegister():void {
			backToList.click( handleBack );
		}

		override protected function onDeregister():void {
			backToList.off("click");
		}

		private function handleBack( e:Event ):void {
			bus.gadgetClose.dispatch();
		}
	}
}