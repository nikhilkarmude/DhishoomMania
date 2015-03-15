package Code.Level
{
	import Code.Geometry.AABB;
	import Code.System.*;
	import Code.Maths.Vector2;
	import Code.*;
	
	public class Map
	{
		static private var m_gTileCentreOffset:Vector2 = new Vector2( Constants.kTileSize/2, Constants.kTileSize/2 );
		static private var m_gTileHalfExtents:Vector2 = new Vector2( Constants.kTileSize/2, Constants.kTileSize/2 );
		
		private var m_aabbTemp:AABB;
		private var m_platformer:Platformer;
		
		/// <summary>
		/// 
		/// </summary>
		public function Map( platformer:Platformer )
		{
			m_platformer = platformer;
				
			Assert( m_Map.length==m_Width*m_Height, "Map dimensions don't match constants!" );
			Assert( m_Map.length==m_BackgroundMap.length, "Map and background dimensions don't match!" );
			Assert( m_Map.length==m_MidgroundMap.length, "Map and midground dimensions don't match!" );
			
			m_aabbTemp = new AABB( );
			
			//UnitTest( );
		}
		
		/// <summary>
		/// Check some basic stuff with the coordinate system
		/// </summary>
		private function UnitTest( ):void
		{
			var iMin:int = 0;
			var jMin:int = 0;
			
			var xMin:Number = TileCoordsToWorldX( iMin );
			var yMin:Number = TileCoordsToWorldY( jMin );
			
			var iMax:int = 9;
			var jMax:int = 9;
			
			var xMax:Number = TileCoordsToWorldX( iMax );
			var yMax:Number = TileCoordsToWorldY( jMax );
			
			var iMinCheck:int = WorldCoordsToTileY( yMin );
			
			Assert( iMin==iMinCheck, "UnitTest(): fail!" );
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_Width( ):int
		{
			throw new NotImplementedException;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_Height( ):int
		{
			throw new NotImplementedException;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_Map( ):Vector.<uint>
		{
			throw new NotImplementedException;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_BackgroundMap( ):Vector.<uint>
		{
			throw new NotImplementedException;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_MidgroundMap( ):Vector.<uint>
		{
			throw new NotImplementedException;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function GetTile( i:int, j:int ):uint
		{
			//Assert( i>=0&&i<=m_Width && j>=0 && j<=m_Height, "Map.GetTile(): index out of range" );
			//return m_Map[j*m_Width+i];
			return GetTileSafe( m_Map, i, j );
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function GetBackgroundTile( i:int, j:int ):uint
		{
			/*Assert( i>=0&&i<=m_Width && j>=0 && j<=m_Height, "Map.GetTile(): index out of range" );
			return m_BackgroundMap[j*m_Width+i];*/
			return GetTileSafe( m_BackgroundMap, i, j );
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function GetMidgroundTile( i:int, j:int ):uint
		{
			/*Assert( i>=0&&i<=m_Width && j>=0 && j<=m_Height, "Map.GetTile(): index out of range" );
			return m_MidgroundMap[j*m_Width+i];*/
			return GetTileSafe( m_MidgroundMap, i, j );
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function GetTileSafe( map:Vector.<uint>, i:int, j:int ):uint
		{
			if ( i>=0&&i<m_Width&&j>=0&&j<m_Height )
			{
				return map[j*m_Width+i];
			}
			else 
			{
				return eTileTypes.kInvalid;
			}
		}
		
		/// <summary>
		/// calculate the position of a tile: 0,0 maps to Constants.kWorldHalfExtents
		/// </summary>
		static public function TileCoordsToWorldX( i:int ):Number
		{
			return i*Constants.kTileSize - Constants.kWorldHalfExtents.m_x;
		}
		
		/// <summary>
		/// calculate the position of a tile: 0,0 maps to Constants.kWorldHalfExtents 
		/// </summary>
		static public function TileCoordsToWorldY( j:int ):Number
		{
			return j*Constants.kTileSize - Constants.kWorldHalfExtents.m_y;
		}
		
		/// <summary>
		/// go from world coordinates to tile coordinates
		/// </summary>
		static public function WorldCoordsToTileX( worldX:Number ):int
		{
			return ( worldX+Constants.kWorldHalfExtents.m_x )/Constants.kTileSize;
		}
		
		/// <summary>
		/// go from world coordinates to tile coordinates
		/// </summary>
		static public function WorldCoordsToTileY( worldY:Number ):int
		{
			return ( worldY+Constants.kWorldHalfExtents.m_y )/Constants.kTileSize;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function GetTileFromPos( pos:Vector2 ):uint
		{
			var i:int = WorldCoordsToTileX( pos.m_x );
			var j:int = WorldCoordsToTileY( pos.m_y );
			
			return GetTile( i, j );
		}
		
		/// <summary>
		/// 
		/// </summary>
		static public function IsTileObstacle( tile:int ):Boolean
		{
			return tile==eTileTypes.kEarthMid||tile==eTileTypes.kEarthGrass||tile==eTileTypes.kCheeseTile;
		}
		
		/// <summary>
		/// 
		/// </summary>
		static public function IsTileDeadly( tile:int ):Boolean
		{
			return tile==eTileTypes.kEarthSpikes;
		}
		
		/// <summary>
		/// 
		/// </summary>
		static public function IsTileLadder( tile:int ):Boolean
		{
			return tile==eTileTypes.kLadderMid||tile==eTileTypes.kLadderTop;
		}
		
		/// <summary>
		/// 
		/// </summary>
		static public function IsTileLadderTop( tile:int ):Boolean
		{
			return tile==eTileTypes.kLadderTop;
		}
		
		/// <summary>
		/// 
		/// </summary>
		static public function IsJumpThroughPlatform( tile:int ):Boolean
		{
			return tile==eTileTypes.kJumpThroughPlatform;
		}
		
		/// <summary>
		/// 
		/// </summary>
		static public function IsTileGoal( tile:int ):Boolean
		{
			return tile==eTileTypes.kGoal;
		}
		
		
		/// <summary>
		/// 
		/// </summary>
		static public function FillInTileAabb( i:int, j:int, outAabb:AABB ):void
		{
			outAabb.Initialise( new Vector2
								(
									TileCoordsToWorldX(i), 
									TileCoordsToWorldY(j)
								).AddTo(m_gTileCentreOffset), m_gTileHalfExtents );
		}
		
		/// <summary>
		/// Call out to the action for each tile within the given world space bounds
		/// </summary>
		public function DoActionToTilesWithinAabb( min:Vector2, max:Vector2, action:Function, dt:Number ):void
		{
			// round down
			var minI:int = WorldCoordsToTileX(min.m_x);
			var minJ:int = WorldCoordsToTileY(min.m_y);
			
			// round up
			var maxI:int = WorldCoordsToTileX(max.m_x+0.5);
			var maxJ:int = WorldCoordsToTileY(max.m_y+0.5);
			
			for ( var i:int = minI; i<=maxI; i++ )
			{
				for ( var j:int = minJ; j<=maxJ; j++ )
				{
					// generate aabb for this tile
					FillInTileAabb( i, j, m_aabbTemp );
					
					// call on the mid-ground map (ladders and special objects)
					action( m_aabbTemp, GetMidgroundTile( i, j ), dt, i, j );
				}
			}
			
			for ( i = minI; i<=maxI; i++ )
			{
				for ( j = minJ; j<=maxJ; j++ )
				{
					// generate aabb for this tile
					FillInTileAabb( i, j, m_aabbTemp );
					
					// call the delegate on the main collision map
					action( m_aabbTemp, GetTile( i, j ), dt, i, j );
				}
			}
		}
	}
}
