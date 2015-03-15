package Code.Gui
{
	import Code.System.*;
	import flash.display.*;
	import flash.filters.GlowFilter;
	import Code.Constants;
	
	public class Hud
	{
		private var m_lifeIcons:ReferenceArray;
		private var m_stage:Stage;
		
		/// <summary>
		/// 
		/// </summary>
		public function Hud( defaultLives:int, stage:Stage )
		{ 
			m_stage = stage;
			m_lifeIcons = new ReferenceArray( HudLifeFla );
			
			for ( var i:int = 0; i<defaultLives; i++ )
			{
				var icon:HudLifeFla = new HudLifeFla( );
				
				icon.x = i*( icon.width+5 )+Constants.kScreenDimensions.m_x/2;
				icon.y = 5;
								
				m_lifeIcons.Add( icon );
				
				m_stage.addChild( icon );
			}
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function Died( ):void
		{
			Assert( m_lifeIcons.m_Num>0, "Hud.Died(): no lives left!" );
			
			var icon:HudLifeFla = m_lifeIcons.Get( m_lifeIcons.m_Num-1 );
			
			m_stage.removeChild( icon );
			m_lifeIcons.Remove( icon );
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function Clear( ):void
		{
			while (m_lifeIcons.m_Num > 0)
			{
				m_stage.removeChild( m_lifeIcons.Get( 0 ) );
				m_lifeIcons.RemoveIndex( 0 );
			}
		}
	}
}
