package com.adobe.cairngorm.validation
{
	import flash.events.EventDispatcher;
	
	import mx.events.ValidationResultEvent;
	import mx.validators.IValidatorListener;
	
	public class ValidatorMultipleListeners extends EventDispatcher implements IValidatorListener
	{
		private var listeners : Array;
		
		private var _errorString : String;
		private var _validationSubField : String;
		
		public function ValidatorMultipleListeners( listeners : Array )
		{
			this.listeners = listeners;
		}
		
		public function get errorString():String
		{
			return _errorString;
		}
		
		public function set errorString(value:String):void
		{
			_errorString = value;
			
			for each( var listener : IValidatorListener in listeners )
			{
				listener.errorString = errorString;
			}
		}
		
		public function get validationSubField():String
		{
			return _validationSubField;
		}
		
		public function set validationSubField(value:String):void
		{
			_validationSubField = value;
			
			for each( var listener : IValidatorListener in listeners )
			{
				listener.validationSubField = validationSubField;
			}
		}
		
		public function validationResultHandler(event:ValidationResultEvent):void
		{
			for each( var listener : IValidatorListener in listeners )
			{
				listener.validationResultHandler( event );
			}
		}
	}
}