package behaviors {
import randori.behaviors.AbstractBehavior;
import randori.jquery.Event;
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
	 * Date: 5/16/13
	 * Time: 3:05 PM
	 * @author Jared Schraub <jschraub@digitalprimates.net>
	 */
	public class Filmstrip extends AbstractBehavior {

		[View]
		public var images:JQuery;

		private var itemSelectedHandlers:Array

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

			// remove the list items that already exist
			images.remove(".filmstripItem");

			// add each new list item
			var item:JQuery
			var totalWidth:Number = 0;
			for (var i:int = 0; i < _data.length; i++) {
				// create the item
				images.append("<img id='gadget" + i + "' class='filmstripItem' src='" + _data[i].image + "'/>");
				// add a click listener to the item
				item = images.find("#gadget" + i);
				item.click(_data[i], itemClicked);

				// total the width of the items
				totalWidth += item.outerWidth(true);
			}
			// set the width of the imageRow to the total width of the items
			images.width(totalWidth);
		}

		public function itemClicked(event:Event):void {
			if (event == null)
				return;
			itemSelectedHandlers.forEach(function (f:Function):void {
				f(event.data);
			});
		}

		public function registerItemSelect(func:Function):void {
			itemSelectedHandlers.push(func);
		}

		override protected function onRegister():void {
			itemSelectedHandlers = new Array();
		}

		override protected function onDeregister():void {

		}
	}
}