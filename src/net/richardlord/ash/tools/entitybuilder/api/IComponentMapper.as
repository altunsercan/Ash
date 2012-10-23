package net.richardlord.ash.tools.entitybuilder.api
{
	public interface IComponentMapper
	{
		function mapDefault( parameter:String, value:* ):IComponentMapper;
		function mapObjectParameter( componentParameter:String, sourceParameter:String):IComponentMapper;
	}
}