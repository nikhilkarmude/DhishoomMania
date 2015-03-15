package Code.Characters
{
	import Code.Maths.*;
	
	public class Brain extends Enemy
	{
		private const kWalkSpeed:Number = 80;
		
		private const kThinkSeconds:Number = 2;
		private const kMoveSeconds:Number = 1;
		
		private var m_thinkTimer:Number;
		private var m_moveTimer:Number;
		private var m_think:Boolean;
		
		public function Brain( )
		{
			m_thinkTimer = Scalar.RandBetween( 0, kThinkSeconds );
			m_think = true;
		}
		
		/// <summary>
		/// Pause, then target the player and move for a bit, repeat
		/// </summary>	
		public override function Update( dt:Number ):void
		{
			super.Update( dt );
			
			if (!IsHurt())
			{
				if ( m_think )
				{
					// have we gone past our think timer limit?
					if ( m_thinkTimer<0 )
					{
						// toggle modes
						m_think = false;
						
						// work out a new target velocity
						m_vel = m_platformer.m_Player.m_Pos.Sub( m_pos ).UnitTo( ).MulScalarTo( kWalkSpeed );
						
						// reset this timer
						m_moveTimer = kMoveSeconds;
					}
					
					m_thinkTimer -= dt;
				}
				else 
				{
					// have we gone past our move timer limit?
					if ( m_moveTimer<0 )
					{
						// toggle modes
						m_think = true;
						
						// stop moving
						m_vel.Clear( );
						
						// reset this timer
						m_thinkTimer = kThinkSeconds;
					}
					
					m_moveTimer -= dt;
				}
			}
		}
		
		/// <summary>
		/// Simple accessor
		/// </summary>	
		protected override function get m_WalkSpeed( ):Number
		{
			return kWalkSpeed;
		}
		
		
		
		/// <summary>
		/// Simple accessor
		/// </summary>
		public override function get m_KillsOnTouch( ):Boolean
		{
			return true;
		}
	}
}
