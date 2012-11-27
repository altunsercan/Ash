package net.richardlord.ash.tools.entitybuilder
{
	import ash.core.Entity;
	
	import flash.utils.Dictionary;
	
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
		public function buildComponent( componentClass:Class, nodeCompClass:Class = null ):IComponentMapper
		{
			if( componentClass == null )
			{
				throw Error( "Cannot build null component" );
			}
			if( nodeCompClass == null )
			{
				nodeCompClass = componentClass;
			}
			var mapper:ComponentMapper = new ComponentMapper( componentClass, nodeCompClass );
			m_map[ nodeCompClass ] = mapper;
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
	private var m_nodeCompClass:Class;
	private var m_values:Dictionary;
	public function ComponentMapper( componentClass:Class, nodeCompClass:Class )
	{
		m_class = componentClass;
		m_nodeCompClass = nodeCompClass;
		m_values = new Dictionary();
	}
	
	internal function getClass():Class
	{
		return m_nodeCompClass;
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
	
	public function toValue( sourceObj:* = null ):*
	{
		return value;
	}
}

internal class ObjectMap
{
	public var componentParameter:String;
	public var sourceParameter:String;
	
	public function toValue( sourceObj:* = null ):*
	{
		if( sourceParameter == "" ) /// if empty string use source object
			return sourceObj;
		return sourceObj[sourceParameter];
	}
}