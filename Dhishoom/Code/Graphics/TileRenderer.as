package Code.Graphics
{
	import flash.display.*;
	import Code.Geometry.*;
	import Code.Maths.*;
	import Code.Constants;
	import Code.Platformer;
	
	public class TileRenderer
	{
		private var m_tiles:Vector.<MovieClip>;
		private var m_numX:int;
		private var m_numY:int;
		private var m_tileWidth:int;
		private var m_tileHeight:int;
		private var m_camera:Camera;
		private var m_zDepth:Number;
		
		private var m_tempAabb:AABB;
		
		/// <summary>
		/// Constructor
		/// </summary>	
		public function TileRenderer( tileType:Class, width:int, height:int, camera:Camera, stage:Platformer, zDepth:Number )
		{
			m_tileWidth = width;
			m_tileHeight = height;
			m_camera = camera;
			m_zDepth = zDepth;
			
			m_tempAabb = new AABB( );
			
			m_numX = Constants.kScreenDimensions.m_x/width+2;
			m_numY = Constants.kScreenDimensions.m_y/height+2;
			
			m_tiles = new Vector.<MovieClip>( m_numX*m_numY );
			
			// run though and create all the tiles we need, this fuction takes
			// a closeure which actually does the work
			PositionLogic( function( index:int, xCoord:int, yCoord:int ):void
			{
				m_tiles[index] = new tileType( );
				m_tiles[index].x = xCoord;
				m_tiles[index].y = yCoord;
				m_tiles[index].cacheAsBitmap = true;
				
				// add the tile and send it to the back
				stage.addChild( m_tiles[index] );
				stage.setChildIndex( m_tiles[index], 0 );
			});
		}
		
		/// <summary>
		/// This function runs through and computes the position of each tile - it takes a closeure 
		/// so you can insert your own inner logic to run at each location
		/// </summary>
		private function PositionLogic( action:Function ):void
		{
			m_camera.GetWorldSpaceOnScreenAABB( m_tempAabb );
			
			var screenTopLeft:Vector2 = m_tempAabb.m_TopLeft;
			
			// stop the background from crawling around due to pixel trucation
			screenTopLeft.RoundTo( );
			
			// calculate the top left of the screen, scaled for z depth
			var scaledTopLeft:Vector2 = screenTopLeft.MulScalar( 1/m_zDepth );
			var tileX:int = Math.floor(scaledTopLeft.m_x / m_tileWidth);
			var tileY:int = Math.floor(scaledTopLeft.m_y / m_tileHeight);
			
			// this offset corrects for translation caused by the divide by z
			var offset:Vector2 = scaledTopLeft.Sub( screenTopLeft );
			
			// get the starting tile coords
			var startX:int = tileX*m_tileWidth - offset.m_x;
			var startY:int = tileY*m_tileHeight - offset.m_y;
			var xCoord:int = startX;
			var yCoord:int = startY;
			
			// run though and call the closure for each tile position
			for ( var j:int = 0; j<m_numY; j++ )
			{
				xCoord = startX;
				for ( var i:int = 0; i<m_numX; i++ )
				{
					var index:int = j*m_numX+i;
									
					action(index, xCoord, yCoord);
					
					xCoord += m_tileWidth;
				}
				yCoord += m_tileHeight;
			}
		}
		
		/// <summary>
		/// Update all the tiles to the new coordinates based on the camera's new position
		/// </summary>	
		public function Update( ):void
		{
			PositionLogic( function( index:int, xCoord:int, yCoord:int ):void
			{
				m_tiles[index].x = xCoord;
				m_tiles[index].y = yCoord;
			});
		}
	}
}
