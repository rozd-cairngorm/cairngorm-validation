/**
 *  Copyright (c) 2007 - 2009 Adobe
 *  All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 */
package com.adobe.cairngorm.validation.validators
{
	import mx.validators.Validator;
	import mx.validators.ValidationResult;
	import mx.events.ValidationResultEvent;

	/**
	 * Check if a url has a valid format
	 * This doesn't necessarily mean it is the correct url 
	 */ 
	public class URLValidator extends Validator
	{
		
		public static const DEFAULT_ERROR_MESSAGE : String = "Please enter a valid url";
		public static const DEFAULT_REGEXP_PATTERN : String = "^(https?://)?([-\\w]+)\\.([-\\w\\.]+)+(:\\d+)?(/([\\w/_\\.]*(\\?\\S+)?)?)?$";
		
		public var errorMessage : String = DEFAULT_ERROR_MESSAGE;
		public var regexpPattern : String = DEFAULT_REGEXP_PATTERN;
		
		override protected function doValidation( value : Object ) : Array 
		{
			var results : Array = new Array();
			if( required || String( value ) != "" )
			{
				trace("URLValidator::doValidation:" + [ String( value ).search( regexp ), String(value), regexp, regexpPattern ]);
				var regexp : RegExp = new RegExp( regexpPattern );
				if( String( value ).search( regexp ) == -1 )
				{
					results.push(
						new ValidationResult(
							true, 
							"url", 
							"invalid url", 
	                        errorMessage));
	
				}
			}
			return results;
        }
        
        public function reset() : void
        {
        	dispatchEvent( new ValidationResultEvent("valid"));
        }
	}
}