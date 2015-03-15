package Code.Level
{
	import Code.*;
	
	public class LastMap extends Map
	{
		private const kMapWidth:int = 18;
		private const kMapHeight:int = 10;
		
		// map for the level
		private var m_map:Vector.<uint> = Vector.<uint>
		( 
			[
				4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,
				4,52,19,51,0,0,0,52,19,51,0,52,19,51,0,19,51,4,
				4,17,15,18,0,0,0,17,15,18,35,17,15,49,51,15,18,4,
				4,17,15,49,51,15,0,50,15,18,34,17,15,15,49,15,18,4,
				4,0,48,15,49,15,50,15,47,29,34,17,15,48,15,15,18,4,
				4,0,0,48,15,15,15,47,29,0,34,17,15,0,48,15,18,4,
				4,0,0,0,16,16,16,29,0,0,0,0,16,0,31,16,29,4,
				4,0,42,42,42,42,42,42,42,42,42,42,42,42,42,42,0,4,
				4,0,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,
				4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4
			]
		);
		
		private var m_backgroundMap:Vector.<uint> = Vector.<uint>
		( 
			[
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,52,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,31,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			]
		);
		
		private var m_midgroundMap:Vector.<uint> = Vector.<uint>
		( 
			[
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,41,0,0,0,52,0,0,0,
				0,0,0,0,52,19,51,0,0,0,0,0,0,41,17,0,0,0,
				0,0,0,41,17,0,18,0,0,0,0,0,0,0,17,0,0,0,
				0,0,0,0,17,0,18,0,0,0,0,0,0,18,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,18,0,0,0,0,
				0,37,0,0,38,0,38,0,0,0,0,0,38,29,38,0,37,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
				0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			]
		);
		
		/// <summary>
		/// 
		/// </summary>
		public function LastMap( platformer:Platformer )
		{
			super( platformer );
		}
		
		/// <summary>
		/// 
		/// </summary>
		public override function get m_Width( ):int
		{
			return kMapWidth;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public override function get m_Height( ):int
		{
			return kMapHeight;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public override function get m_Map( ):Vector.<uint>
		{
			return m_map;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public override function get m_BackgroundMap( ):Vector.<uint>
		{
			return m_backgroundMap;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public override function get m_MidgroundMap( ):Vector.<uint>
		{
			return m_midgroundMap;
		}
	}
	
}
