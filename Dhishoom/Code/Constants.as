package Code
{
	import Code.Maths.*;
	
	public class Constants
	{
		static public const kGravity:Number = 100;
		static public const kTwoPi:Number = Math.PI*2;
		static public const kMaxSpeed:Number = 300;
		static public const kScreenDimensions:Vector2 = new Vector2(640,360);
		static public var kWorldHalfExtents:Vector2;
		static public const kTileSize:int = 64;
		static public const k24FpsTimeStep:Number = 1.0/24.0;
		static public const kDesiredFps:Number = 30.0;
		static public const kUnitYNeg:Vector2 = new Vector2(0,-1);
		static public const kExpand:Vector2 = new Vector2(5,5);
		static public const kPlaneHeight:Number = 12;
	}
}
