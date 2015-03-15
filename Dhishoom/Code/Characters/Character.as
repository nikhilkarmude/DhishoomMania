package Code.Characters
{
	import flash.display.*;
	import Code.Maths.Vector2;
	import Code.*;
	import Code.System.*;
	import Code.Geometry.*;
	import Code.Graphics.*;
	import Code.Level.*;
	import Code.Physics.*;
	
	public class Character extends MoveableObject
	{
		// shared animation names
		protected const kWalkAnim:String = "walkAnim";
		
		// how many frames does tha player flash for?
		protected const kEnemyHurtFrames:int = 10;
		
		protected var m_hurtTimer:int;
		protected var m_animationController:AnimationController;
		
		public function Character( )
		{
			super( );
						
			m_hurtTimer = 0;
					
			m_animationController = new AnimationController( this );
		}
		
		
		/// <summary>
		/// 
		/// </summary>	
		public function Hurt( hurtPos:Vector2 ):void
		{
			throw new NotImplementedException;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected function get m_AnimSpeedMultiplier( ):Number
		{
			return 1.0;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function IsHurt( ):Boolean
		{
			return m_hurtTimer!=0;
		}
			
		
		/// <summary>
		/// 
		/// </summary>	
		public override function Update( dt:Number ):void
		{
			super.Update( dt );
			
			m_animationController.Update( dt*m_AnimSpeedMultiplier );
		}
	}
}
