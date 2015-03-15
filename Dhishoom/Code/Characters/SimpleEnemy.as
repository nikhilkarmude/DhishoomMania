package Code.Characters
{
	import flash.display.*;
	import Code.Maths.*;
	import Code.*;
	import Code.Geometry.*;
	import Code.Graphics.AnimationController;
	import Code.System.*;
	import Code.Physics.*;
	
	public class SimpleEnemy extends Enemy
	{
		/// <summary>
		/// 
		/// </summary>
		public function SimpleEnemy()
		{
			super();
		}
		
		/// <summary>
		/// Simple update function which just checks for kReverseDirection markers
		/// </summary>	
		public override function Update( dt:Number ):void
		{
			if ( m_hurtTimer == 0 )
			{
				// form AABB for character
				var min:Vector2 = m_pos.Sub( m_halfExtents );
				var max:Vector2 = m_pos.Add( m_halfExtents );
				
				m_map.DoActionToTilesWithinAabb( min, max, InnerCollide, dt );
			}
						
			super.Update( dt );
		}
		
		/// <summary>
		/// Is the current tile a reverse direction maker? If so, change direction
		/// </summary>	
		protected override function InnerCollide( tileAabb:AABB, tileType:int, dt:Number, i:int, j:int ):void
		{
			if ( tileType==eTileTypes.kReverseDirection && MoveableObject.HeadingTowards(tileAabb.m_Centre, this) )
			{
				// toggle direction
				m_vel.m_x *= -1;
				this.scaleX *= -1;
			}
		}
		
		/// <summary>
		/// This enemy type is always updated, this is to stop them from bunching up 
		/// due to the off-screen deactivation code
		/// </summary>
		public override function get m_ForceUpdate( ):Boolean
		{
			return true;
		}
	}
}
