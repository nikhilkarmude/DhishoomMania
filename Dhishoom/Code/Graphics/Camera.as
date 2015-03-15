package Code.Graphics
{
	import Code.Geometry.AABB;
	import Code.System.Pool;
	import Code.Maths.*;
	import Code.Characters.Character;
	import Code.*;
	
	import flash.display.MovieClip;
	import flash.geom.*;
	import flash.events.MouseEvent;
	import Code.Geometry.IAABB;
	import Code.Physics.MoveableObject;
	
	public class Camera
	{
		static public const kInitialZoom:Number = 1;
		static private const kMinScale:Number = 1;
		static private const kMaxScale:Number = 1;
		
		private var m_parent:MovieClip;
		private var m_character:MoveableObject;
		private var m_scale:Vector2;
		private var m_translate:Vector2;
		private var m_worldToScreen:Matrix;
		private var m_screenToWorld:Matrix;
		
		private var m_screenSpaceAABB:AABB;
		private var m_tempAabbPool:Pool;
		
		private var m_cameraPos:Vector2;

		
		/// <summary>
		/// 
		/// </summary>	
		public function Camera(parent:MovieClip, character:MoveableObject)
		{
			m_parent = parent;
			m_character = character;
			m_scale = new Vector2(kInitialZoom,kInitialZoom);
			
			var screenCentre:Vector2 = new Vector2( Constants.kScreenDimensions.m_x/2, Constants.kScreenDimensions.m_y/2 );
			m_screenSpaceAABB = new AABB
								(
									screenCentre,
									screenCentre
								);
								
			m_cameraPos = character.m_Pos.Clone();
			
			Update(0);
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function Update( dt:Number ) : void
		{
			m_worldToScreen = new Matrix();
			
			var translate:Vector2 = Platformer.m_gTempVectorPool.AllocateClone( m_character.m_Pos ).NegTo( );

			var screenHalfExtents:Vector2 = Platformer.m_gTempVectorPool.Allocate( Constants.kScreenDimensions.m_x*0.5/m_scale.m_x, Constants.kScreenDimensions.m_y*0.5/m_scale.m_y );

			var topLeft:Vector2 = Platformer.m_gTempVectorPool.AllocateClone(m_character.m_Pos).SubFrom(screenHalfExtents);
			var bottomRight:Vector2 = Platformer.m_gTempVectorPool.AllocateClone(m_character.m_Pos).AddTo(screenHalfExtents);

			var correctLeft:Number = Math.min(topLeft.m_x+Constants.kWorldHalfExtents.m_x, 0);
			var correctTop:Number = Math.min(topLeft.m_y+Constants.kWorldHalfExtents.m_y, 0);

			var correctRight:Number = Math.min(Constants.kWorldHalfExtents.m_x-bottomRight.m_x, 0);
			var correctBottom:Number = Math.min(Constants.kWorldHalfExtents.m_y-bottomRight.m_y, 0);

			translate.m_x += correctLeft - correctRight;
			translate.m_y += correctTop - correctBottom;
			
			m_cameraPos = translate.m_Neg;
						
			m_worldToScreen.translate( translate.m_x, translate.m_y );
			m_worldToScreen.scale( m_scale.m_x, m_scale.m_y );
			m_worldToScreen.translate( Constants.kScreenDimensions.m_x/2, Constants.kScreenDimensions.m_y/2 );
			
			// this is essential to stop cracks appearing between tiles as we scroll around - because cacheToBitmap means
			// sprites can only be positioned on whole pixel boundaries, sub-pixel camera movements cause gaps to appear.
			m_worldToScreen.tx = Math.floor( m_worldToScreen.tx+0.5 );
			m_worldToScreen.ty = Math.floor( m_worldToScreen.ty+0.5 );
			
			m_parent.transform.matrix = m_worldToScreen;
			
			// for screen->world matrix
			m_screenToWorld = m_worldToScreen.clone();
			m_screenToWorld.invert();
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function ScreenToWorldPos( e:MouseEvent ):Vector2
		{
			return Vector2.FromPoint( m_screenToWorld.transformPoint( new Vector2(e.stageX, e.stageY).m_Point ) );
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function ScreenToWorldPosV( v:Vector2 ):Vector2
		{
			return Vector2.FromPoint( m_screenToWorld.transformPoint( v.m_Point ) );
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function WorldToScreenPos( worldPos:Vector2 ):Vector2
		{
			return Vector2.FromPoint( m_worldToScreen.transformPoint( worldPos.m_Point ) );
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function OnScreen( worldPos:Vector2 ):Boolean
		{
			var screenPos:Vector2 = WorldToScreenPos(worldPos);
			
			return screenPos.m_x >= 0 && screenPos.m_x < Constants.kScreenDimensions.m_x &&
					screenPos.m_y>=0&&screenPos.m_y<Constants.kScreenDimensions.m_y;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function OnScreenAABB( aabb:IAABB ):Boolean
		{
			var screenSpaceCentre:Vector2 = WorldToScreenPos( aabb.m_Centre );
			var screenSpaceAABB:AABB = new AABB( screenSpaceCentre, aabb.m_HalfExtents );
			
			return AABB.Overlap( m_screenSpaceAABB, screenSpaceAABB );
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function GetWorldSpaceOnScreenAABB( outAabb:AABB ):void
		{
			outAabb.UpdateFrom( m_cameraPos, m_screenSpaceAABB.m_HalfExtents.Div( m_scale ) );
		}
		
		/// <summary>
		/// 
		/// </summary>
		public function GetWorldSpaceVisibleHalfExtents( ):Vector2
		{
			return m_screenSpaceAABB.m_HalfExtents.Div( m_scale );
		}
		
		
		/// <summary>
		/// 
		/// </summary>	
		public function set m_Scale(scale:Number):void
		{
			var oldScale:Number = m_scale.m_x;
			
			scale = Scalar.Clamp( scale, kMinScale, kMaxScale );
			
			m_scale.m_x = scale;
			m_scale.m_y = scale;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function get m_Scale( ):Number
		{
			return m_scale.m_x;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function get m_CameraPos( ):Vector2
		{
			return m_cameraPos;
		}
		
		/// <summary>
		/// 
		/// </summary>	
		public function SetTarget( target:MoveableObject ):void
		{
			m_character = target;
		}
	}
}
