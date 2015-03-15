package Code.Characters
{
	public class Star extends SimpleEnemy
	{
		private const kWalkSpeed:Number = 40;
		private const kWalkAnimMultiplier:Number = 1.0;
		
		/// <summary>
		/// 
		/// </summary>
		public function Star()
		{
			super();
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
		protected override function get m_AnimSpeedMultiplier( ):Number
		{
			return kWalkAnimMultiplier;
		}
		
		/// <summary>
		/// Kills on touch
		/// </summary>
		public override function get m_KillsOnTouch( ):Boolean
		{
			return true;
		}
	}
}
