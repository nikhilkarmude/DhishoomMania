package Code.Characters
{
	import Code.Maths.Vector2;
	import Code.*;
	import Code.System.*;
	import Code.Geometry.*;
	import Code.Graphics.*;
	import Code.Maths.Scalar;
	import Code.Level.*;
	
	public class LadySpikes extends Enemy
	{
		private const kWalkSpeed:Number = 40;
		private const kLiveSeconds:Number = 3;
		private const kStoppedVel:Number = 1;
		
		private var m_timer:Number;
		
		/// <summary>
		/// 
		/// </summary>
		public function LadySpikes()
		{
			super();
			
			m_timer = 0;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public override function Initialise( pos:Vector2, map:Map, parent:Platformer, ...args ):Vector2
		{
			// get initial velocity from args
			m_vel.m_x = args[0];
			
			// face the direction of travel
			this.scaleX = -Scalar.Sign( m_vel.m_x );
			
			return super.Initialise( pos, map, parent, args );
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public override function Update( dt:Number ):void
		{
			super.Update( dt );
			
			if ( m_vel.m_Len < kStoppedVel )
			{
				m_dead = true;
			}
			
			m_timer += dt;
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
			return 0.5;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public override function get m_KillsOnTouch( ):Boolean
		{
			return true;
		}
		
		/// <summary>
		/// 
		/// </summary>
		public override function get m_HasWorldCollision( ):Boolean
		{
			return m_hurtTimer==0;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected override function get m_TileMapped( ):Boolean
		{
			return false;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected override function get m_ApplyGravity( ):Boolean
		{
			return m_hurtTimer==0;
		}
	}
}
