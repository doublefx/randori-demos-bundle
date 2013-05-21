package utils {

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
	 * Date: 5/20/13
	 * Time: 2:25 PM
	 * @author Jared Schraub <jschraub@digitalprimates.net>
	 */
	public class CircleMath {
		public static function calcRadius(width:Number, height:Number):Number {
			return Math.min(width, height) / 2;
		}
		public static function calcHypotenuse(x:Number, y:Number):Number {
			return Math.sqrt(x * x + y * y);
		}

		public static function angleLeftOfCenter(endAngle:Number, startAngle:Number):Boolean {
			return (endAngle + startAngle) / 2 > Math.PI;
		}

		public static function calcComponentOfOuterCircle(x:Number, h:Number, r:Number):Number {
			return x / h * r;
		}

		public function CircleMath() { }
	}
}