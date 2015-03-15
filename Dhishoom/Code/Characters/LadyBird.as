package Code.Characters
{
	import Code.Maths.*;
	import Code.Physics.*;
	
	public class LadyBird extends SimpleEnemy
	{
		// animation names
		private const kFireInAnim:String = "fireInAnim";
		private const kFireOutAnim:String = "fireOutAnim";
		
		private const kWalkSpeed:Number = 40;
		private const kWalkAnimMultiplier:Number = 1;
		private const kFireSpikesDelay:int = 60;
		private const kTriggerTimerRadius:Number = 200;
		
		private var m_fireSpikesCounter:int;
		private var m_originalXVel:Number;
		
		/// <summary>
		/// 
		/// </summary>
		public function LadyBird()
		{
			super();
			
			m_fireSpikesCounter = kFireSpikesDelay;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public override function Update( dt:Number ):void
		{
			super.Update( dt );
			
			var withinRadius:Boolean = m_platformer.m_Player.m_Pos.Sub( m_pos ).m_Len<kTriggerTimerRadius;
			var facingPlayer:Boolean = MoveableObject.HeadingTowards( m_platformer.m_Player.m_Pos, this );
			
			if (withinRadius && facingPlayer && m_hurtTimer==0 )
			{
				// every so often, we spawn some spikes
				if ( m_fireSpikesCounter>0 )
				{
					m_fireSpikesCounter--;
				}
				else if (m_animationController.m_Playing == kWalkAnim)
				{
					// begin a series of callbacks which eventually plays the spawn anim
					m_animationController.StopAtEnd( );
					m_animationController.SetEndOfAnimCallback( WaitTillEndOfAnim );
				}
			}
		}
		
		/// <summary>
		/// 
		/// </summary>
		private function WaitTillEndOfAnim( animName:String ):void
		{
			m_animationController.PlayOnce( kFireInAnim );
			m_animationController.SetEndOfAnimCallback( SpawnSpikes );
			
			// pause motion
			m_originalXVel = m_vel.m_x;
			
			if ( m_hurtTimer==0 )
			{
				m_vel.m_x = 0;
			}
		}
		
		/// <summary>
		/// 
		/// </summary>
		private function SpawnSpikes( animName:String ):void
		{
			var velX:Number = -this.scaleX*kWalkSpeed*2;
			
			var spikes:Character = Character(m_platformer.SpawnMo( LadySpikesFla, m_pos.Clone(), true, velX ));
			
			// put behind us in display list order
			m_platformer.setChildIndex( spikes, m_platformer.getChildIndex( this )-1 );
			
			m_animationController.PlayOnce( kFireOutAnim );
			m_animationController.SetEndOfAnimCallback( ResumeNormalAnim );
		}
		
		/// <summary>
		/// 
		/// </summary>
		private function ResumeNormalAnim( animName:String ):void
		{
			m_animationController.PlayLooping( kWalkAnim );
			
			// reset counter
			m_fireSpikesCounter = kFireSpikesDelay;
			
			// resume motion
			if ( m_hurtTimer==0 )
			{
				m_vel.m_x = m_originalXVel;
			}
		}
		
		/// <summary>
		/// 
		/// </summary>	
		protected override function get m_WalkSpeed( ):Number
		{
			return kWalkSpeed;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected override function get m_AnimSpeedMultiplier( ):Number
		{
			return kWalkAnimMultiplier;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public override function get m_KillsOnTouch( ):Boolean
		{
			return false;
		}
	}
}
