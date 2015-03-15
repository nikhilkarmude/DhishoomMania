package Code.Characters
{
	import flash.display.*;
	import Code.Maths.*;
	import Code.*;
	import Code.Geometry.*;
	import Code.Graphics.AnimationController;
	import Code.System.*;
	import Code.Level.*;
	
	public class Enemy extends Character
	{
		// animation names
		private const kHitAnim:String = "hitAnim";
		
		/// <summary>
		/// Simple constructor
		/// </summary>
		public function Enemy( )
		{
			// aways go to the left by default;
			m_vel.m_x = -m_WalkSpeed;
			
			m_animationController.PlayLooping( kWalkAnim );
			m_animationController.GotoRandomFrameInCurrentAnim( );
		}
				
		/// <summary>
		/// Simple update function
		/// </summary>	
		public override function Update( dt:Number ):void
		{
			if ( m_hurtTimer > 0 )
			{
				m_hurtTimer--;
			}
			
			super.Update( dt );
		}
		
		/// <summary>
		/// Hurt this enemy, player was at hurtPos
		/// </summary>	
		public override function Hurt( hurtPos:Vector2 ):void
		{
			if ( m_hurtTimer==0 )
			{
				m_hurtTimer = kEnemyHurtFrames;
				
				m_animationController.PlayOnce( kHitAnim );
				m_animationController.SetEndOfAnimCallback( DeleteEnemy );
			}
		}
		
		/// <summary>
		/// 
		/// </summary>
		public override function IsHurt( ):Boolean
		{
			return super.IsHurt( )||m_animationController.m_Playing==kHitAnim;
		}
		
		/// <summary>
		/// Animation callback used to delete this enemy and spawn a pick-up
		/// </summary>
		private function DeleteEnemy( animName:String ):void
		{
			// mark this enemy as dead, it will be deleted
			m_dead = true;
			
			// spawn a pickup
			m_platformer.SpawnMo( DiamondPickupFla, m_pos.Clone( ), true );
		}
		
		/// <summary>
		/// What speed should this guy walk at?
		/// </summary>	
		protected function get m_WalkSpeed( ):Number
		{
			throw new NotImplementedException;
		}
		
		/// <summary>
		/// Does he kill on touch?
		/// </summary>
		public function get m_KillsOnTouch( ):Boolean
		{
			throw new NotImplementedException;
		}
	}
}
