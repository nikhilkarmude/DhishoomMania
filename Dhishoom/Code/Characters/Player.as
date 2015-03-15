package Code.Characters
{
	import flash.display.*;
	import flash.utils.*;
	
	import Code.Maths.*;
	import Code.Graphics.AnimationController;
	import Code.*;
	import Code.System.*;
	import Code.Geometry.*;
	import Code.Level.*;
	
	public class Player extends Character
	{
		// animation names
		private const kJumpAnim:String = "jumpAnim";
		private const kLandAnim:String = "landAnim";
		private const kFallAnim:String = "fallAnim";
		private const kPunchAnim:String = "punchAnim";
		private const kGoalAnim:String = "goalAnim";
		private const kDiedAnim:String = "diedAnim";
		private const kIdleAnim:String = "idleAnim";
		private const kClimbAnim:String = "climbAnim";
		
		// how high do they jump?
		private const kPlayerJumpVel:Number = 900*1.2;
		
		// how many frames does tha player flash for?
		private const kHurtFrames:int = 120;
		
		// default lives
		static public const kDefaultLives:int = 2;
		
		private const kLadderStayStrength:Number = 400;
		
		//
		// symbol linkage to CS4
		//
		
		public var m_flaPlayer:MovieClip;
		
		// controls how fast the player's velocity moves towards the target velocity
		// 1.0 = in one frame, 0 = never
		private const kReachTargetScale:Number = 0.7;
		
		// how fast the player walks
		private const kWalkSpeed:Number = 80;
		
		
		private var m_velTarget:Vector2;
		
		private var m_keyboard:Keyboard;
		
		
		
		private var m_tileAabb:AABB;
		private var m_punchAabb:AABB;
		
		
		
		private var m_collideLadder:uint;
		private var m_oldCollideLadder:uint;
		private var m_tryToMove:Boolean;
		private var m_flyMode:Boolean;
		private var m_climbLadder:Boolean;
		private var m_onLadderTop:Boolean;
		private var m_disableLadderTopCollision:Boolean;
		
		private var m_goalIn:Boolean;
		
		private var m_lives:int;
		
		
		/// <summary>
		/// 
		/// </summary>	
		public function Player( )
		{
			super();
			
			
			//m_flaPlayer.visible = false;
			m_flyMode = false;
			m_collideLadder = eTileTypes.kEmpty;
			
			m_climbLadder = false;
			m_onLadderTop = false;
			m_disableLadderTopCollision = false;
			
			m_goalIn = false;
							
			// temporary storage for collision against tiles
			m_tileAabb = new AABB( );
						
			m_velTarget = new Vector2( );
			
			m_lives = kDefaultLives;
		}
		
		/// <summary>
		/// Replaces the constructor since we can't have any parameters due to the CS4 symbol inheritance
		/// </summary>	
		public override function Initialise(pos:Vector2, map:Map, parent:Platformer, ...args ):Vector2
		{
			var newPos:Vector2 = super.Initialise( pos, map, parent );
			
			m_velTarget = new Vector2( );
			m_keyboard = parent.m_Keyboard;
			
			m_animationController.Stop( );
			
			m_punchAabb = new AABB( newPos.Clone(), m_halfExtents.Clone() );
			
			return newPos;
		}
		
		
		/// <summary>
		/// 
		/// </summary>
		public function MakeTemporaryilyInvunerable( ):void
		{
			m_hurtTimer = kHurtFrames;
		}
		
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_Punching( ):Boolean
		{
			return !m_animationController.m_Stopped && m_animationController.m_Playing == kPunchAnim;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_PunchAabb( ):AABB
		{
			// put the punch hit marker twice the radius away from the player
			m_punchAabb.m_Centre.m_x = m_pos.m_x+m_radius*this.scaleX*2;
			m_punchAabb.m_Centre.m_y = m_pos.m_y;
			
			return m_punchAabb;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function get m_Lives( ):int
		{
			return m_lives;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function set m_Lives( numLives:int ):void
		{
			m_lives = numLives;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public override function get m_HasWorldCollision( ):Boolean
		{
			return true;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public override function Update( dt:Number ):void
		{
			// player contol
			if ( !m_animationController.m_Locked )
			{
				KeyboardControl( dt );
			}
			
			// integrate velocity
			if ( m_flyMode )
			{
				m_vel.MulScalarTo( 0.5 );
			}
			else
			{
				m_vel.AddYTo( Constants.kGravity );
			}
			
			// clamp speed
			m_vel.m_x = Scalar.Clamp( m_vel.m_x, -Constants.kMaxSpeed, Constants.kMaxSpeed );
			
			if ( m_climbLadder )
			{
				m_vel.m_y = Scalar.Clamp( m_vel.m_y, -Constants.kMaxSpeed, Constants.kMaxSpeed );
			}
			else 
			{
				m_vel.m_y = Math.min( m_vel.m_y, Constants.kMaxSpeed*2 );
			}
			
			if ( m_goalIn )
			{
				m_vel.Clear( );
			}
			
			super.Update( dt );
			
			if ( m_hurtTimer>0 && m_lives > 0 )
			{
				this.visible = (m_hurtTimer&1) == 1;
				m_hurtTimer--;
			}
		}
		
		/// <summary>
		/// 
		/// </summary>
		private function ClimbOrStop( climbing:Boolean ):void
		{
			if ( climbing )
			{
				m_animationController.PlayLooping( kClimbAnim );
			}
			else 
			{
				m_animationController.StopAtEnd( );
			}
		}
		
		
		/// <summary>
		/// 
		/// </summary>
		private function WalkOrStop( walking:Boolean ):void
		{
			if ( walking )
			{
				m_animationController.PlayLooping( kWalkAnim );
			}
			else 
			{
				if ( m_animationController.m_Playing==kWalkAnim )
				{
					m_animationController.PlayOnce( kIdleAnim );
				}
				else 
				{
					m_animationController.StopAtEnd( );
				}
			}
		}
		
		/// <summary>
		/// 
		/// </summary>	
		private function KeyboardControl( dt:Number ):void
		{
			m_tryToMove = false;
			
			var moveSpeed:Number;
			
			if ( m_flyMode )
			{
				moveSpeed = kWalkSpeed*4;
			}
			else 
			{
				moveSpeed = m_OnGround ? kWalkSpeed : kWalkSpeed/2;
			}
			
			m_velTarget.Clear( );
			
			if ( m_climbLadder && !m_OnGround )
			{
				//
				// ladder climbing controls
				//
				
				var walking:Boolean = false;
				
				if ( m_keyboard.IsKeyDown( eKeyCodes.kLeftArrow ) )
				{
					m_velTarget.m_x = -Constants.kMaxSpeed;
					
					// face left
					this.scaleX = -1;
					
					walking = true;
				}
				if ( m_keyboard.IsKeyDown( eKeyCodes.kRightArrow ) )
				{
					m_velTarget.m_x = Constants.kMaxSpeed;
					
					// face right
					this.scaleX = 1;
					
					walking = true;
				}
				if ( m_keyboard.IsKeyDown( eKeyCodes.kDownArrow ) )
				{
					m_velTarget.m_y = Constants.kMaxSpeed;
					
					walking = true;
				}
				if ( m_keyboard.IsKeyDown( eKeyCodes.kUpArrow ) )
				{
					m_velTarget.m_y = -Constants.kMaxSpeed;
					
					walking = true;
				}
				
				ClimbOrStop( walking );
			}
			else
			{
				//
				// normal walking controls
				//
				
				walking = false;
				
				if ( m_keyboard.IsKeyDown( eKeyCodes.kLeftArrow ) )
				{
					m_vel.m_x -= moveSpeed;
					walking = m_tryToMove = true;
					
					// face left
					this.scaleX = -1;
				}
				if ( m_keyboard.IsKeyDown( eKeyCodes.kRightArrow ) )
				{
					m_vel.m_x += moveSpeed;
					walking = m_tryToMove = true;
					
					// face right
					this.scaleX = 1;
				}
				
				if ( m_OnGround && !m_Punching )
				{
					WalkOrStop( walking );
				}
			}
			
			if (m_flyMode || m_collideLadder)
			{
				if ( m_keyboard.IsKeyDown( eKeyCodes.kUpArrow ) )
				{
					if ( m_collideLadder )//&& m_OnGround )
					{
						//
						// joining ladder at bottom
						//
						
						m_vel.m_y -= moveSpeed*4;
						m_climbLadder = true;
					}
					else 
					{
						// fly mode controls
						m_vel.m_y -= moveSpeed;
					}
					
					m_tryToMove = true;
				}
			}
			else
			{
				//
				// jump controls
				//
				
				if ( m_keyboard.IsKeyDownTransition( eKeyCodes.kUpArrow ) )
				{
					if ( m_OnGround )
					{
						m_vel.m_y -= kPlayerJumpVel;
						
						m_animationController.PlayOnce( kJumpAnim );
					}
				}
				
				if ( m_keyboard.IsKeyDown( eKeyCodes.kDownArrow ) && m_onLadderTop )
				{
					//
					// joining a ladder at the top 
					//
					
					m_disableLadderTopCollision = true;
				}
			}
			
			//
			// punching
			//
					
			if ( m_keyboard.IsKeyDownTransition( eKeyCodes.kSpace ) )
			{
				m_animationController.PlayOnce( kPunchAnim );
			}
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected override function PreCollisionCode( ):void
		{
			super.PreCollisionCode( );
			
			// keep track of transitioning between ladder states
			m_oldCollideLadder = m_collideLadder;
			m_collideLadder = eTileTypes.kEmpty;
		}
		
		/// <summary>
		/// Special implementation for the player
		/// </summary>
		protected override function PostCollisionCode( ):void
		{
			super.PostCollisionCode( );
			
			// if we're not colliding with the ladder or we're on the ground, we're not climbing the ladder
			if ( !m_collideLadder || m_OnGround )
			{
				m_climbLadder = false;
			}
			
			// if we fall onto the top of a ladder, we start climbing it
			if ( m_oldCollideLadder==eTileTypes.kEmpty && Map.IsTileLadder(m_collideLadder) && !m_OnGround )
			{
				m_climbLadder = true;
				m_animationController.PlayOnce( kClimbAnim );
			}
			
			if ( !m_OnGround && !m_climbLadder && !m_Punching && m_vel.m_y > 0 )
			{
				m_animationController.PlayOnce( kFallAnim ); 
			}
		}
		
		/// <summary>
		/// Special case code for the player colliding with different tile types
		/// </summary>	
		protected override function InnerCollide(tileAabb:AABB, tileType:int, dt:Number, i:int, j:int ):void
		{
			// is it collidable?
			if ( Map.IsTileObstacle( tileType ) )
			{
				var collided:Boolean = Collide.AabbVsAabb( this, tileAabb, m_contact, i, j, m_map );
				if ( collided )
				{
					CollisionResponse( m_contact.m_normal, m_contact.m_dist, dt );
				}
			}
			else if ( Map.IsTileDeadly( tileType ) )
			{
				if ( Collide.PointInAabb( m_Pos, tileAabb ) )
				{
					Hurt( tileAabb.m_Centre );
				}
			}
			else if ( Map.IsTileLadder( tileType ) )
			{
				//
				// Are we colliding with the top of a ladder?
				//
				
				var checkLadderMiddle:Boolean = false;
				
				if ( Map.IsTileLadderTop( tileType ) && !m_disableLadderTopCollision )
				{
					m_onLadderTop = Collide.AabbVsAabbTopPlane( this, tileAabb, m_contact, i, j, m_map );
					
					if ( m_onLadderTop )
					{
						CollisionResponse( m_contact.m_normal, m_contact.m_dist, dt );
					}
					else 
					{
						checkLadderMiddle = true;
					}
				}
				else 
				{
					checkLadderMiddle = true;
				}
				
				if (checkLadderMiddle)
				{
					//
					// check to see if we're colliding with the middle of a ladder
					//
					
					if (Collide.PointInAabb(m_Pos, tileAabb))
					{
						m_collideLadder = tileType;
						m_disableLadderTopCollision = false;
						
						if ( m_climbLadder )
						{
							// remove a portion of the total velocity of the character
							var delta:Vector2 = m_velTarget.Sub( m_vel );
							
							var len:Number = delta.m_Len;
							var change:Vector2 = delta;
							if ( len>kLadderStayStrength )
							{
								// limit the amount we can remove velocity by
								change.MulScalarTo( kLadderStayStrength/len );
							}
							
							m_vel.AddTo( change );
						}
					}
				}
			}
			else if ( Map.IsJumpThroughPlatform( tileType ) )
			{
				if ( Collide.AabbVsAabbTopPlane( this, tileAabb, m_contact, i, j, m_map ) )
				{
					CollisionResponse( m_contact.m_normal, m_contact.m_dist, dt );
				}
			}
			else if ( Map.IsTileGoal( tileType ) )
			{
				// if the player centre is in the goal, its level complete!
				if ( !m_goalIn && Collide.PointInAabb( m_Pos, tileAabb ) )
				{
					// centre on stage
					var goalInAnim:GoalInAnimFla = new GoalInAnimFla( );
					goalInAnim.x = Constants.kScreenDimensions.m_x/2;
					goalInAnim.y = Constants.kScreenDimensions.m_y/2;
					
					// removes itself once anim complete (timeline as)
					this.stage.addChild( goalInAnim );
					
					m_animationController.PlayOnce( kGoalAnim );
					m_animationController.SetEndOfAnimCallback( LevelComplete );
					m_animationController.m_Locked = true;
					
					m_goalIn = true;
				}
			}
		}
		
		/// <summary>
		/// 
		/// </summary>
		private function LevelComplete( animName:String ):void
		{
			m_platformer.LevelComplete( );
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public override function Hurt( hurtPos:Vector2 ):void
		{
			if ( m_hurtTimer==0 && !m_goalIn && m_lives>0 )
			{
				m_hurtTimer = kHurtFrames;
				
				m_lives--;
				m_platformer.Died( );
				
				if ( m_lives==0 )
				{
					m_animationController.PlayOnce( kDiedAnim );
					m_animationController.SetEndOfAnimCallback( Died );
					m_animationController.m_Locked = true;
					
					m_vel.m_x = 0;
				}
				else 
				{
					// give player impulse to knock him off track
					var signX:Number = Scalar.Sign( hurtPos.m_x-m_pos.m_x );
					
					m_vel.AddTo( new Vector2( -400*signX, -1000 ) );
				}
			}
		}
		
		/// <summary>
		/// 
		/// </summary>
		private function Died( animName:String ):void
		{
			// centre on stage
			var tryOverAnim:TryOverAnimFla = new TryOverAnimFla( );
			tryOverAnim.x = Constants.kScreenDimensions.m_x/2;
			tryOverAnim.y = Constants.kScreenDimensions.m_y/2;
			
			// removes itself once anim complete (timeline as)
			this.stage.addChild( tryOverAnim );
			
			setTimeout( function( ):void
			{
				m_platformer.DiedCompletely( );
			}, 3000);
		}
				
		/// <summary>
		/// 
		/// </summary>	
		protected override function get m_ApplyFriction( ):Boolean
		{
			return !m_tryToMove;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		protected override function LandingTransition( ):void
		{
			m_animationController.PlayOnce( kLandAnim ); 
		}
	}
}
