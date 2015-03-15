package Code.Geometry
{
	import Code.*;
	
	public class PointAndDistanceContainer
	{
		public function PointAndDistanceContainer( p:Vector2, dist:Number )
		{
			m_pos = p;
			m_dist = dist;
		}
		public var m_pos:Vector2;
		public var m_dist:Number;
	}
}
