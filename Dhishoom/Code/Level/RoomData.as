package Code.Level
{
	
	public class RoomData
	{
		private var m_mapWidth:int;
		private var m_mapHeight:int;
		
		private var m_map:Vector.<uint>;
		private var m_backgroundMap:Vector.<uint>;
		private var m_midgroundMap:Vector.<uint>;
		
		public function RoomData( width:int, height:int, map:Vector.<uint>, backgroundMap:Vector.<uint>, midgroundMap:Vector.<uint> )
		{
			m_mapWidth = width;
			m_mapHeight = height;
			m_map = map;
			m_backgroundMap = backgroundMap;
			m_midgroundMap = midgroundMap;
		}
		
		public function get m_MapWidth( ):int
		{
			return m_mapWidth;
		}
		
		public function get m_MapHeight( ):int
		{
			return m_mapHeight;
		}
	}
}
