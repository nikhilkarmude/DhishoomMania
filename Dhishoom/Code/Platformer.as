package Code
{
	import Code.Maths.Vector2;
	import Code.System.*;
	import Code.Maths.*;
	import Code.Characters.*;
	import Code.Graphics.*;
	import flash.display.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import Code.Geometry.AABB;
	import Code.Level.*;
	import Code.Gui.*;
	import Code.Physics.*;
	import Code.Pickups.*;
	import MoveKeysFla;
	
	[SWF(width="640", height="360", backgroundColor="#F4DCB0")]
	public class Platformer extends GameLoop
	{
		private const kMaxCharacters:int = 500;
		private const kNumFpsSamples:int = 4;
		
		private var m_map:Map;
		
		private var m_levels:ReferenceArray;
		private var m_currentLevel:int;
		
		// fast allocator for vector2s, cleared once per frame
		static public var m_gTempVectorPool:VectorPool;
		
		private var m_keyboard:Keyboard;
		private var m_player:Player;
		private var m_camera:Camera;
		private var m_hud:Hud;
		
		private var m_moveableObjects:ReferenceArray;
		private var m_onScreenMos:ReferenceArray;
		
		private var m_dynamicGfx:Vector.<Sprite>;
		
		private var m_backgroundTR:TileRenderer;
		private var m_midgroundTR:TileRenderer;
		
		/// <summary>
		/// 
		/// </summary>	
		public function Platformer( )
		{
			super( );
						 
			// keyboard controller
			m_keyboard = new Keyboard( this.stage );
			
			// temporary vector2 pool for fast allocation
			m_gTempVectorPool = new VectorPool( 10000 );
			
			m_moveableObjects = new ReferenceArray( MoveableObject, kMaxCharacters );
			m_onScreenMos = new ReferenceArray( MoveableObject, kMaxCharacters );
			
			m_dynamicGfx = new Vector.<Sprite>( );
			
			m_currentLevel = -1;
			m_levels = new ReferenceArray( Map );
			m_levels.Add( new StartMap( this ) );
			m_levels.Add( new Map1( this ) );
			m_levels.Add( new Map2( this ) );
			m_levels.Add( new LastMap( this ) );
			
			
			// trigger the first level
			LevelComplete( );
			
			// set 30 fps
			this.stage.frameRate = Constants.kDesiredFps;
			
			// start the update loop
			Start( );
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_Keyboard( ):Keyboard
		{
			return m_keyboard;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_Player( ):Player
		{
			return m_player;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		private function CreateTilesInner( tileSet:Vector.<uint>, addtoScene:Boolean=true ):void
		{
			var index:int = 0;
			for each ( var tileCode:uint in tileSet )
			{
				var tile:MovieClip;
				
				// calculate the position of each tile: 0,0 maps to Constants.kWorldHalfExtents
				var tileI:int = index%m_map.m_Width;
				var tileJ:int = index/m_map.m_Width;
				
				var tileX:int = Map.TileCoordsToWorldX(tileI);
				var tileY:int = Map.TileCoordsToWorldY(tileJ);
				
				var tilePos:Vector2 = new Vector2( tileX, tileY );
				
				// create each tile
				switch ( tileCode )
				{
					//
					// foreground tiles
					//
					
					case eTileTypes.kReverseDirection:				// fall through to next
					case eTileTypes.kEmpty:							tile = null;									break;
					
					case eTileTypes.kEarthGrassLeft:				tile = new EarthGrassLeftFla( );				break;
					case eTileTypes.kEarthGrass:					tile = new EarthGrassFla( );					break;
					case eTileTypes.kEarthGrassRight:				tile = new EarthGrassRightFla( );				break;
					case eTileTypes.kEarthMid:						tile = new EarthMidFla( );						break;
					case eTileTypes.kEarthTop:						tile = new EarthTopFla( );						break;
					case eTileTypes.kEarthRight:					tile = new EarthRightFla( );					break;
					case eTileTypes.kEarthLeft:						tile = new EarthLeftFla( );						break;
					case eTileTypes.kEarthBottom:					tile = new EarthBottomFla( );					break;
					case eTileTypes.kEarthTopLeft:					tile = new EarthTopLeftFla( );					break;
					case eTileTypes.kEarthTopRight:					tile = new EarthTopRightFla( );					break;
					case eTileTypes.kEarthBottomRight:				tile = new EarthBottomRightFla( );				break;
					case eTileTypes.kEarthBottomLeft:				tile = new EarthBottomLeftFla( );				break;
					case eTileTypes.kEarthSpikes:					tile = new EarthSpikesFla( );					break;
					
					case eTileTypes.kCheeseTile:					tile = new CheeseTileFla();						break;
					case eTileTypes.kCheeseTop:						tile = new CheeseTopFla();						break;
					case eTileTypes.kCheeseRight:					tile = new CheeseRightFla();					break;
					case eTileTypes.kCheeseLeft:					tile = new CheeseLeftFla();						break;
					case eTileTypes.kCheeseBottom:					tile = new CheeseBottomFla();					break;
					
					case eTileTypes.kCheeseTopLeft:					tile = new CheeseTopLeftFla();					break;
					case eTileTypes.kCheeseTopRight:				tile = new CheeseTopRightFla();					break;
					case eTileTypes.kCheeseBottomLeft:				tile = new CheeseBottomLeftFla();				break;
					case eTileTypes.kCheeseBottomRight:				tile = new CheeseBottomRightFla();				break;
					case eTileTypes.kCheeseBottomLeftCorner:		tile = new CheeseBottomLeftCornerFla();			break;
					case eTileTypes.kCheeseBottomRightCorner:		tile = new CheeseBottomRightCornerFla();		break;
					
					case eTileTypes.kJumpThroughPlatform:			tile = new JumpThroughPlatformFla();			break;
					case eTileTypes.kGoal:							tile = new GoalFla();							break;
					
					//
					// characters
					//
					
					case eTileTypes.kPlayer:
					{
						tile = m_player = Player(SpawnMo( PlayerFla, tilePos ));
						tilePos = m_player.m_Pos;
					}
					break;
					
					case eTileTypes.kStar:
					{
						var c:MoveableObject = SpawnMo( StarFla, tilePos );
						tile = c;
						tilePos = c.m_Pos;
					}
					break;
					
					case eTileTypes.kLadyBird:
					{
						c = SpawnMo( LadyBirdFla, tilePos );
						tile = c;
						tilePos = c.m_Pos;
					}
					break;
					
					case eTileTypes.kBrain:
					{
						c = SpawnMo( BrainFla, tilePos );
						tile = c;
						tilePos = c.m_Pos;
					}
					break;
					
					case eTileTypes.kSkeleton:
					{
						c = SpawnMo( SkeletonFla, tilePos );
						tile = c;
						tilePos = c.m_Pos;
					}
					break;
					
					//
					// background tiles
					//
					
					case eTileTypes.kCheeseTileBackground:					tile = new CheeseTileBackgroundFla( );					break;
					case eTileTypes.kCheeseTopBackground:					tile = new CheeseTopBackgroundFla();					break;
					case eTileTypes.kCheeseRightBackground: 				tile = new CheeseRightBackgroundFla( );					break;
					case eTileTypes.kCheeseLeftBackground:					tile = new CheeseLeftBackgroundFla();					break;
					case eTileTypes.kCheeseBottomBackground:				tile = new CheeseBottomBackgroundFla();					break;
					case eTileTypes.kCheeseTopLeftBackground:				tile = new CheeseTopLeftBackgroundFla();				break;
					case eTileTypes.kCheeseTopRightBackground:				tile = new CheeseTopRightBackgroundFla();				break;
					case eTileTypes.kCheeseBottomLeftBackground:			tile = new CheeseBottomLeftBackgroundFla();				break;
					case eTileTypes.kCheeseBottomRightBackground:			tile = new CheeseBottomRightBackgroundFla();			break;
					case eTileTypes.kCheeseBottomLeftCornerBackground:		tile = new CheeseBottomLeftCornerBackgroundFla();		break;
					case eTileTypes.kCheeseBottomRightCornerBackground:		tile = new CheeseBottomRightCornerBackgroundFla();		break;
					
					case eTileTypes.kCheeseCornerTopLeft:					tile = new CheeseCornerTopLeftFla();					break;
					case eTileTypes.kCheeseCornerTopLeftBackground:			tile = new CheeseCornerTopLeftBackgroundFla();			break;
					case eTileTypes.kCheeseCornerTopRight:					tile = new CheeseCornerTopRightFla();					break;
					case eTileTypes.kCheeseCornerTopRightBackground:		tile = new CheeseCornerTopRightBackgroundFla();			break;
					
					case eTileTypes.kGrassBush:								tile = new GrassBushFla();								break;
					
					case eTileTypes.kMoveKeys:								tile = new MoveKeysFla();								break;
					case eTileTypes.kPunchKey:								tile = new PunchKeyFla();								break;
					
					//
					// Midground tiles
					//
					
					case eTileTypes.kLadderMid:								tile = new LadderMidFla();								break;
					case eTileTypes.kLadderTop:								tile = new LadderTopFla();								break;	
					
					
					default: Assert( false, "Unexpected tile code " + tileCode );
				}
				
				if ( tile!=null )
				{
					tile.x = tilePos.m_x;
					tile.y = tilePos.m_y;
					tile.cacheAsBitmap = true;
					
					if ( addtoScene )
					{
						this.addChild( tile );
					}
				}
				
				index++;
			}
		}
		
		/// <summary>
		/// 
		/// </summary>	
		protected override function Update( dt:Number ):void
		{
			if ( dt>0 )
			{
				// fixed frame rate
				dt = 1.0/30.0;
				
				m_keyboard.Update( );
				
				ClearDynamicGfx( );
				
				// work out what is on-screen
				m_onScreenMos.Clear( );
				
				for ( var i:int = 0; i<m_moveableObjects.m_Num; i++ )
				{
					var mo:MoveableObject = m_moveableObjects.Get( i );
					
					// if the character is hurt, it needs to get updated otherwise it wont be deleted
					if ( m_camera.OnScreenAABB( mo ) || mo.m_ForceUpdate )
					{
						m_onScreenMos.Add( mo );
					}
				}
				
				// update all moveable objects
				for ( i = 0; i<m_onScreenMos.m_Num; i++)
				{
					mo = m_onScreenMos.Get( i );
					
					if ( !mo.m_Dead )
					{
						mo.Update( dt );
					}
				}
				
				// player vs moveable object collision
				for ( i = 0; i<m_onScreenMos.m_Num; i++ )
				{
					mo = m_onScreenMos.Get( i );
					
					if ( mo is Enemy && !mo.m_Dead )
					{
						var enemy:Enemy = mo as Enemy;
						
						// does this enemy kill on touch?
						if ( !enemy.IsHurt() && enemy.m_KillsOnTouch && AABB.Overlap( m_player, enemy ) )
						{
							m_player.Hurt( enemy.m_Pos );
						}
						
						// handle player punching
						if ( m_player.m_Punching )
						{
							if ( AABB.Overlap( m_player.m_PunchAabb, enemy ) )
							{
								enemy.Hurt( m_player.m_Pos );
							}
						}
					}
					else if (mo is Diamond && AABB.Overlap( m_player, mo ))
					{
						// is this a collectable?
						mo.m_Dead = true;
							
						CreateEffect( CollectEffectFla, mo.m_Pos );
					}
					
					// remove dead objects
					if ( mo.m_Dead )
					{
						RemoveMo( mo, mo is Enemy );
					}
				}
				
				
				// camera depends on player
				m_camera.Update( dt );
				
				m_backgroundTR.Update();
				m_midgroundTR.Update();
				
				// clear vector2 allocator
				m_gTempVectorPool.Clear( );
			}
		}
		
		/// <summary>
		/// these effects are special in that they actually removes themselves from the scene when the anim ends (relies on timeline as)
		/// </summary>
		private function CreateEffect( type:Class, pos:Vector2 ):void
		{
			var de:* = new type( );
			de.x = pos.m_x;
			de.y = pos.m_y;
			
			this.addChild( de );
		}
		
		/// <summary>
		/// 
		/// </summary>
		private function RemoveMo( c:MoveableObject, dissipateEffect:Boolean=true ):Boolean
		{
			this.removeChild( c );
			
			if ( dissipateEffect )
			{
				CreateEffect( DissipateEffectFla, c.m_Pos );
			}
			
			return m_moveableObjects.Remove( c );
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function DrawPoint( p:Vector2, colour:uint, radius:Number=2 ):void
		{
			var spr:Sprite = new Sprite( );
			
			spr.graphics.beginFill( colour );
			spr.graphics.drawCircle( 0, 0, radius );
			spr.graphics.endFill( );
			
			spr.x = p.m_x;
			spr.y = p.m_y;
			
			m_dynamicGfx.push( spr );
			this.addChild( spr );
		}
		
		/// <summary>
		/// 
		/// </summary>	
		private function ClearDynamicGfx( ):void
		{
			for each(var s:Sprite in m_dynamicGfx)
			{
				this.removeChild( s );
			}
			
			m_dynamicGfx = new Vector.<Sprite>( );
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function SpawnMo( type:Class, pos:Vector2, addToScene:Boolean=false, ...args ):MoveableObject
		{
			var instance:* = new type();							
			instance.Initialise( pos, m_map, this, args );
			instance.cacheAsBitmap = true;
			
			m_moveableObjects.Add( instance );
			
			if ( addToScene )
			{
				this.addChild( instance );
			}
			
			return instance;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function LevelComplete( ):void
		{
			if ( m_currentLevel<m_levels.m_Num )
			{
				m_currentLevel++;
				
				ChangeMap( m_levels.Get( m_currentLevel ) );
			}
			else 
			{
				// ran out of levels!
				throw new NotImplementedException;
			}
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function DiedCompletely( ):void
		{
			// start whole level again
			m_player = null;
			ChangeMap( m_map );
			
			m_player.MakeTemporaryilyInvunerable( );
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function Died( ):void
		{
			m_hud.Died( );
		}
		
		/// <summary>
		/// 
		/// </summary>
		private function ChangeMap( newMap:Map ):void
		{
			var oldLives:int = m_player==null ? Player.kDefaultLives : m_player.m_Lives;
			
			m_map = newMap;
			m_player = null;
			
			if ( m_hud!=null )
			{
				m_hud.Clear( );
			}
			
			// fill this in
			Constants.kWorldHalfExtents = new Vector2( newMap.m_Width*Constants.kTileSize*0.5, newMap.m_Height*Constants.kTileSize*0.5 );
			
			// remove everything
			m_moveableObjects.Clear( );
			m_onScreenMos.Clear( );
			
			while (this.numChildren > 0)
			{
				this.removeChildAt( 0 );
			}
			
			CreateTilesInner( m_map.m_BackgroundMap );
			CreateTilesInner( m_map.m_MidgroundMap );
			CreateTilesInner( m_map.m_Map );
			
			// bring any brains to front
			for ( var i:int = 0; i<m_moveableObjects.m_Num; i++ )
			{
				if ( m_moveableObjects.Get( i ) is Brain )
				{
					this.setChildIndex( m_moveableObjects.Get( i ), this.numChildren-1 );
				}
			}
			
			Assert( m_player!=null, "Platformer.ChangeMap(): player not found in new map!" );
			
			// restore this
			m_player.m_Lives = oldLives;
			
			// camera controls what we see
			m_camera = new Camera( this, m_player );
			m_hud = new Hud( oldLives, this.stage );
			
			m_midgroundTR = new TileRenderer( MidgroundTileFla, 320, 320, m_camera, this, 1.5 );
			m_backgroundTR = new TileRenderer( BackgroundTileFla, 256, 256, m_camera, this, 2 );
		}
	}
}
