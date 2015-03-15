package Code.Characters
{
	import Code.Maths.Vector2;
	
	public class Skeleton extends Enemy
	{
		// animation names
		private const kJumpAnim:String = "jumpAnim";
		private const kDeadlyAnim:String = "deadlyAnim";
		
		private const kJumpStrength:Number = 800;
		
		private var m_jumping:Boolean;
		
		public function Skeleton( )
		{
			super( );
			
			ResetJumpSequence(null);
		}
		
		/// <summary>
		/// Stand still, play walk anim
		/// </summary>
		private function ResetJumpSequence( animName:String  ):void
		{
			// stand still
			m_vel.m_x = 0;
			m_jumping = false;
			
			m_animationController.PlayOnce( kWalkAnim );
			m_animationController.SetEndOfAnimCallback( PlayJumpAnim );
		}
		
		/// <summary>
		/// Play the jump anim
		/// </summary>	
		private function PlayJumpAnim( animName:String ):void
		{
			m_animationController.PlayOnce( kJumpAnim );
			m_animationController.SetEndOfAnimCallback( JumpTowardPlayer );
		}
		
		/// <summary>
		/// Actually jump towards the player
		/// </summary>	
		private function JumpTowardPlayer( animName:String ):void
		{
			if ( !IsHurt( ) )
			{
				// work out a new target velocity
				var targetPos:Vector2 = m_platformer.m_Player.m_Pos.Add( Vector2.RandomRadius( 100 ) );
				var playerUnitDirection:Vector2 = targetPos.SubFrom( m_pos ).UnitTo( );
				
				// must jump upwards!
				playerUnitDirection.m_y = -2;
				
				// re-normalise
				playerUnitDirection.UnitTo( );
				
				// jump towards player
				m_vel.AddTo( playerUnitDirection.MulScalarTo( kJumpStrength ) );
				
				m_jumping = true;
				
				m_animationController.SetEndOfAnimCallback( null );
			}
		}
		
		/// <summary>
		/// Check for landing, play the deadly animation when landed
		/// </summary>	
		public override function Update( dt:Number ):void
		{
			super.Update( dt );
			
			if ( m_jumping && !IsHurt() )
			{
				if ( m_OnGround&&!m_OnGroundLast )
				{
					// landed!
					m_animationController.PlayOnce( kDeadlyAnim );
					m_animationController.SetEndOfAnimCallback( ResetJumpSequence );
				}
			}
		}
		
		/// <summary>
		/// Apply collision detection only when not hurt
		/// </summary>
		public override function get m_HasWorldCollision( ):Boolean
		{
			return !IsHurt();
		}
		
		/// <summary>
		/// Apply gravity only when not hurt
		/// </summary>
		protected override function get m_ApplyGravity( ):Boolean
		{
			return !IsHurt();
		}
		
		/// <summary>
		/// Apply friction only when not hurt
		/// </summary>
		protected override function get m_ApplyFriction( ):Boolean
		{
			return !IsHurt();
		}
		
		/// <summary>
		/// Doesn't walk
		/// </summary>	
		protected override function get m_WalkSpeed( ):Number
		{
			return 0;
		}
		
		/// <summary>
		/// Force update when jumping so he's not left in mid air when going off screen
		/// </summary>
		public override function get m_ForceUpdate( ):Boolean
		{
			return super.m_ForceUpdate || m_jumping;
		}
		
		/// <summary>
		/// Only kills on touch when the deadly anim is playing
		/// </summary>
		public override function get m_KillsOnTouch( ):Boolean
		{
			return m_animationController.m_Playing==kDeadlyAnim;
		}
	}
}
