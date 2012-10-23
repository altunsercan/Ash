package net.richardlord.ash.tools.entitybuilder
{
	import flash.utils.Dictionary;
	
	import net.richardlord.ash.core.Entity;
	import net.richardlord.ash.tools.entitybuilder.api.IComponentMapper;

	public class EntityBuilder
	{
		private var m_map:Dictionary;
		public function EntityBuilder()
		{
			m_map = new Dictionary();
		}
		
		/**
		 * Adds new component to builder. When instantiating new entities, builder will create
		 * this component and try to fill neccessary parameters.
		 *  
		 * @param componentClass Component Class
		 * @return Mapping interface
		 * 
		 */
		public function buildComponent( componentClass:Class ):IComponentMapper
		{
			if( componentClass == null )
			{
				throw Error( "Cannot build null component" );
			}
			var mapper:ComponentMapper = new ComponentMapper( componentClass );
			m_map[ componentClass ] = mapper;
			return mapper;
		}
		
		/**
		 * Instantiate new entity based on previous configurations
		 * on the builder. You need to give a source object if you 
		 * used object mapping previously.
		 *  
		 * @return 
		 * 
		 */
		public function instantiateEntity( sourceObject:* = null ):Entity
		{
			var ent:Entity = new Entity();
			for each( var mapApi:IComponentMapper in m_map )
			{
				var map:ComponentMapper = ComponentMapper( mapApi );
				ent.add( map.createComponent( sourceObject ), map.getClass() );
			}
			return ent;
		}
		
		/**
		 * Incase you only need components without an entity this function
		 * returns array of components built.
		 * 
		 * @param sourceObject
		 * @return 
		 * 
		 */
		public function instantiateComponents( sourceObject:* = null ):Array
		{
			var arr:Array = new Array();
			for each( var mapApi:IComponentMapper in m_map )
			{
				var map:ComponentMapper = ComponentMapper( mapApi );
				arr.push( map.createComponent( sourceObject ) );
			}
			return arr;
		}
		
			
	}
}
import flash.utils.Dictionary;

import net.richardlord.ash.tools.entitybuilder.api.IComponentMapper;

internal class ComponentMapper implements IComponentMapper
{
	private var m_class:Class;
	private var m_values:Dictionary;
	public function ComponentMapper( componentClass:Class )
	{
		m_class = componentClass;
		m_values = new Dictionary();
	}
	
	internal function getClass():Class
	{
		return m_class;
	}
	
	internal function createComponent( sourceObj:* = null ):*
	{
		var component:*;
		component = new m_class();	
		
		/// Apply mapping
		for( var key:Object in m_values)
		{
			component[key] = m_values[key].toValue( sourceObj );
		}
		
		return component;
	}
	
	public function mapDefault( parameter:String, value:* ):IComponentMapper
	{
		var map:DefaultMap = new DefaultMap();
		map.parameter = parameter;
		map.value = value;
		m_values[ parameter ] = map; 
		
		return this;
	}
	
	public function mapObjectParameter( componentParameter:String, sourceParameter:String):IComponentMapper
	{
		var map:ObjectMap = new ObjectMap();
		map.componentParameter = componentParameter;
		map.sourceParameter = sourceParameter;
		m_values[ componentParameter ] = map; 
		
		return this;
	}
	
}

internal class DefaultMap
{
	public var parameter:String;
	public var value:*;
	
	public function toValue( sourceObj:* = null ):void
	{
		return value;
	}
}

internal class ObjectMap
{
	public var componentParameter:String;
	public var sourceParameter:String;
	
	public function toValue( sourceObj:* = null ):void
	{
		return sourceObj[sourceParameter];
	}
}