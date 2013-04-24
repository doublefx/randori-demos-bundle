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
 * @author Michael Labriola <labriola@digitalprimates.net>
 */
package mediators {
	import eventBus.HMSSBus;

	import randori.behaviors.AbstractMediator;
	import randori.behaviors.List;

	import services.LabService;
	import services.vo.Gadget;

	public class LabsMediator extends AbstractMediator {

		[View]
		public var gadgets:List;

		[Inject]
		public var labService:LabService

		[Inject]
		public var bus:HMSSBus;

		override protected function onRegister():void {
			gadgets.listChanged.add( handleGadgetSelected );
			labService.get().then( displayInList );
		}

		private function handleGadgetSelected( gadget:Gadget ):void {
			bus.gadgetSelected.dispatch( gadgets.selectedItem );
		}

		private function displayInList( data:Array ):void {
			gadgets.data = data;
		}

		public function LabsMediator() {
			super();
		}
	}
}