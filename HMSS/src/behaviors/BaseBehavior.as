package behaviors {
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
	 * Date: 4/23/13
	 * Time: 2:12 PM
	 * @author Jared Schraub <jschraub@digitalprimates.net>
	 */
	public class BaseBehavior extends AbstractBehavior {

		public function set data(value:Object): void {
			decoratedNode.html(value);
		}

		override protected function onRegister():void {

		}

		override protected function onDeregister():void {

		}

	}
}