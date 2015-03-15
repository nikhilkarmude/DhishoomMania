package Code.Physics
{
	import flash.display.*;
	import Code.Maths.Vector2;
	import Code.*;
	import Code.System.*;
	import Code.Geometry.*;
	import Code.Graphics.*;
	import Code.Level.*;
	
	
	public class MoveableObject extends MovieClip implements IAABB, ICircle
	{
		// friction with ground - 1=totally sticky, 0=ice
		private const kGroundFriction:Number = 0.6;
		
		protected var m_pos:Vector2;
		protected var m_posCorrect:Vector2;
		protected var m_vel:Vector2;
		protected var m_radius:Number;
		protected var m_halfExtents:Vector2;
		
		protected var m_platformer:Platformer;
		protected var m_map:Map;
		
		private var m_collision:MovieClip;
		
		protected var m_contact:Contact;
		
		private var m_onGround:Boolean;
		private var m_onGroundLast:Boolean;
		
		protected var m_dead:Boolean;
		
		public function MoveableObject( )
		{
			super( );
			
			// get collsion radius
			m_collision = MovieClip(getChildByName( "m_flaCollision" ));
			Assert( m_collision!=null, "Missing collision shape called \"m_flaCollision\"" );
			
			// hide the collision shape
			m_collision.visible = false;
			
			m_radius = m_collision.width/2;
			m_halfExtents = new Vector2( m_radius, m_radius );
			
			m_vel = new Vector2( );
			m_posCorrect = new Vector2( );
			
			m_contact = new Contact( );
			
			m_dead = false;
		}
		
		/// <summary>
		/// Replaces the constructor since we can't have any parameters due to the CS4 symbol inheritance
		/// </summary>	
		public function Initialise( pos:Vector2, map:Map, parent:Platformer, ...args ):Vector2
		{
			// position in the centre of the tile in the X and resting on the bottom of the tile in the Y
			if ( m_TileMapped )
			{
				pos.m_x += Constants.kTileSize/2;
				pos.m_y += Constants.kTileSize-m_radius;
			}
			
			m_Pos = pos;
			m_platformer = parent;
			m_map = map;
			
			return pos;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected function get m_FlaCollision( ):MovieClip
		{
			return m_collision;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function get m_Radius( ):Number
		{
			return m_radius;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_Centre( ):Vector2
		{
			return m_pos;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_HalfExtents( ):Vector2
		{
			return m_halfExtents;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function get m_Pos( ):Vector2
		{
			return m_pos;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function set m_Pos( pos:Vector2 ):void
		{
			m_pos = pos;
			
			// update visual
			this.x = pos.m_x;
			this.y = pos.m_y;
		}
		
		
		/// <summary>
		/// 
		/// </summary>	
		public function get m_Vel( ):Vector2
		{
			return m_vel;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function set m_Vel( vel:Vector2 ):void
		{
			m_vel = vel;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected function get m_OnGround( ):Boolean
		{
			return m_onGround;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected function get m_OnGroundLast( ):Boolean
		{
			return m_onGroundLast;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected function get m_TileMapped( ):Boolean
		{
			return true;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function get m_Dead( ):Boolean
		{
			return m_dead;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function set m_Dead( dead:Boolean ):void
		{
			m_dead = dead;
		}
		
		/// <summary>
		/// Apply gravity, do collision and integrate position
		/// </summary>	
		public function Update( dt:Number ):void
		{
			if ( m_ApplyGravity )
			{
				m_vel.AddYTo( Constants.kGravity );
				
				// clamp max speed
				m_vel.m_y = Math.min( m_vel.m_y, Constants.kMaxSpeed*2 );
			}
			
			if ( m_HasWorldCollision )
			{
				// do complex world collision
				Collision( dt );
			}
			
			// integrate position
			m_pos.MulAddScalarTo( m_vel.Add(m_posCorrect), dt );
			
			// force the setter to act
			m_Pos = m_pos;
			m_posCorrect.Clear( );
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_HasWorldCollision( ):Boolean
		{
			return false;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected function get m_ApplyGravity( ):Boolean
		{
			return false;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected function get m_ApplyFriction( ):Boolean
		{
			return false;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_ForceUpdate( ):Boolean
		{
			return false;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected function PreCollisionCode( ):void
		{
			m_onGroundLast = m_onGround;
			m_onGround = false;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected function PostCollisionCode( ):void
		{
		}
		
		/// <summary>
		/// Do collision detection and response for this object
		/// </summary>	
		protected function Collision( dt:Number ):void
		{
			// where are we predicted to be next frame?
			var predictedPos:Vector2 = Platformer.m_gTempVectorPool.AllocateClone( m_pos ).MulAddScalarTo( m_vel, dt );
			
			// find min/max
			var min:Vector2 = m_pos.Min( predictedPos );
			var max:Vector2 = m_pos.Max( predictedPos );
			
			// extend by radius
			min.SubFrom( m_halfExtents );
			max.AddTo( m_halfExtents );
			
			// extend a bit more - this helps when player is very close to boundary of one map cell
			// but not intersecting the next one and is up a ladder
			min.SubFrom( Constants.kExpand );
			max.AddTo( Constants.kExpand );
			
			PreCollisionCode( );
			
			m_map.DoActionToTilesWithinAabb( min, max, InnerCollide, dt );
			
			PostCollisionCode( );
		}
		
		/// <summary>
		/// Inner collision response code
		/// </summary>	
		protected function InnerCollide(tileAabb:AABB, tileType:int, dt:Number, i:int, j:int ):void
		{
			// is it collidable?
			if ( Map.IsTileObstacle( tileType ) )
			{
				// standard collision responce
				var collided:Boolean = Collide.AabbVsAabb( this, tileAabb, m_contact, i, j, m_map );
				if ( collided )
				{
					CollisionResponse( m_contact.m_normal, m_contact.m_dist, dt );
				}
			}
			else if ( Map.IsJumpThroughPlatform( tileType ) || Map.IsTileLadderTop(tileType) )
			{
				// these type of platforms are handled separately since you can jump through them
				collided = Collide.AabbVsAabbTopPlane( this, tileAabb, m_contact, i, j, m_map );
				if ( collided )
				{
					CollisionResponse( m_contact.m_normal, m_contact.m_dist, dt );
				}
			}
		}
		
		/// <summary>
		/// 
		/// </summary>	
		protected function LandingTransition( ):void
		{
		}
		
		/// <summary>
		/// Collision Reponse - remove normal velocity
		/// </summary>	
		protected function CollisionResponse( normal:Vector2, dist:Number, dt:Number ):void
		{
			// get the separation and penetration separately, this is to stop pentration 
			// from causing the objects to ping apart
			var separation:Number = Math.max( dist, 0 );
			var penetration:Number = Math.min( dist, 0 );
			
			// compute relative normal velocity require to be object to an exact stop at the surface
			var nv:Number = m_vel.Dot( normal ) + separation/dt;
			
			// accumulate the penetration correction, this is applied in Update() and ensures
			// we don't add any energy to the system
			m_posCorrect.SubFrom( normal.MulScalar( penetration/dt ) );
			
			if ( nv<0 )
			{
				// remove normal velocity
				m_vel.SubFrom( normal.MulScalar( nv ) );
				
				// is this some ground?
				if ( normal.m_y<0 )
				{
					m_onGround = true;
					
					// friction
					if ( m_ApplyFriction )
					{
						// get the tanget from the normal (perp vector)
						var tangent:Vector2 = normal.m_Perp;
						
						// compute the tangential velocity, scale by friction
						var tv:Number = m_vel.Dot( tangent )*kGroundFriction;
						
						// subtract that from the main velocity
						m_vel.SubFrom( tangent.MulScalar( tv ) );
					}
					
					if (!m_onGroundLast)
					{
						// this transition occurs when this object 'lands' on the ground
						LandingTransition( );
					} 
				}
			}
		}
		
		/// <summary>
		/// Is the given candidate heading towards towardsPoint? 
		/// </summary>
		static public function HeadingTowards( towardsPoint:Vector2, candidate:MoveableObject ):Boolean
		{
			var deltaX:Number = towardsPoint.m_x-candidate.m_Pos.m_x;
			var headingTowards:Boolean = deltaX*candidate.m_Vel.m_x>0;
			
			return headingTowards;
		}
	}
}
