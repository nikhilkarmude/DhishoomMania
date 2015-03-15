package Code.Pickups
{
	import Code.Physics.*;
	
	public class Diamond extends MoveableObject
	{
		
		public function Diamond( )
		{
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
		protected override function get m_ApplyGravity( ):Boolean
		{
			return true;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected override function get m_ApplyFriction( ):Boolean
		{
			return true;
		}
		
		/// <summary>
		/// 
		/// </summary>
		protected override function get m_TileMapped( ):Boolean
		{
			return false;
		}
	}
}
